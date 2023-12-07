import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class MessageTextField extends StatefulWidget {
  final String currentId;
  final String friendId;

  const MessageTextField({
    Key? key,
    required this.currentId,
    required this.friendId,
  }) : super(key: key);

  @override
  State<MessageTextField> createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  TextEditingController _controller = TextEditingController();
  Position? _currentPosition;
  String? _currentAddress;
  String? message;
  File? imageFile;

  LocationPermission? permission;

  Future getImage(ImageSource source) async {
    ImagePicker _picker = ImagePicker();
    await _picker.pickImage(source: source).then((XFile? xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    try {
      String fileName = Uuid().v1();
      var ref = FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
      var uploadTask = await ref.putFile(imageFile!);
      String imageUrl = await uploadTask.ref.getDownloadURL();
      await sendMessage(imageUrl, 'img');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to upload image: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      Fluttertoast.showToast(msg: "Location permissions are denied");
      if (permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(msg: "Location permissions are permanently denied");
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
      );

      setState(() {
        _currentPosition = position;
        _getAddressFromLatLon();
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to get current location: $e');
    }
  }

  Future<void> _getAddressFromLatLon() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      Placemark place = placemarks[0];
      setState(() {
        _currentAddress = "${place.locality}, ${place.postalCode}, ${place.street}";
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to get address: $e');
    }
  }

  Future<void> sendMessage(String message, String type) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentId)
          .collection('messages')
          .doc(widget.friendId)
          .collection('chats')
          .add({
        'senderId': widget.currentId,
        'receiverId': widget.friendId,
        'message': message,
        'type': type,
        'date': DateTime.now(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.friendId)
          .collection('messages')
          .doc(widget.currentId)
          .collection('chats')
          .add({
        'senderId': widget.currentId,
        'receiverId': widget.friendId,
        'message': message,
        'type': type,
        'date': DateTime.now(),
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to send message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                cursorColor: Colors.pink,
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type your message',
                  fillColor: Colors.grey[100],
                  filled: true,
                  prefixIcon: IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) => bottomSheet(),
                      );
                    },
                    icon: Icon(
                      Icons.add_box_rounded,
                      color: Colors.pink,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () async {
                  message = _controller.text;
                  sendMessage(message!, 'text');
                  _controller.clear();
                },
                child: Icon(
                  Icons.send,
                  color: Colors.pink,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            chatsIcon(Icons.location_pin, "Location", () async {
              await _getCurrentLocation();
              Future.delayed(Duration(seconds: 2), () {
                message =
                "https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude}%2C${_currentPosition!.longitude}. $_currentAddress";
                sendMessage(message!, "link");
              });
            }),
            chatsIcon(Icons.camera_alt, "Camera", () async {
              await getImage(ImageSource.camera);
            }),
            chatsIcon(Icons.insert_photo, "Photo", () async {
              await getImage(ImageSource.gallery);
            }),
          ],
        ),
      ),
    );
  }

  Widget chatsIcon(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.pink,
            child: Icon(icon),
          ),
          Text("$title")
        ],
      ),
    );
  }
}
