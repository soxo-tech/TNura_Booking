// ignore_for_file: prefer_const_constructors

import 'package:booking/core/colors.dart';
import 'package:flutter/material.dart';

/// A custom button widget that displays a label and shows a loading indicator when needed.
class RefractedButton extends StatelessWidget {
  /// Background color of the button. Defaults to [AppColors.buttonBlue] if not provided.
  final Color? backGroundColor;

  /// Color of the text on the button. Defaults to white if not provided.
  final Color textColor;

  /// The label text displayed on the button.
  final String label;

  /// Callback function to be executed when the button is pressed.
  final Function()? onTap;

  /// Indicates whether the button is in a loading state.
  final bool isLoading;

  /// Height of the button. Defaults to 40 if not provided.
  final double height;

  /// Font size of the button's label. Defaults to 14 if not provided.
  final double fontSize;

  /// Font Weight of the button's label
  final dynamic fontWeight;

  /// Creates a [RefractedButton] with the provided parameters.
  const RefractedButton({
    super.key,
    this.backGroundColor,
    required this.label,
    this.onTap,
    this.textColor = Colors.white,
    this.isLoading = false,
    this.height = 40,
    this.fontSize = 14,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(1),
          shadowColor: const WidgetStatePropertyAll(Colors.white),
          backgroundColor: WidgetStateProperty.all(
            backGroundColor ?? AppColors.buttonBlue,
          ),
        ),
        onPressed: () {
          if (isLoading) {
            return;
          }
          onTap?.call();
        },
        child: AnimatedCrossFade(
          firstChild: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
          secondChild: const Loader(),
          crossFadeState:
              isLoading ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }
}

/// A simple circular progress indicator used as a loading spinner.
class Loader extends StatelessWidget {
  /// Scale of the loader indicator. Defaults to 0.75.
  final double scale;

  /// Creates a [Loader] with the provided scale.
  const Loader({super.key, this.scale = 0.75});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: CircularProgressIndicator(
        color: Color(0xFFF8BF40),
        backgroundColor: Colors.white,
      ),
    );
  }
}
