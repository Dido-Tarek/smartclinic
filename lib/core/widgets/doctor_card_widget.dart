import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';

class DoctorCardWidget extends StatefulWidget {
  final String doctorName;
  final String specialization;
  final double rating;
  final int? reviewsCount;
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

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isInitialFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.doctorName.trim().startsWith('Dr.')
      ? widget.doctorName.trim()
      : 'Dr. ${widget.doctorName.trim()}';
    final displayRating = widget.reviewsCount != null &&
        widget.reviewsCount! > 0
      ? (widget.reviewsCount! / 100).clamp(0.0, 5.0).toDouble()
      : widget.rating;
    final imageSource = (widget.imageUrl ?? widget.imagePath).trim();
    final isNetworkImage = imageSource.startsWith('http://') ||
      imageSource.startsWith('https://') ||
      (widget.imageUrl != null &&
        widget.imageUrl!.trim().isNotEmpty &&
        !imageSource.startsWith('assets/'));

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
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                ),
                border: Border.all(
                  color: AppColors.deepNavy.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                ),
                child: SizedBox(
                  height: 160, // fixed image area height
                  width: double.infinity,
                  child: isNetworkImage
                      ? Image.network(
                          imageSource.startsWith('http')
                              ? imageSource
                              : 'http://smartclinicccc.runasp.net/$imageSource',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            widget.imagePath,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(widget.imagePath, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: AppColors.yellowRating,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  displayRating.toStringAsFixed(1),
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

            Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
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
          ],
        ),
      ),
    );
  }
}
