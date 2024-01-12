import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pill_reminder/constants.dart';
import 'package:sizer/sizer.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2000), () {
      Navigator.popUntil(context, ModalRoute.withName("/"));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldColor,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.heartCircleCheck,
            color: kPrimaryColor,
            size: 25.h,
          ),
          SizedBox(height: 3.h),
          Text(
            "Medicine saved succesfully!",
            textAlign: TextAlign.center,
            style: GoogleFonts.aBeeZee(
                color: kPrimaryColor.withOpacity(0.8),
                fontWeight: FontWeight.w800,
                fontSize: 24),
          )
        ],
      )),
    );
  }
}
