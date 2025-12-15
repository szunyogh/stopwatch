import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stopwatch/ui/theme/color.dart';

final appLightTheme = ThemeData(brightness: Brightness.light).copyWith(
  scaffoldBackgroundColor: white,
  primaryColor: primaryColor,
  primaryColorDark: primaryColorDark,
  primaryColorLight: primaryColorLight,
  colorScheme: const ColorScheme.light(
    primary: primaryColor,
    primaryContainer: primaryColorLight,
    secondary: green,
    secondaryContainer: green2,
    surface: white,
    background: white,
    error: red,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: black3, fontSize: 16.sp, fontWeight: FontWeight.w500),
    bodyMedium: TextStyle(color: black3, fontSize: 16.sp, fontWeight: FontWeight.w500),
    bodySmall: TextStyle(color: black400, fontSize: 12.sp, fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(color: black, fontSize: 32.sp, fontWeight: FontWeight.w500),
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
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(primaryColor),
      side: WidgetStateProperty.all(const BorderSide(color: primaryColor)),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(vertical: 15, horizontal: 24).r,
      ),
      textStyle: WidgetStateProperty.all(
        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
      ),
    ),
  ),
  iconTheme: const IconThemeData(color: primaryColor),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(primaryColor),
      maximumSize: WidgetStateProperty.all(Size(54.w, 54.w)),
      padding: WidgetStateProperty.all(const EdgeInsets.all(16).r),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(50).r),
      ),
    ),
  ),
  dividerTheme: DividerThemeData(color: black.withOpacity(.1)),
  drawerTheme: DrawerThemeData(
    backgroundColor: white,
    elevation: 0,
    shape: Border(right: BorderSide(color: black.withOpacity(0.1))),
  ),
  canvasColor: primaryColorLight,
  popupMenuTheme: PopupMenuThemeData(
    elevation: 3,
    shadowColor: black.withOpacity(.15),
    color: white,
  ),
  checkboxTheme: CheckboxThemeData(
    checkColor: WidgetStateProperty.all(white),
    fillColor: WidgetStateProperty.all(primaryColor),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5).r),
    side: const BorderSide(color: primaryColor),
  ),
  inputDecorationTheme: InputDecorationTheme(
    isDense: true,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16).r,
    hintStyle: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: grey,
    ),
    floatingLabelStyle: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: primaryColor,
    ),
    labelStyle: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: grey,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30).r,
      borderSide: const BorderSide(color: grey2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30).r,
      borderSide: const BorderSide(color: grey2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30).r,
      borderSide: const BorderSide(color: primaryColor),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30).r,
      borderSide: const BorderSide(color: grey2),
    ),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: white,
    elevation: 3,
    insetPadding: EdgeInsets.zero,
    actionsPadding: EdgeInsets.fromLTRB(15, 10, 15, 20).r,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14).r,
    ),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: primaryColor,
    inactiveTrackColor: primaryColor.withOpacity(.2),
    thumbColor: primaryColor,
    trackHeight: 4.h,
    trackShape: const RoundedRectSliderTrackShape(),
    overlayColor: primaryColor.withOpacity(.15),
    valueIndicatorColor: primaryColor.withOpacity(.2),
  ),
);
