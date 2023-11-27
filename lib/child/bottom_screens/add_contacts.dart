import 'package:flutter/material.dart';
import 'package:safetyapp/child/bottom_screens/contacts_page.dart';
import 'package:safetyapp/compontnts/PrimaryButton.dart';

class  AddContactsPage extends StatelessWidget {
  const AddContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            PrimaryButton(title: "AddContacts page", onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder:(context)=>ContactPage(),
                  ));
            }),
          ],
        ),
      ),
    );
  }
}
