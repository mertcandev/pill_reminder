import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pill_reminder/constants.dart';
import 'package:pill_reminder/global_bloc.dart';
import 'package:pill_reminder/models/errors.dart';
import 'package:pill_reminder/models/medicine.dart';
import 'package:pill_reminder/pages/home_page.dart';
import 'package:pill_reminder/pages/new_entry/new_entry_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../common/convert_time.dart';
import '../../models/medicine_type.dart';
import '../success_screen/success_screen.dart';

class NewEntryPage extends StatefulWidget {
  const NewEntryPage({super.key});

  @override
  State<NewEntryPage> createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  late TextEditingController nameController;
  late TextEditingController dosageController;
  late GlobalKey<ScaffoldState> _scaffoldKey;
  late NewEntryBloc _newEntryBloc;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    dosageController.dispose();
    _newEntryBloc.dispose();
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    dosageController = TextEditingController();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _newEntryBloc = NewEntryBloc();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    initializeNotifications();
    initializeErrorListen();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Add New"),
      ),
      body: Provider<NewEntryBloc>.value(
        value: _newEntryBloc,
        child: Padding(
          padding: EdgeInsets.all(2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PanelTitle(
                title: "Medicine Name",
                isRequired: true,
              ),
              TextFormField(
                textCapitalization: TextCapitalization.words,
                maxLength: 12,
                controller: nameController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: kOtherColor),
              ),
              const PanelTitle(
                title: "Dosage in mg",
                isRequired: true,
              ),
              TextFormField(
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.number,
                maxLength: 12,
                controller: dosageController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: kOtherColor),
              ),
              SizedBox(height: 2.h),
              const PanelTitle(title: "Medicine Type", isRequired: false),
              Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: StreamBuilder<MedicineType>(
                  builder: (context, snapshot) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MedicineTypeColumn(
                            name: "Bottle",
                            iconValue: FontAwesomeIcons.bottleWater,
                            isSelected: snapshot.data == MedicineType.Bottle
                                ? true
                                : false,
                            medicineType: MedicineType.Bottle),
                        MedicineTypeColumn(
                            name: "Pill",
                            iconValue: FontAwesomeIcons.capsules,
                            isSelected: snapshot.data == MedicineType.Pill
                                ? true
                                : false,
                            medicineType: MedicineType.Pill),
                        MedicineTypeColumn(
                            name: "Syringe",
                            iconValue: FontAwesomeIcons.syringe,
                            isSelected: snapshot.data == MedicineType.Syringe
                                ? true
                                : false,
                            medicineType: MedicineType.Syringe),
                        MedicineTypeColumn(
                            name: "Tablet",
                            iconValue: FontAwesomeIcons.tablets,
                            isSelected: snapshot.data == MedicineType.Tablet
                                ? true
                                : false,
                            medicineType: MedicineType.Tablet)
                      ],
                    );
                  },
                  stream: _newEntryBloc.selectedMedicineType,
                ),
              ),
              const PanelTitle(title: "Interval Selection", isRequired: true),
              const IntervalSelection(),
              const PanelTitle(title: "Starting Time", isRequired: true),
              const SelectTime(),
              SizedBox(height: 2.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: SizedBox(
                  width: 80.w,
                  height: 8.h,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: const StadiumBorder(),
                    ),
                    child: Center(
                      child: Text(
                        "Confirm",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    onPressed: () {
                      String? medicineName;
                      int? dosage;
                      if (nameController.text == "") {
                        _newEntryBloc.submitError(EntryError.nameNull);
                        return;
                      }
                      if (nameController.text != "") {
                        medicineName = nameController.text;
                      }
                      if (dosageController.text == "") {
                        dosage = 0;
                        return;
                      }
                      if (dosageController.text != "") {
                        dosage = int.parse(dosageController.text);
                      }
                      for (var medicine in globalBloc.medicineList$!.value) {
                        if (medicineName == medicine.medicineName) {
                          _newEntryBloc.submitError(EntryError.nameDuplicate);
                          return;
                        }
                      }
                      if (_newEntryBloc.selectedIntervals!.value == 0) {
                        _newEntryBloc.submitError(EntryError.interval);
                        return;
                      }
                      if (_newEntryBloc.selectedTimeOfDay$!.value == "None") {
                        _newEntryBloc.submitError(EntryError.startTime);
                        return;
                      }
                      String medicineType = _newEntryBloc
                          .selectedMedicineType.value
                          .toString()
                          .substring(13);

                      int interval = _newEntryBloc.selectedIntervals!.value;
                      String startTime =
                          _newEntryBloc.selectedTimeOfDay$!.value;

                      List<int> intIDs =
                          makeIDs(24 / _newEntryBloc.selectedIntervals!.value);
                      List<String> notificaionIDs =
                          intIDs.map((i) => i.toString()).toList();

                      Medicine newEntryMedicine = Medicine(
                          notificationIDs: notificaionIDs,
                          medicineName: medicineName,
                          dosage: dosage,
                          medicineType: medicineType,
                          interval: interval,
                          startTime: startTime);
                      globalBloc.updateMedicineList(newEntryMedicine);
                      scheduleNotification(newEntryMedicine);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SuccessScreen()));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void initializeErrorListen() {
    _newEntryBloc.errorState$!.listen((EntryError error) {
      switch (error) {
        case EntryError.nameNull:
          displayError("Please enter the medicine's name");
          break;
        case EntryError.nameDuplicate:
          displayError("Medicine name already exists");
          break;

        case EntryError.dosage:
          displayError("Please enter the dosage required");
          break;

        case EntryError.interval:
          displayError("Please select the reminder's interval");
          break;

        case EntryError.startTime:
          displayError("Please select the reminder's starting time");
          break;
        default:
      }
    });
  }

  void displayError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: kOtherColor,
      content: Text(error),
      duration: const Duration(milliseconds: 2000),
    ));
  }

  List<int> makeIDs(double n) {
    var rng = Random();
    List<int> ids = [];
    for (int i = 0; i < n; i++) {
      ids.add(rng.nextInt(1000000000));
    }
    return ids;
  }

  initializeNotifications() async {
    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings("@mipmap/launcher_icon");
    var initializationSettings = InitializationSettings(
        iOS: initializationSettingsIOS, android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future onSelectNotification(String? payload) async {
    if (payload != null) {
      debugPrint("notification payload: $payload");
    }
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const HomePage()));
  }

  Future<void> scheduleNotification(Medicine medicine) async {
    var hour = int.parse(medicine.startTime![0] + medicine.startTime![1]);
    var ogValue = hour;
    var minute = int.parse(medicine.startTime![2] + medicine.startTime![3]);
    var iOSPlatformChannemSpecifics = const DarwinNotificationDetails();
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        "repeatDailyAtTime channel id", "repeatDailyAtTime channel name",
        importance: Importance.max,
        ledColor: kOtherColor,
        ledOffMs: 1000,
        ledOnMs: 1000,
        enableLights: true);

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannemSpecifics);
    for (int i = 0; i < (24 / medicine.interval!).floor(); i++) {
      if (hour + (medicine.interval! * i) > 23) {
        hour = hour + (medicine.interval! * i) - 24;
      } else {
        hour = hour + (medicine.interval! * i);
      }
      await flutterLocalNotificationsPlugin.show(
          int.parse(medicine.notificationIDs![i]),
          "Reminder: ${medicine.medicineName}",
          medicine.medicineType.toString() != MedicineType.None.toString()
              ? "It is time to take your ${medicine.medicineType!.toLowerCase()}, according to schedule"
              : "It is time to take your medicine, according to schedule",
          platformChannelSpecifics);
      hour = ogValue;
    }
  }
}

