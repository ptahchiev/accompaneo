import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static const textFormFieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: Colors.grey, width: 1.6),
  );

  static final ThemeData themeData = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.primaryColor,
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: 34,
        letterSpacing: 0.5,
      ),
      bodySmall: TextStyle(
        color: Colors.grey,
        fontSize: 14,
        letterSpacing: 0.5,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,
      errorStyle: TextStyle(fontSize: 12),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 14,
      ),
      border: textFormFieldBorder,
      errorBorder: textFormFieldBorder,
      focusedBorder: textFormFieldBorder,
      focusedErrorBorder: textFormFieldBorder,
      enabledBorder: textFormFieldBorder,
      labelStyle: TextStyle(
        fontSize: 17,
        color: Colors.grey,
        fontWeight: FontWeight.w500,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.all(4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(color: Colors.grey.shade200),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: AppColors.primaryColor,
        disabledBackgroundColor: Colors.grey.shade300,
        minimumSize: const Size(double.infinity, 52),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: Colors.amber,
      inactiveTrackColor: Colors.grey,
      thumbColor: AppColors.primaryColor,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 18),
      overlayColor: Colors.indigo.withOpacity(0.18),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
      activeTickMarkColor: AppColors.primaryColor,
      inactiveTickMarkColor: Colors.white,
      trackHeight: 11,
      valueIndicatorColor: AppColors.primaryColor,
      valueIndicatorTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold
      )

    )
  );

  static BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  static const TextStyle titleLarge = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 34,
    letterSpacing: 0.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 29,
    letterSpacing: 0.5,
  );


  static const TextStyle bodySmall = TextStyle(
    color: Colors.grey,
    letterSpacing: 0.5,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontSize: 24,
    letterSpacing: 0.5,
  );

  static const TextStyle heroCardTitle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 20,
    letterSpacing: 0.5,
  );
}