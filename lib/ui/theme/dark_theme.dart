import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stopwatch/ui/theme/color.dart';

final appDarkTheme = ThemeData(brightness: Brightness.dark).copyWith(
  scaffoldBackgroundColor: primaryColorDark,
  primaryColor: primaryColor,
  primaryColorDark: primaryColorDark,
  primaryColorLight: primaryColorLight,
  colorScheme: ColorScheme.dark(
    primary: white.withOpacity(.5),
    primaryContainer: primaryColorLight,
    secondary: green,
    secondaryContainer: green2,
    surface: primaryColorDark,
    background: primaryColorDark,
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
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(white),
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 15, horizontal: 24).r),
      textStyle: WidgetStateProperty.all(TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
    ),
  ),
  iconTheme: IconThemeData(color: primaryColorLight),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(white),
      maximumSize: WidgetStateProperty.all(Size(54.w, 54.w)),
      padding: WidgetStateProperty.all(const EdgeInsets.all(16).r),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50).r)),
    ),
  ),
  dividerTheme: DividerThemeData(color: white.withOpacity(.2)),
  drawerTheme: DrawerThemeData(
    backgroundColor: Colors.transparent,
    elevation: 0,
    shape: Border(right: BorderSide(color: white.withOpacity(0.1))),
  ),
  canvasColor: grey,
  popupMenuTheme: PopupMenuThemeData(
    elevation: 3,
    shadowColor: grey.withOpacity(.2),
  ),
  checkboxTheme: CheckboxThemeData(
    checkColor: WidgetStateProperty.all(blu3),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5).r),
    side: const BorderSide(color: blu3),
  ),
  inputDecorationTheme: InputDecorationTheme(
    isDense: true,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16).r,
    hintStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: blu2),
    floatingLabelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: blu2),
    labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: blu2),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30).r,
      borderSide: const BorderSide(color: black400),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30).r,
      borderSide: const BorderSide(color: black400),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30).r,
      borderSide: const BorderSide(color: black400),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30).r,
      borderSide: const BorderSide(color: black400),
    ),
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: blue5,
    dayStyle: TextStyle(color: white, fontSize: 11.sp, fontWeight: FontWeight.w500),
    headerBackgroundColor: blue5,
    headerForegroundColor: white,
    yearStyle: TextStyle(color: white, fontSize: 15.sp, fontWeight: FontWeight.w500),
    headerHeadlineStyle: TextStyle(color: white, fontSize: 16.sp, fontWeight: FontWeight.w500),
    rangePickerHeaderHeadlineStyle: TextStyle(color: white, fontSize: 5.sp, fontWeight: FontWeight.w500),
    weekdayStyle: TextStyle(color: white, fontSize: 14.sp, fontWeight: FontWeight.w500),
    surfaceTintColor: white.withOpacity(.2),
    dayOverlayColor: WidgetStatePropertyAll(white.withOpacity(.1)),
    todayBackgroundColor: WidgetStatePropertyAll(white.withOpacity(.1)),
    todayBorder: BorderSide.none,
    todayForegroundColor: WidgetStatePropertyAll(white),
    confirmButtonStyle: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(white),
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 15, horizontal: 24).r),
      textStyle: WidgetStateProperty.all(TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
    ),
    cancelButtonStyle: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(white),
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 15, horizontal: 24).r),
      textStyle: WidgetStateProperty.all(TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
    ),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: primaryColorDark,
    elevation: 3,
    insetPadding: EdgeInsets.zero,
    actionsPadding: EdgeInsets.fromLTRB(15, 10, 15, 20).r,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14).r, side: BorderSide.none),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: white,
    inactiveTrackColor: white.withOpacity(.2),
    thumbColor: white,
    trackHeight: 4.h,
    trackShape: const RoundedRectSliderTrackShape(),
    overlayColor: white.withOpacity(.2),
    valueIndicatorColor: white.withOpacity(.2),
  ),
);
