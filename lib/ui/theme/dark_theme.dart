import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stopwatch/ui/theme/color.dart';

final appDarkTheme = ThemeData(brightness: Brightness.dark).copyWith(
  scaffoldBackgroundColor: AppColors.primaryColorDark,
  primaryColor: AppColors.primaryColor,
  primaryColorDark: AppColors.primaryColorDark,
  primaryColorLight: AppColors.primaryColorLight,
  colorScheme: ColorScheme.dark(
    primary: AppColors.white.withValues(alpha: 0.5),
    primaryContainer: AppColors.grey2,
    secondary: AppColors.green,
    secondaryContainer: AppColors.green2,
    surface: AppColors.primaryColorDark,
    onSurface: AppColors.blue1,
    error: AppColors.red,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
    bodyMedium: TextStyle(color: AppColors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
    bodySmall: TextStyle(color: AppColors.white, fontSize: 12.sp, fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(color: AppColors.white, fontSize: 50.sp, fontWeight: FontWeight.w500),
    headlineSmall: TextStyle(color: AppColors.white, fontSize: 18.sp, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(color: AppColors.white, fontSize: 24.sp, fontWeight: FontWeight.w500),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(AppColors.white),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.grey2;
        }
        return AppColors.primaryColor;
      }),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10).r)),
      iconColor: WidgetStatePropertyAll(AppColors.white),
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12, horizontal: 24).r),
      textStyle: WidgetStateProperty.all(TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
    ),
  ),
);
