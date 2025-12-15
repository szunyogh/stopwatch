import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stopwatch/ui/theme/color.dart';

final appLightTheme = ThemeData(brightness: Brightness.light).copyWith(
  scaffoldBackgroundColor: white,
  primaryColor: primaryColor,
  primaryColorDark: primaryColorDark,
  primaryColorLight: primaryColorLight,
  colorScheme: const ColorScheme.light(primary: primaryColor, primaryContainer: primaryColorLight, secondary: green, secondaryContainer: green2, surface: white, onSurface: blu2, error: red),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: black3, fontSize: 16.sp, fontWeight: FontWeight.w500),
    bodyMedium: TextStyle(color: black3, fontSize: 16.sp, fontWeight: FontWeight.w500),
    bodySmall: TextStyle(color: black400, fontSize: 12.sp, fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(color: black, fontSize: 50.sp, fontWeight: FontWeight.w500),
    headlineMedium: TextStyle(color: black, fontSize: 24.sp, fontWeight: FontWeight.w500),
    headlineSmall: TextStyle(color: black, fontSize: 18.sp, fontWeight: FontWeight.w700),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(white),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return grey2;
        }
        return primaryColor;
      }),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10).r)),
      iconColor: WidgetStatePropertyAll(white),
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12, horizontal: 24).r),
      textStyle: WidgetStateProperty.all(TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
    ),
  ),
);
