import 'package:flutter/material.dart';
import '../../core/colors.dart';

/// A custom text widget with additional styling options.
///
/// This widget allows customization of text appearance including font size, color, decoration, and alignment.
class RefractedText extends StatelessWidget {
  /// The text to display.
  final String text;

  /// The font size of the text. Defaults to 16 if not provided.
  final double fontSize;

  /// The color of the text. Defaults to [AppColors.primaryLight] if not provided.
  final Color? textColor;

  /// The decoration of the text, such as underline or line-through.
  final TextDecoration? decoration;

  /// The color of the text decoration.
  final Color? decorationColor;

  /// The height of the text, which affects line spacing.
  final double? height;

  /// The alignment of the text within its container.
  final TextAlign? textAlign;

  /// The maximum number of lines to display. If null, the text will not be limited in height.
  final int? maxLines;

  /// The weight of the text, affecting its thickness. Defaults to [FontWeight.w600] if not provided.
  final FontWeight fontWeight;
  final TextOverflow? overflow;

  /// Creates a [RefractedText] with the provided parameters.
  const RefractedText({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.textColor,
    this.decoration,
    this.decorationColor,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      style: TextStyle(
        height: height,
        decoration: decoration,
        decorationColor: decorationColor,
        overflow: overflow,
        color: textColor ?? AppColors.primaryLight,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
      ),
    );
  }
}
