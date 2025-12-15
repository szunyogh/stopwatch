import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stopwatch/ui/theme/color.dart';

final appDarkTheme = ThemeData(brightness: Brightness.dark).copyWith(
  scaffoldBackgroundColor: primaryColorDark,
  primaryColor: primaryColor,
  primaryColorDark: primaryColorDark,
  primaryColorLight: primaryColorLight,
  colorScheme: ColorScheme.dark(
    primary: white.withValues(alpha: 0.5),
    primaryContainer: grey2,
    secondary: green,
    secondaryContainer: green2,
    surface: primaryColorDark,
    onSurface: blue1,
    error: red,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: white, fontSize: 16.sp, fontWeight: FontWeight.w500),
    bodyMedium: TextStyle(color: white, fontSize: 16.sp, fontWeight: FontWeight.w500),
    bodySmall: TextStyle(color: white, fontSize: 12.sp, fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(color: white, fontSize: 50.sp, fontWeight: FontWeight.w500),
    headlineSmall: TextStyle(color: white, fontSize: 18.sp, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(color: white, fontSize: 24.sp, fontWeight: FontWeight.w500),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(white),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return grey;
        }
        return primaryColor;
      }),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10).r),
      ),
      iconColor: WidgetStatePropertyAll(white),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(vertical: 12, horizontal: 24).r,
      ),
      textStyle: WidgetStateProperty.all(
        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
      ),
    ),
  ),
);
