import 'package:booking/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppointmentHistoryShimmer extends StatelessWidget {
  const AppointmentHistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      itemCount: 6, 
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.backgroundBlueLight,
          highlightColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                // Image box shimmer
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                const SizedBox(width: 12),

                // Text shimmer
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 10,
                        width: 120,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 10,
                        width: 180,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 10,
                        width: 140,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}