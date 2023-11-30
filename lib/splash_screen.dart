import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:safetyapp/child/bottom_page.dart';
import 'package:safetyapp/db/share_pref.dart';
import 'package:safetyapp/parent/parent_home_screen.dart';
import 'package:safetyapp/utils/constants.dart';
import 'child/child_login_screen.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen.withScreenFunction(
      splash: 'assets/splash.jpg', // Replace with your splash image path
      screenFunction: () async {
        await MySharedPrefference.init();

        String? userType = await MySharedPrefference.getUserType();
        if (userType == null || userType == "") {
          return LoginScreen();
        } else if (userType == "child") {
          return BottomPage();
        } else if (userType == "parent") {
          return ParentHomeScreen();
        } else {
          return progressIndicator(context);
        }
      },
      splashTransition: SplashTransition.rotationTransition,
      pageTransitionType: PageTransitionType.scale,
      duration: 3000,
    );
  }
}
