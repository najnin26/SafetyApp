
import 'dart:math';

import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shake/shake.dart';

import '../../db/db_services.dart';
import '../../model/contactsm.dart';
import '../../utils/quotes.dart';
import '../../widgets/home_widgets/CustomCarouel.dart';
import '../../widgets/home_widgets/custom_appBar.dart';
import '../../widgets/home_widgets/emergency.dart';
import '../../widgets/home_widgets/safehome/SafeHome.dart';
import '../../widgets/life_safe.dart';

class HomeScreen extends StatefulWidget{
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //const HomeScreen({super.key});
  int qIndex = 0;
  Position? _curentPosition;
  String? _curentAddress;
  LocationPermission? permission;
  _getPermission() async=> await [Permission.sms].request();
  _isPermissionGranted() async => await Permission.sms.status.isGranted;
  _sendSms(String phoneNumber, String message, {int? simSlot}) async {
    SmsStatus result = await BackgroundSms.sendMessage(
        phoneNumber: phoneNumber, message: message, simSlot: 1);
    if (result == SmsStatus.sent) {
      print("Sent");
      Fluttertoast.showToast(msg: "send");
    } else {
      Fluttertoast.showToast(msg: "failed");
    }
  }
  _getCurrentLocation() async {
    permission = await Geolocator.checkPermission();
    if (permission==LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      Fluttertoast.showToast(msg: "Location permissions are denied.");
      if(permission==LocationPermission.deniedForever){
        await Geolocator.requestPermission();
        Fluttertoast.showToast(msg: "Location permissions are permanently denied.");
      }
    }
    await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _curentPosition = position;
        print(_curentPosition!.latitude);
        _getAddressFromLatLon();
      });
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  _getAddressFromLatLon() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _curentPosition!.latitude, _curentPosition!.longitude);

      Placemark place = placemarks[0];
      setState(() {
        _curentAddress =
        "${place.locality},${place.postalCode},${place.street},";
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
  getRandomQuote(){
    Random random = Random();
    setState(() {
      qIndex=random.nextInt(sweetSayings.length);
    });
  }
  getAndSendSmS() async{
    List<TContact> contactList=await DatabaseHelper().getContactList();
    String recipients="";
    int i=1;
    for(TContact contact in contactList) {
      recipients += contact.number;
      if (i != contactList.length) {
        recipients += ';';
        i++;
      }
    }
      String messageBody=
        "https://www.google.com/maps/search/?api=1&query=${_curentPosition!.latitude}%2C${_curentPosition!.longitude}";
    if(await _isPermissionGranted()){
      contactList.forEach((element) {
        _sendSms("${element.number}",
            "i am in trouble $messageBody");
      });
    } else {
      Fluttertoast.showToast(msg: "something wrong");
    }
  }

  @override
  void initState(){
    getRandomQuote();
    super.initState();
    _getPermission();
    _getCurrentLocation();
    ShakeDetector.autoStart(
      onPhoneShake: () {
        getAndSendSmS();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shake!'),
          ),
        );
        // Do stuff on phone shake
      },
      minimumShakeCount: 1,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: 2.7,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppBar(
                    onTap: getRandomQuote,
                    quoteIndex: qIndex,
                  ),
                  CustomCarousel(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Emergency",
                      style:
                      TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                    ),
                  ),
                  Emergency(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Explore LiveSafe",
                      style:
                      TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                    ),
                  ),
                  LiveSafe(),
                  SafeHome(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}