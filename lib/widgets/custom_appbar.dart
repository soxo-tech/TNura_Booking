import 'package:booking/widgets/refracted_text.dart';
import 'package:flutter/material.dart';

import '../../core/colors.dart';

//A customised nappbar widget with named params for more customization
AppBar customAppBar({
  String? title,
  List<Widget>? actions,
  Widget? leading,
  double elevation = 4,
  VoidCallback? onBack,
  double leadingWidth = 55,
  required BuildContext context,
}) {
  return AppBar(
    centerTitle: true,
    elevation: elevation,
    leading:
        leading ??
        IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
    backgroundColor: AppColors.backgroundBlueLight,
    foregroundColor: AppColors.primaryDark,
    shadowColor: const Color.fromARGB(57, 0, 0, 0),
    automaticallyImplyLeading: true,
    leadingWidth: leadingWidth,
    titleTextStyle: const TextStyle(fontSize: 18, color: AppColors.primaryDark),
    title: RefractedText(
      text: title ?? "",
      fontSize: 18,
      textColor: AppColors.primaryDark,
    ),
    actions: actions,
  );
}
