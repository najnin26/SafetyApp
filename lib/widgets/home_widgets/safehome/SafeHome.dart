
import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safetyapp/db/db_services.dart';
import 'package:safetyapp/model/contactsm.dart';

import '../../../compontnts/PrimaryButton.dart';

class SafeHome extends StatefulWidget {

  @override
  State<SafeHome> createState() => _SafeHomeState();
}

class _SafeHomeState extends State<SafeHome> {
  Position? _curentPosition;
  String? _curentAddress;
  LocationPermission? permission;
  _getPermission() async => await [Permission.sms].request();
  _isPermissionGranted() async => await Permission.sms.isGranted;
  _sendSms(String phoneNumber, String message, {int? simSlot}) async {
    await BackgroundSms.sendMessage(
        phoneNumber: phoneNumber,
        message: message,
        simSlot: simSlot
    ).then((SmsStatus status) {
      if (status == SmsStatus.sent) {
        Fluttertoast.showToast(msg: 'sent');
      } else {
        Fluttertoast.showToast(msg: 'failed');
      }
    });
  }
  _getCurrentLocation() async{
    permission=await Geolocator.checkPermission();
    if(permission==LocationPermission.denied){
      permission=await Geolocator.requestPermission();
      Fluttertoast.showToast(
          msg: 'Location permissions are denied.');
      if(permission==LocationPermission.deniedForever){
        Fluttertoast.showToast(
            msg: 'Location permissions are permanently denied.');
      }
    }
    Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      forceAndroidLocationManager: true,
    ).then((Position position) {
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
  @override
  void initState() {
    super.initState();
    _getPermission();
    _getCurrentLocation();
  }
  showModelSafeHome(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery
              .of(context)
              .size
              .height / 1.4,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "SEND YOUR CURRENT LOCATION IMMEDIATELY TO YOU EMERGENCY CONTACTS",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                if (_curentPosition != null) Text(_curentAddress ?? 'No address available'),
                PrimaryButton(
                    title: "GET LOCATION",
                    onPressed: () {
                      _getCurrentLocation();
                    }),
                SizedBox(height: 10),
                PrimaryButton(
                    title: "GET ALERT", onPressed: () async{
                      List<TContact> contactList=await DatabaseHelper().getContactList();
                      String recipients="";
                      int i=1;
                      for(TContact contact in contactList){
                        recipients +=contact.number;
                        if(i!=contactList.length){
                          recipients+=';';
                          i++;
                        }
                      }
                      String messageBody=
                          "https://www.google.com/maps/search/?api=1&query=${_curentPosition?.latitude ?? 0}%2C${_curentPosition?.longitude ?? 0}. ${_curentAddress ?? ''}";
                      if(await _isPermissionGranted()){
                        contactList.forEach((element) {
                          _sendSms("${element.number}",
                            "i am in trouble $messageBody");
                        });
                      } else {
                        Fluttertoast.showToast(msg: "something wrong");
                      }
                    }),
              ],
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    if (_curentPosition != null) {//added using new idea
      print(_curentPosition!.latitude);
    }
    return InkWell(
      onTap: () => showModelSafeHome(context),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          height: 180,
          width: MediaQuery
              .of(context)
              .size
              .width * 0.9,
          decoration: BoxDecoration(),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    ListTile(
                      title: Text("Send location"),
                      subtitle: Text("Share location"),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('assets/route.jpg'),
              )
            ],
          ),
        ),
      ),
    );
  }
}