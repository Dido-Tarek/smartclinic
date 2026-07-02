import 'dart:async';
import 'dart:io';
import 'dart:typed_data' as td;
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:image_background_remover/image_background_remover.dart';
import 'package:path_provider/path_provider.dart';

/// Singleton service that wraps [BackgroundRemover] with:
///
/// - **Disk-persistent cache** — processed images survive app restarts.
///   The ONNX model only ever runs once per unique image URL / asset path.
/// - **In-memory L1 cache** — zero-latency hits for already-loaded images.
/// - **Serial ONNX queue** — one inference at a time to avoid UI jank.
/// - **Graceful fallback** on any error.
class BgRemoverService {
  BgRemoverService._();
  static final BgRemoverService instance = BgRemoverService._();

  // L1 — RAM cache (fast, lost on restart)
  final Map<String, td.Uint8List> _memCache = {};

  // L2 — disk cache directory (persistent across restarts)
  Directory? _cacheDir;

  Future<void>? _initFuture;
  bool _initialized = false;
  bool _initFailed = false;
  final Dio _dio = Dio();

  // Serial ONNX queue
  Future<void> _queue = Future.value();

  // ── Initialisation ──────────────────────────────────────────────────────────

  /// Call once at app startup. Safe to call multiple times.
  Future<void> initialize() {
    _initFuture ??= _doInit();
    return _initFuture!;
  }

  Future<void> _doInit() async {
    // Set up disk cache directory in parallel with ONNX init
    await Future.wait([
      _initDiskCache(),
      _initOnnx(),
    ]);
  }

  Future<void> _initDiskCache() async {
    try {
      final base = await getApplicationCacheDirectory();
      _cacheDir = Directory('${base.path}/bg_removed');
      await _cacheDir!.create(recursive: true);
    } catch (_) {
      _cacheDir = null; // disk cache unavailable — fall back to mem-only
    }
  }

  Future<void> _initOnnx() async {
    try {
      await BackgroundRemover.instance.initializeOrt();
      _initialized = true;
    } catch (e) {
      _initFailed = true;
      // ignore: avoid_print
      print('[BgRemoverService] ONNX init failed: $e');
    }
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Removes the background from [imageSource] (network URL or asset path).
  /// Returns processed PNG bytes, or [null] on failure/unavailability.
  ///
  /// Lookup order:
  ///   1. L1 RAM cache   → instant, synchronous
  ///   2. L2 disk cache  → fast async read, runs IN PARALLEL (not queued)
  ///   3. ONNX inference → slow, serialised, result saved to both caches
  Future<td.Uint8List?> processImage(String imageSource) async {
    final key = imageSource.trim();
    if (key.isEmpty) return null;

    // L1 — RAM hit (synchronous)
    if (_memCache.containsKey(key)) return _memCache[key];

    // L2 — Disk hit (async but NOT queued, runs in parallel with other reads)
    final diskBytes = await _readFromDisk(key);
    if (diskBytes != null) {
      _memCache[key] = diskBytes;
      return diskBytes;
    }

    // L3 — ONNX inference (serialised to prevent concurrent GPU/ONNX jank)
    final result = Completer<td.Uint8List?>();
    _queue = _queue.then((_) async {
      if (result.isCompleted) return;
      result.complete(await _runOnnx(key));
    });
    return result.future;
  }

  /// Synchronously check if the image is already cached in RAM.
  /// Useful for widgets to skip the loading shimmer entirely on rebuild.
  td.Uint8List? getCached(String imageSource) =>
      _memCache[imageSource.trim()];

  Future<td.Uint8List?> _runOnnx(String key) async {
    // L1 re-check (another caller may have completed this while we waited)
    if (_memCache.containsKey(key)) return _memCache[key];

    // L2 re-check (race: another caller may have just written to disk)
    final diskBytes = await _readFromDisk(key);
    if (diskBytes != null) {
      _memCache[key] = diskBytes;
      return diskBytes;
    }

    // Wait for ONNX init to finish first
    if (_initFuture != null) {
      try {
        await _initFuture;
      } catch (_) {}
    }
    if (!_initialized || _initFailed) return null;

    try {
      final td.Uint8List rawBytes = await _fetchBytes(key);

      // Yield one frame so the shimmer can animate before heavy work starts
      await Future<void>.delayed(Duration.zero);

      final ui.Image processed =
          await BackgroundRemover.instance.removeBg(rawBytes);

      final td.ByteData? byteData =
          await processed.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final bytes = byteData.buffer.asUint8List();

      // Store in both caches
      _memCache[key] = bytes;
      await _writeToDisk(key, bytes);

      return bytes;
    } catch (e) {
      // ignore: avoid_print
      print('[BgRemoverService] processImage failed for "$key": $e');
      return null;
    }
  }

  // ── Disk cache helpers ──────────────────────────────────────────────────────

  /// Converts the image key into a safe filesystem filename.
  String _diskKey(String key) {
    // MD5 hash → short, filesystem-safe, unique filename
    final hash = md5.convert(key.codeUnits).toString();
    return '$hash.png';
  }

  Future<td.Uint8List?> _readFromDisk(String key) async {
    if (_cacheDir == null) return null;
    try {
      final file = File('${_cacheDir!.path}/${_diskKey(key)}');
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (_) {}
    return null;
  }

  Future<void> _writeToDisk(String key, td.Uint8List bytes) async {
    if (_cacheDir == null) return;
    try {
      final file = File('${_cacheDir!.path}/${_diskKey(key)}');
      await file.writeAsBytes(bytes, flush: true);
    } catch (_) {}
  }

  // ── Cache management ────────────────────────────────────────────────────────

  /// Clears only the in-memory cache. Disk cache is preserved.
  void clearMemoryCache() => _memCache.clear();

  /// Deletes the entire disk cache (frees storage).
  Future<void> clearDiskCache() async {
    if (_cacheDir == null) return;
    try {
      if (await _cacheDir!.exists()) {
        await _cacheDir!.delete(recursive: true);
        await _cacheDir!.create();
      }
    } catch (_) {}
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  void dispose() {
    BackgroundRemover.instance.dispose();
    _memCache.clear();
  }

  // ── Fetch helpers ───────────────────────────────────────────────────────────

  Future<td.Uint8List> _fetchBytes(String source) async {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      final response = await _dio.get<List<int>>(
        source,
        options: Options(responseType: ResponseType.bytes),
      );
      return td.Uint8List.fromList(response.data!);
    } else {
      final byteData = await rootBundle.load(source);
      return byteData.buffer.asUint8List();
    }
  }
}
