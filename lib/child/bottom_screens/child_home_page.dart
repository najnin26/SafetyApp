import 'dart:math';
import 'package:flutter/material.dart';
import 'package:safetyapp/utils/quotes.dart';
import 'package:safetyapp/widgets/home_widgets/custom_appBar.dart';
import 'package:safetyapp/widgets/home_widgets/CustomCarouel.dart';
import 'package:safetyapp/widgets/home_widgets/emergency.dart';
import 'package:safetyapp/widgets/home_widgets/safehome/SafeHome.dart';
import 'package:safetyapp/widgets/life_safe.dart';
class HomeScreen extends StatefulWidget{
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //const HomeScreen({super.key});
  int qIndex = 0;
  getRandomQuote(){
    Random random = Random();
    setState(() {
      qIndex=random.nextInt(sweetSayings.length);
    });
  }
  @override
  void initState(){
    getRandomQuote();
    super.initState();
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