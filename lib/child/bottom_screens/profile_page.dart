import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../child_login_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: ()async{
            try{
              await FirebaseAuth.instance.signOut();
              goTo(context, LoginScreen());
            } on FirebaseAuthException catch(e){
              dialogueBox(context, e.toString());
            }
            },
          child: Text(
            "SIGN OUT",
          ),
        ),
      ),
    );
  }
}
