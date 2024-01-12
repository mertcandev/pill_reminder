import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pill_reminder/constants.dart';
import 'package:pill_reminder/global_bloc.dart';
import 'package:provider/provider.dart';

import 'package:sizer/sizer.dart';

import '../../models/medicine.dart';

class MedicineDetails extends StatefulWidget {
  const MedicineDetails({super.key, required this.medicine});
  final Medicine medicine;

  @override
  State<MedicineDetails> createState() => _MedicineDetailsState();
}

class _MedicineDetailsState extends State<MedicineDetails> {
  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Details"),
      ),
      body: Padding(
        padding: EdgeInsets.all(2.h),
        child: Column(
          children: [
            MainSection(
              medicine: widget.medicine,
            ),
            ExtendedSection(
              medicine: widget.medicine,
            ),
            const Spacer(),
            SizedBox(
              width: 100.w,
              height: 7.h,
              child: TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: kSecondaryColor,
                      shape: const StadiumBorder()),
                  onPressed: () {
                    openAlertBox(context, globalBloc);
                  },
                  child: Text(
                    "Delete",
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium!
                        .copyWith(color: Colors.white),
                  )),
            ),
            SizedBox(height: 2.h)
          ],
        ),
      ),
    );
  }

  openAlertBox(BuildContext context, GlobalBloc globalBloc) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(top: 1.h),
          backgroundColor: kScaffoldColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          title: Text("Delete This Reminder?",
              style: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .copyWith(color: kTextColor)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: Theme.of(context)
                    .textTheme
                    .labelSmall!
                    .copyWith(color: kTextLightColor),
              ),
            ),
            TextButton(
              onPressed: () {
                globalBloc.removeMedicine(widget.medicine);
                Navigator.popUntil(context, ModalRoute.withName("/"));
              },
              child: Text(
                "Confirm",
                style: Theme.of(context)
                    .textTheme
                    .labelSmall!
                    .copyWith(color: kSecondaryColor),
              ),
            )
          ],
        );
      },
    );
  }
}

class ExtendedSection extends StatelessWidget {
  const ExtendedSection({super.key, this.medicine});
  final Medicine? medicine;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        ExtendedInfoTab(
            fieldTitle: "Medicine Type",
            fieldInfo: medicine!.medicineType! == "None"
                ? "Not Specified"
                : medicine!.medicineType!),
        ExtendedInfoTab(
            fieldTitle: "Dose Interval",
            fieldInfo:
                "Every ${medicine!.interval} hours | ${medicine!.interval == 24 ? "One time a day" : "${(24 / medicine!.interval!).floor()} times a day "}"),
        ExtendedInfoTab(
            fieldTitle: "Start Time",
            fieldInfo:
                '${medicine!.startTime![0]}${medicine!.startTime![1]}:${medicine!.startTime![2]}${medicine!.startTime![3]}')
      ],
    );
  }
}

class ExtendedInfoTab extends StatelessWidget {
  const ExtendedInfoTab(
      {super.key, required this.fieldTitle, required this.fieldInfo});
  final String fieldTitle;
  final String fieldInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fieldTitle,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Text(
            fieldInfo,
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(color: kSecondaryColor),
          )
        ],
      ),
    );
  }
}

class MainSection extends StatelessWidget {
  const MainSection({super.key, required this.medicine});
  final Medicine? medicine;
  Hero makeIcon() {
    if (medicine!.medicineType == "Bottle") {
      return Hero(
        tag: medicine!.medicineName! + medicine!.medicineType!,
        child: Icon(
          FontAwesomeIcons.bottleDroplet,
          color: kPrimaryColor,
          size: 7.h,
        ),
      );
    } else if (medicine!.medicineType == "Pill") {
      return Hero(
        tag: medicine!.medicineName! + medicine!.medicineType!,
        child: Icon(
          FontAwesomeIcons.capsules,
          color: kPrimaryColor,
          size: 7.h,
        ),
      );
    } else if (medicine!.medicineType == "Syringe") {
      return Hero(
        tag: medicine!.medicineName! + medicine!.medicineType!,
        child: Icon(
          FontAwesomeIcons.syringe,
          color: kPrimaryColor,
          size: 7.h,
        ),
      );
    } else if (medicine!.medicineType == "Tablet") {
      return Hero(
        tag: medicine!.medicineName! + medicine!.medicineType!,
        child: Icon(
          FontAwesomeIcons.tablets,
          color: kPrimaryColor,
          size: 7.h,
        ),
      );
    }
    return Hero(
      tag: medicine!.medicineName! + medicine!.medicineType!,
      child: Icon(Icons.error, color: kPrimaryColor, size: 7.h),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        makeIcon(),
        SizedBox(width: 2.w),
        Column(
          children: [
            Hero(
              tag: medicine!.medicineName!,
              child: Material(
                color: Colors.transparent,
                child: MainInfoTab(
                    fieldTitle: "Medicine Name",
                    fieldInfo: medicine!.medicineName!),
              ),
            ),
            MainInfoTab(
                fieldTitle: "Dosage",
                fieldInfo: medicine!.dosage == 0
                    ? "Not Specified"
                    : "${medicine!.dosage} mg")
          ],
        )
      ],
    );
  }
}

class MainInfoTab extends StatelessWidget {
  const MainInfoTab(
      {super.key, required this.fieldTitle, required this.fieldInfo});
  final String fieldTitle;
  final String fieldInfo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 10.h,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fieldTitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: kTextColor)
                    .copyWith(color: Colors.grey)),
            SizedBox(height: 0.3.h),
            Text(fieldInfo,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: kTextColor))
          ],
        ),
      ),
    );
  }
}
