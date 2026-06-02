import 'package:booking/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A widget that displays a shimmer effect for a report loading view.
///
/// The [PackagesShimmer] widget is used to show a placeholder while the report data is loading.
/// It consists of a series of shimmer effects that mimic the loading state of various UI elements.
///
/// The widget includes:
/// - A header shimmer effect for text.
/// - A row of shimmer circles to represent loading indicators.
/// - A list of shimmer containers to represent loading list items.
///
/// The layout and appearance of the shimmer effect are defined by the child widgets: [TextShimmer] and [SimmerCircle].

class PackagesShimmer extends StatelessWidget {
  const PackagesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundBlueLight,
      highlightColor: Colors.white,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 1. Location Bar Shimmer
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.backgroundBlueLight,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Package Cards Shimmer
              _buildCardShimmer(),
              const SizedBox(height: 20),
              _buildCardShimmer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardShimmer() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundBlueLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Area Placeholder
          Container(
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.backgroundBlueLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Container(
                    width: 200,
                    height: 18,
                    color: AppColors.backgroundBlueLight),
                const SizedBox(height: 10),
                // Price
                Container(
                    width: 80,
                    height: 16,
                    color: AppColors.backgroundBlueLight),
                const SizedBox(height: 15),
                // Description lines
                Container(
                    width: double.infinity,
                    height: 12,
                    color: AppColors.backgroundBlueLight),
                const SizedBox(height: 6),
                Container(
                    width: double.infinity,
                    height: 12,
                    color: AppColors.backgroundBlueLight),
                const SizedBox(height: 15),
                // "Learn More" align right
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                      width: 80,
                      height: 14,
                      color: AppColors.backgroundBlueLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget that displays a shimmer effect for text placeholders.
///
/// The [TextShimmer] widget is used to show a shimmer effect for text areas while data is loading.
/// It consists of two placeholder containers with a shimmer effect to mimic text loading.
///
/// The layout and appearance of the shimmer effect are defined by the size and margins of the containers.

class TextShimmer extends StatelessWidget {
  const TextShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:
          AppColors.backgroundBlueLight, // Base color for shimmer effect.
      highlightColor: Colors.white, // Highlight color for shimmer effect.
      child: Column(
        children: [
          Container(
            height: 15, // Height of the shimmer text placeholder.
            color: AppColors
                .backgroundBlueLight, // Background color of shimmer text placeholder.
            margin: const EdgeInsets.fromLTRB(
              20,
              0,
              100,
              0,
            ), // Margin around the shimmer text placeholder.
          ),
          Container(
            height: 15, // Height of the shimmer text placeholder.
            color: AppColors
                .backgroundBlueLight, // Background color of shimmer text placeholder.
            margin: const EdgeInsets.fromLTRB(
              20,
              10,
              200,
              0,
            ), // Margin around the shimmer text placeholder.
          ),
        ],
      ),
    );
  }
}

/// A widget that displays a shimmer effect for circular placeholders.
///
/// The [SimmerCircle] widget is used to show a shimmer effect for circular placeholders, typically used
/// to represent loading profile pictures or icons.
///
/// The layout and appearance of the shimmer effect are defined by the size and shape of the circular container.

class SimmerCircle extends StatelessWidget {
  const SimmerCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:
          AppColors.backgroundBlueLight, // Base color for shimmer effect.
      highlightColor: Colors.white, // Highlight color for shimmer effect.
      child: Container(
        height: 60, // Height of the shimmer circle.
        width: 60, // Width of the shimmer circle.
        margin: const EdgeInsets.only(
          right: 10,
        ), // Margin around the shimmer circle.
        decoration: const BoxDecoration(
          color: AppColors
              .backgroundBlueLight, // Background color of shimmer circle.
          shape: BoxShape.circle, // Shape of the shimmer circle.
        ),
      ),
    );
  }
}
