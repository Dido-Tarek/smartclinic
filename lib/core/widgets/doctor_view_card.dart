import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/services/bg_remover_service.dart';
import 'package:smartclinic/core/widgets/smart_clinic_loader.dart';

class DoctorViewCard extends StatefulWidget {
  final String doctorName;
  final String specialization;
  final String clinicName;
  final double rating;
  final String doctorImagePath;
  final int yearsOfExperience;
  final int patientsCount;
  final int reviewsCount;

  const DoctorViewCard({
    super.key,
    required this.doctorName,
    required this.specialization,
    required this.clinicName,
    required this.rating,
    required this.doctorImagePath,
    this.yearsOfExperience = 5,
    this.patientsCount = 500,
    this.reviewsCount = 0,
  });

  @override
  State<DoctorViewCard> createState() => _DoctorViewCardState();
}

class _DoctorViewCardState extends State<DoctorViewCard> {
  Uint8List? _processedImage;
  bool _bgProcessing = true;

  @override
  void initState() {
    super.initState();
    // L1 synchronous hit — no shimmer if already cached
    final cached =
        BgRemoverService.instance.getCached(widget.doctorImagePath);
    if (cached != null) {
      _processedImage = cached;
      _bgProcessing = false;
    } else {
      _removeBackground();
    }
  }

  @override
  void didUpdateWidget(DoctorViewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.doctorImagePath == widget.doctorImagePath) return;

    final cached =
        BgRemoverService.instance.getCached(widget.doctorImagePath);
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

  Future<void> _removeBackground() async {
    final result =
        await BgRemoverService.instance.processImage(widget.doctorImagePath);
    if (!mounted) return;
    setState(() {
      _processedImage = result;
      _bgProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageSource = widget.doctorImagePath.trim();
    final isNetworkImage =
        imageSource.startsWith('http://') || imageSource.startsWith('https://');
    final isLocalFile =
        imageSource.isNotEmpty && File(imageSource).existsSync();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Half-circle doctor image ──────────────────────────────────────
          ClipOval(
            child: ColoredBox(
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.centerRight,
                widthFactor: 0.70,
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: _buildDoctorImage(
                    imageSource: imageSource,
                    isNetworkImage: isNetworkImage,
                    isLocalFile: isLocalFile,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.doctorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.deepNavy,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.skyBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.specialization}  |  ${widget.clinicName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.yellowRating,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepNavy,
                          ),
                        ),
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
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _BadgeItem(
                            icon: Icons.emoji_events_outlined,
                            label: '+${widget.yearsOfExperience} Years EXP',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _BadgeItem(
                            icon: Icons.people_alt_outlined,
                            label: '+${widget.patientsCount} Patients',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorImage({
    required String imageSource,
    required bool isNetworkImage,
    required bool isLocalFile,
  }) {
    // ✅ FIX: When bg-removed image is ready, render ONLY Image.memory
    // — no original image underneath so transparent areas stay transparent
    if (_processedImage != null) {
      return Image.memory(
        _processedImage!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _originalImage(imageSource, isNetworkImage, isLocalFile),
      );
    }

    // While processing: show the original image with shimmer overlay
    return Stack(
      fit: StackFit.expand,
      children: [
        _originalImage(imageSource, isNetworkImage, isLocalFile),
        if (_bgProcessing)
          // SmartClinic branded loader while AI processes
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black26,
              child: SmartClinicLoader(size: 80),
            ),
          ),
      ],
    );
  }

  Widget _originalImage(
    String imageSource,
    bool isNetworkImage,
    bool isLocalFile,
  ) {
    if (isNetworkImage) {
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset(widget.doctorImagePath, fit: BoxFit.cover),
      );
    }
    if (isLocalFile) {
      return Image.file(File(imageSource), fit: BoxFit.cover);
    }
    return Image.asset(
      widget.doctorImagePath,
      fit: BoxFit.cover,
    );
  }
}

// ── Badge widget ───────────────────────────────────────────────────────────────
class _BadgeItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BadgeItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.skyBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.skyBlue, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.skyBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
