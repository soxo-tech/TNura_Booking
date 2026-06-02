// ignore_for_file: prefer_const_constructors

import 'package:booking/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GuestsTextfield extends StatefulWidget {
  ///
  /// This widget provides a styled text field with a border, padding, and an optional hint.
  /// It also supports real-time text updates through the [onChanged] callback.
  ///

  ///  Controller to manage the text input.
  final TextEditingController controller;

  /// Defines the height of the text field. Default is `42`.
  final double? textFieldSize;

  /// The hint text displayed when the field is empty.
  final String? hintText;

  ///The label text
  final String? labelText;

  /// The border color of the text field.
  final Color? textfieldBorderColor;

  /// The KeyboardType of the TextField
  final TextInputType? keyboardType;

  /// Callback triggered when the text input changes.
  final ValueChanged<String>? onChanged;

  /// Callback triggered when the text input changes.

  final GestureTapCallback? onTap;

  final int? maxLength;
  final Widget? suffixIcon;
  final bool? otpVerified;
 final TextCapitalization textCapitalization;
 final List<TextInputFormatter>? inputFormatters;
  const GuestsTextfield({
    super.key,
    required this.controller,
    this.textFieldSize = 42,
    this.hintText,
    this.labelText,
    this.textfieldBorderColor,
    this.onChanged,
    this.keyboardType,
    this.onTap,
    this.maxLength,
    this.suffixIcon,
    this.otpVerified,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  State<GuestsTextfield> createState() => _GuestsTextfieldState();
}

class _GuestsTextfieldState extends State<GuestsTextfield> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters: widget.inputFormatters,
      maxLength: widget.maxLength,
      onTap: widget.onTap,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.packageTextPrimary,
      ),
      controller: widget.controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.white,
        hintText: widget.labelText,
        hintStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textFieldHintColor,
        ),
        suffixIcon:
            widget.otpVerified != null && widget.controller.text.isNotEmpty
                ? Icon(
                    Icons.check_circle_outline,
                    color: widget.otpVerified == true
                        ? Colors.green
                        : AppColors.textFieldHintColor,
                  )
                : null,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: widget.otpVerified == true
                ? Colors.green
                : widget.textfieldBorderColor!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: widget.textfieldBorderColor!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.textfieldBorderColor!),
        ),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        counterText: "", // hide character count
      ),
      onChanged: widget.onChanged,
    );
  }
}