class SelectTime extends StatefulWidget {
  const SelectTime({super.key});

  @override
  State<SelectTime> createState() => _SelectTimeState();
}

class _SelectTimeState extends State<SelectTime> {
  TimeOfDay _time = const TimeOfDay(hour: 0, minute: 00);
  bool _clicked = false;

  Future<TimeOfDay> _selectTime() async {
    final NewEntryBloc newEntryBloc =
        Provider.of<NewEntryBloc>(context, listen: false);

    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: _time);

    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
        _clicked = true;

        //update state via provider, we will do later
        newEntryBloc.updateTime(convertTime(_time.hour.toString()) +
            convertTime(_time.minute.toString()));
      });
    }
    return picked!;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8.h,
      child: Padding(
        padding: EdgeInsets.only(top: 2.h),
        child: TextButton(
          style: TextButton.styleFrom(
              backgroundColor: kPrimaryColor, shape: const StadiumBorder()),
          onPressed: () {
            _selectTime();
          },
          child: Center(
            child: Text(
              _clicked == false
                  ? "Select Time"
                  : "${convertTime(_time.hour.toString())} : ${convertTime(_time.toString())} ",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}

class IntervalSelection extends StatefulWidget {
  const IntervalSelection({super.key});

  @override
  State<IntervalSelection> createState() => _IntervalSelectionState();
}

class _IntervalSelectionState extends State<IntervalSelection> {
  final _intervals = [6, 8, 12, 24];
  var _selected = 0;
  @override
  Widget build(BuildContext context) {
    final NewEntryBloc newEntryBloc = Provider.of<NewEntryBloc>(context);
    return Padding(
      padding: EdgeInsets.only(top: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Remind me every",
            style: Theme.of(context).textTheme.displaySmall,
          ),
          DropdownButton(
            iconEnabledColor: kOtherColor,
            dropdownColor: kScaffoldColor,
            itemHeight: 8.h,
            elevation: 4,
            value: _selected == 0 ? null : _selected,
            hint: _selected == 0
                ? Text(
                    "Select an Interval",
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : null,
            onChanged: (newVal) {
              setState(() {
                _selected = newVal!;
                newEntryBloc.updateInterval(newVal);
              });
            },
            items: _intervals.map(
              (int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    value.toString(),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                );
              },
            ).toList(),
          ),
          Text(
            _selected == 1 ? " hour" : " hours",
            style: Theme.of(context).textTheme.displaySmall,
          )
        ],
      ),
    );
  }
}

class MedicineTypeColumn extends StatelessWidget {
  const MedicineTypeColumn(
      {super.key,
      required this.name,
      required this.iconValue,
      required this.isSelected,
      required this.medicineType});
  final MedicineType medicineType;
  final String name;
  final bool isSelected;
  final IconData iconValue;

  @override
  Widget build(BuildContext context) {
    final NewEntryBloc newEntryBloc = Provider.of<NewEntryBloc>(context);
    return GestureDetector(
      onTap: () {
        newEntryBloc.updateSelectedMedicine(medicineType);
      },
      child: Column(
        children: [
          Container(
              alignment: Alignment.center,
              width: 20.w,
              height: 10.h,
              decoration: BoxDecoration(
                color: isSelected ? kOtherColor : Colors.white,
                borderRadius: BorderRadius.circular(3.h),
              ),
              child: Icon(
                iconValue,
                size: 24.sp,
                color: isSelected ? Colors.white : kOtherColor,
              )),
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Container(
              width: 20.w,
              height: 4.h,
              decoration: BoxDecoration(
                  color: isSelected ? kOtherColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(20)),
              child: Center(
                  child: Text(
                name,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(color: isSelected ? Colors.white : kOtherColor),
              )),
            ),
          )
        ],
      ),
    );
  }
}

class PanelTitle extends StatelessWidget {
  const PanelTitle({super.key, required this.title, required this.isRequired});
  final String title;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
                text: title, style: Theme.of(context).textTheme.labelMedium),
            TextSpan(
                text: isRequired ? " + " : "",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: kPrimaryColor))
          ],
        ),
      ),
    );
  }
}
