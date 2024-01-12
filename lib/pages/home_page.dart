import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pill_reminder/constants.dart';
import 'package:pill_reminder/global_bloc.dart';
import 'package:pill_reminder/pages/medicine_details/medicine_details.dart';
import 'package:pill_reminder/pages/new_entry/new_entry_page.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../models/medicine.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(2.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const TopContainer(),
            SizedBox(height: 2.h),
            const Flexible(child: BottomContainer())
          ],
        ),
      ),
      floatingActionButton: InkResponse(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const NewEntryPage()));
        },
        child: SizedBox(
          width: 18.w,
          height: 9.h,
          child: Card(
            shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(3.h)),
            color: kPrimaryColor,
            child: Icon(
              Icons.add_outlined,
              color: kScaffoldColor,
              size: 50.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class TopContainer extends StatelessWidget {
  const TopContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(bottom: 1.h),
          child: Text(
            "Worry Less.\nLive Healthier.",
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(bottom: 1.h),
          child: Text(
            "Welcome to Daily Dose",
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
        SizedBox(height: 2.h),
        StreamBuilder<List<Medicine>>(
            stream: globalBloc.medicineList$,
            builder: (context, snapshot) {
              return Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(bottom: 1.h),
                child: Text(
                  !snapshot.hasData ? "0" : snapshot.data!.length.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              );
            }),
      ],
    );
  }
}

class BottomContainer extends StatelessWidget {
  const BottomContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);

    return StreamBuilder(
        stream: globalBloc.medicineList$,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else if (snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No Medicine",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          } else {
            return GridView.builder(
              padding: EdgeInsets.only(top: 1.h),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return MedicineCard(
                  medicine: snapshot.data![index],
                );
              },
            );
          }
        });

    // return Text(
    //   "No Medicine",
    //   textAlign: TextAlign.center,
    //   style: Theme.of(context).textTheme.headlineMedium,
    // );
  }
}

class MedicineCard extends StatelessWidget {
  const MedicineCard({super.key, required this.medicine});
  final Medicine medicine;
  Hero makeIcon() {
    if (medicine.medicineType == "Bottle") {
      return Hero(
        tag: medicine.medicineName! + medicine.medicineType!,
        child: Icon(
          FontAwesomeIcons.bottleDroplet,
          color: kPrimaryColor,
          size: 7.h,
        ),
      );
    } else if (medicine.medicineType == "Pill") {
      return Hero(
        tag: medicine.medicineName! + medicine.medicineType!,
        child: Icon(
          FontAwesomeIcons.capsules,
          color: kPrimaryColor,
          size: 7.h,
        ),
      );
    } else if (medicine.medicineType == "Syringe") {
      return Hero(
        tag: medicine.medicineName! + medicine.medicineType!,
        child: Icon(
          FontAwesomeIcons.syringe,
          color: kPrimaryColor,
          size: 7.h,
        ),
      );
    } else if (medicine.medicineType == "Tablet") {
      return Hero(
        tag: medicine.medicineName! + medicine.medicineType!,
        child: Icon(
          FontAwesomeIcons.tablets,
          color: kPrimaryColor,
          size: 7.h,
        ),
      );
    }
    return Hero(
      tag: medicine.medicineName! + medicine.medicineType!,
      child: Icon(Icons.error, color: kPrimaryColor, size: 7.h),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.white,
      splashColor: Colors.grey,
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder<void>(
              pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, Widget? child) {
                    return Opacity(
                      opacity: animation.value,
                      child: MedicineDetails(
                        medicine: medicine,
                      ),
                    );
                  },
                );
              },
              transitionDuration: const Duration(milliseconds: 200)),
        );
      },
      child: Container(
        margin: EdgeInsets.all(1.h),
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(2.h)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              makeIcon(),
              const Spacer(),
              Hero(
                tag: medicine.medicineName!,
                child: Text(medicine.medicineName!,
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: kTextColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2)),
              ),
              SizedBox(
                height: 0.3.h,
              ),
              Text(
                  medicine.interval == 1
                      ? "Every ${medicine.interval} hour"
                      : "Every ${medicine.interval} hours",
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.start,
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(color: kTextLightColor))
            ]),
      ),
    );
  }
}
