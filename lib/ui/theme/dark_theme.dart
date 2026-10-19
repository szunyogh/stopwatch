import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stopwatch/ui/theme/color.dart';

final appDarkTheme = ThemeData(brightness: Brightness.dark).copyWith(
  scaffoldBackgroundColor: AppColors.primaryColorDark,
  primaryColor: AppColors.blue,
  primaryColorDark: AppColors.primaryColorDark,
  primaryColorLight: AppColors.primaryColorLight,
  cardColor: AppColors.darkCard,
  colorScheme: ColorScheme.dark(
    primary: AppColors.white,
    primaryContainer: AppColors.black2,
    secondary: AppColors.green,
    secondaryContainer: AppColors.green2,
    surface: AppColors.darkCard,
    onSurface: AppColors.white,
    onSurfaceVariant: AppColors.blue2,
    shadow: AppColors.black,
    error: AppColors.red,
  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: AppColors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
    bodySmall: TextStyle(color: AppColors.blue2, fontSize: 12.sp, fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(color: AppColors.white, fontSize: 50.sp, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(color: AppColors.white.withValues(alpha: .7), fontSize: 24.sp, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(color: AppColors.white, fontSize: 18.sp, fontWeight: FontWeight.w700),
    displayLarge: TextStyle(color: AppColors.white, fontSize: 55.sp, fontWeight: FontWeight.w700),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(AppColors.white),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.white.withValues(alpha: 0.3);
        }
        return AppColors.blue;
      }),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10).r)),
      iconColor: WidgetStatePropertyAll(AppColors.white),
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12, horizontal: 24).r),
      textStyle: WidgetStateProperty.all(TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(foregroundColor: WidgetStateProperty.all(AppColors.white), backgroundColor: WidgetStateProperty.all(AppColors.blue2.withValues(alpha: .2))),
  ),
);
