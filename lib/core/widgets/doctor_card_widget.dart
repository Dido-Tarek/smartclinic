import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/services/bg_remover_service.dart';
import 'package:smartclinic/core/widgets/smart_clinic_loader.dart';

class DoctorCardWidget extends StatefulWidget {
  final String doctorName;
  final String specialization;
  final double rating;
  final int? reviewsCount;
  final double? consultationPrice;
  final String imagePath;
  final String? imageUrl;
  final VoidCallback onTap;
  final Function(bool) onFavoriteChanged;
  final bool isInitialFavorite;

  const DoctorCardWidget({
    super.key,
    required this.doctorName,
    required this.specialization,
    required this.rating,
    this.reviewsCount,
    this.consultationPrice,
    required this.imagePath,
    this.imageUrl,
    required this.onTap,
    required this.onFavoriteChanged,
    this.isInitialFavorite = false,
  });

  @override
  State<DoctorCardWidget> createState() => _DoctorCardWidgetState();
}

class _DoctorCardWidgetState extends State<DoctorCardWidget> {
  late bool isFavorite;
  Uint8List? _processedImage;
  bool _bgProcessing = true;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isInitialFavorite;
    // L1 synchronous hit — if already cached, show instantly (no shimmer)
    final src = _effectiveSource(widget.imageUrl, widget.imagePath);
    final cached = BgRemoverService.instance.getCached(src);
    if (cached != null) {
      _processedImage = cached;
      _bgProcessing = false;
    } else {
      _removeBackground();
    }
  }

  @override
  void didUpdateWidget(DoctorCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldSrc = _effectiveSource(oldWidget.imageUrl, oldWidget.imagePath);
    final newSrc = _effectiveSource(widget.imageUrl, widget.imagePath);
    if (oldSrc == newSrc) return; // same image — nothing to do

    // Check L1 first before triggering async work
    final cached = BgRemoverService.instance.getCached(newSrc);
    if (cached != null) {
      setState(() {
        _processedImage = cached;
        _bgProcessing = false;
      });
    } else {
      setState(() {
        _processedImage = null;
        _bgProcessing = true;
      });
      _removeBackground();
    }
  }

  String _effectiveSource(String? url, String path) =>
      (url != null && url.trim().isNotEmpty) ? url.trim() : path.trim();

  Future<void> _removeBackground() async {
    final src = _effectiveSource(widget.imageUrl, widget.imagePath);
    final result = await BgRemoverService.instance.processImage(src);
    if (!mounted) return;
    setState(() {
      _processedImage = result;
      _bgProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.doctorName.trim().startsWith('Dr.')
        ? widget.doctorName.trim()
        : 'Dr. ${widget.doctorName.trim()}';
    final fallbackAsset = AppImages.imagesDoctorDRMaiElKady;
    final imageSource = _effectiveSource(widget.imageUrl, widget.imagePath);
    final isNetworkImage =
        imageSource.startsWith('http://') || imageSource.startsWith('https://');
    final isLocalFile =
        imageSource.isNotEmpty && File(imageSource).existsSync();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Doctor image area ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(
                  color: AppColors.deepNavy.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(12),
                ),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  // ✅ FIX: render ONLY the processed image when available.
                  // Never put the original behind it — that would show through
                  // the transparent areas and make it look unchanged.
                  child: _processedImage != null
                      ? Image.memory(
                          _processedImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _originalImage(
                            imageSource: imageSource,
                            isNetworkImage: isNetworkImage,
                            isLocalFile: isLocalFile,
                            fallbackAsset: fallbackAsset,
                          ),
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            _originalImage(
                              imageSource: imageSource,
                              isNetworkImage: isNetworkImage,
                              isLocalFile: isLocalFile,
                              fallbackAsset: fallbackAsset,
                            ),
                            if (_bgProcessing)
                              // SmartClinic branded loader while AI processes
                              const Positioned.fill(
                                child: ColoredBox(
                                  color: Colors.black26,
                                  child: SmartClinicLoader(size: 80),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Rating row ─────────────────────────────────────────────────
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: AppColors.yellowRating,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.darkSlate,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.reviewsCount != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    '(${widget.reviewsCount} reviews)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.darkSlate,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Favourite + specialization ──────────────────────────────────
            Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() => isFavorite = !isFavorite);
                    widget.onFavoriteChanged(isFavorite);
                  },
                  child: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite ? AppColors.error : AppColors.darkSlate,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.specialization,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grayText,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            if (widget.consultationPrice != null) ...[
              const SizedBox(height: 8),
              Text(
                '${widget.consultationPrice!.toStringAsFixed(0)} EGP',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _originalImage({
    required String imageSource,
    required bool isNetworkImage,
    required bool isLocalFile,
    required String fallbackAsset,
  }) {
    if (isNetworkImage) {
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset(fallbackAsset, fit: BoxFit.cover),
      );
    }
    if (isLocalFile) {
      return Image.file(File(imageSource), fit: BoxFit.cover);
    }
    return Image.asset(
      imageSource.isNotEmpty ? imageSource : fallbackAsset,
      fit: BoxFit.cover,
    );
  }
}
