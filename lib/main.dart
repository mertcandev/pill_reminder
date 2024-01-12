import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pill_reminder/constants.dart';
import 'package:pill_reminder/global_bloc.dart';

import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'pages/home_page.dart';

void main() {
 
 
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalBloc? globalBloc;

  @override
  void initState() {
    globalBloc = GlobalBloc();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider<GlobalBloc>.value(
      value: globalBloc!,
      child: Sizer(builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pill Reminder',
          theme: ThemeData.dark().copyWith(
              primaryColor: kPrimaryColor,
              scaffoldBackgroundColor: kScaffoldColor,
              appBarTheme: AppBarTheme(
                  toolbarHeight: 7.h,
                  backgroundColor: kScaffoldColor,
                  elevation: 0,
                  iconTheme: IconThemeData(color: kSecondaryColor, size: 20.sp),
                  titleTextStyle: GoogleFonts.mulish(
                      color: kTextColor,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.normal,
                      fontSize: 16.sp)),
              textTheme: TextTheme(
                  headlineMedium: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w500,
                      color: kSecondaryColor),
                  headlineLarge: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: kTextColor),
                  displaySmall:
                      GoogleFonts.poppins(fontSize: 12.sp, color: kTextColor),
                  bodySmall: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w400,
                      color: kPrimaryColor),
                  labelMedium: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: kTextColor)),
              inputDecorationTheme: const InputDecorationTheme(
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: kTextLightColor, width: 0.7)),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: kTextLightColor,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor))),
              timePickerTheme: TimePickerThemeData(
                  backgroundColor: kScaffoldColor,
                  hourMinuteColor: kTextColor,
                  hourMinuteTextColor: kScaffoldColor,
                  dayPeriodColor: kTextColor,
                  dayPeriodTextColor: kScaffoldColor,
                  dialBackgroundColor: kTextColor,
                  dialHandColor: kPrimaryColor,
                  dialTextColor: kScaffoldColor,
                  entryModeIconColor: kOtherColor,
                  dayPeriodTextStyle: GoogleFonts.aBeeZee(fontSize: 8.sp))),
          home: const HomePage(),
        );
      }),
    );
  }
}
