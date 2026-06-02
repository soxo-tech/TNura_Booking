import 'package:booking/core/colors.dart';
import 'package:booking/widgets/refracted_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class StackedLoader extends StatelessWidget {
  const StackedLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black38,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Loader(),
                  const SizedBox(width: 20),
                  Text(
                    "Please Wait...".tr(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
