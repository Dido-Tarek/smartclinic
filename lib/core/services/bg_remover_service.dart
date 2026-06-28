import 'dart:async';
import 'dart:typed_data' as td;
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:image_background_remover/image_background_remover.dart';

/// Singleton service that wraps [BackgroundRemover] with:
/// - One-time ONNX initialisation (awaitable from callers)
/// - Serial processing queue  → only 1 ONNX job at a time, prevents UI jank
/// - In-memory cache keyed by image source (URL or asset path)
/// - Graceful fallback on any error
class BgRemoverService {
  BgRemoverService._();
  static final BgRemoverService instance = BgRemoverService._();

  final Map<String, td.Uint8List> _cache = {};
  Future<void>? _initFuture;
  bool _initialized = false;
  bool _initFailed = false;
  final Dio _dio = Dio();

  // Serial queue: each new job chains onto the previous one so ONNX
  // never runs two inferences concurrently (which causes compound UI freeze).
  Future<void> _queue = Future.value();

  // ── Initialisation ─────────────────────────────────────────────────────────

  /// Call once at app startup. Safe to call multiple times.
  Future<void> initialize() {
    _initFuture ??= _doInit();
    return _initFuture!;
  }

  Future<void> _doInit() async {
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
  /// Returns processed PNG bytes, or [null] on failure.
  ///
  /// Jobs are serialised — only one ONNX inference runs at a time.
  /// Results are cached so the same image is never processed twice.
  Future<td.Uint8List?> processImage(String imageSource) {
    final key = imageSource.trim();
    if (key.isEmpty) return Future.value(null);

    // Serve from cache without touching the queue
    if (_cache.containsKey(key)) return Future.value(_cache[key]);

    // Chain this job onto the serial queue
    final result = Completer<td.Uint8List?>();
    _queue = _queue.then((_) async {
      if (result.isCompleted) return; // widget was disposed already
      result.complete(await _processOne(key));
    });
    return result.future;
  }

  Future<td.Uint8List?> _processOne(String key) async {
    // Re-check cache (another caller may have processed it while we waited)
    if (_cache.containsKey(key)) return _cache[key];

    // Wait for ONNX init if still in progress
    if (_initFuture != null) {
      try {
        await _initFuture;
      } catch (_) {}
    }
    if (!_initialized || _initFailed) return null;

    try {
      final td.Uint8List rawBytes = await _fetchBytes(key);

      // Yield one frame so the shimmer can animate before the heavy work
      await Future<void>.delayed(Duration.zero);

      final ui.Image result =
          await BackgroundRemover.instance.removeBg(rawBytes);

      final td.ByteData? byteData =
          await result.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final processed = byteData.buffer.asUint8List();
      _cache[key] = processed;
      return processed;
    } catch (e) {
      // ignore: avoid_print
      print('[BgRemoverService] processImage failed for "$key": $e');
      return null;
    }
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  void dispose() {
    BackgroundRemover.instance.dispose();
    _cache.clear();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

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
