
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safetyapp/model/user_model.dart';
import '../compontnts/PrimaryButton.dart';
import '../compontnts/SecondaryButton.dart';
import '../compontnts/custom_textfield.dart';
import '../utils/constants.dart';
import 'child_login_screen.dart';

class RegisterChildScreen extends StatefulWidget {
  @override
  State<RegisterChildScreen> createState() => _RegisterChildScreenState();
}

class _RegisterChildScreenState extends State<RegisterChildScreen> {
  bool isPasswordShown=true;
  bool isRetypePasswordShown = true;
  final _formkey=GlobalKey<FormState>();
  bool isLoading = false;
  final _formData=Map<String,Object>();

  _onSubmit() async{
    _formkey.currentState!.save();
    if(_formData['password']!=_formData['rpassword']){
      dialogueBox(context,'Password and retype password should be equal');
    }else{
      progressIndicator(context);
      try {
        setState(() {
          isLoading = true;
        });
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email:_formData['cemail'].toString(),
            password:_formData['password'].toString()
        );
        if(userCredential.user!=null){
          setState(() {
            isLoading = true;
          });
          final v = userCredential.user!.uid;
          DocumentReference<Map<String, dynamic>>db=
          FirebaseFirestore.instance.collection('users').doc(v);
          final user=UserModel(
            name: _formData['name'].toString(),
            phone: _formData['phone'].toString(),
            childEmail: _formData['cemail'].toString(),
            guardianEmail: _formData['gemail'].toString(),
            id: v,
            type:'child',
          );
          final jsonData=user.toJson();
          await db.set(jsonData).whenComplete((){
            goTo(context, LoginScreen());
            setState(() {
              isLoading = false;
            });
          });
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
          dialogueBox(context, 'The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
          dialogueBox(context,'The account already exists for that email.');
        }
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        print(e);
        setState(() {
          isLoading = false;
        });
        dialogueBox(context, e.toString());
      }
    }
    print(_formData['email']);
    print(_formData['password']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 10
          ),
          child: Stack(
            children: [
              isLoading? progressIndicator(context)
              :SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height*0.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "REGISTER AS CHILD",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          Image.asset('assets/logo.png',
                            height: 100,
                            width: 100,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height*0.75,
                      child: Form(
                        key: _formkey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomTextField(
                              hintText:'Enter name',
                              textInputAction: TextInputAction.next,
                              keyboardtype: TextInputType.name,
                              prefix: Icon(Icons.person),
                              onsave: (name){
                                _formData['name']=name??"";
                              },
                              validate: (email){
                                if(email!.isEmpty||
                                    email.length<3){
                                  return "Enter correct name";
                                }
                                return null;
                              },
                            ),
                            CustomTextField(
                              hintText:'Enter phone',
                              textInputAction: TextInputAction.next,
                              keyboardtype: TextInputType.phone,
                              prefix: Icon(Icons.phone),
                              onsave: (phone){
                                _formData['phone']=phone??"";
                              },
                              validate: (email){
                                if(email!.isEmpty||
                                    email.length<10){
                                  return "Enter correct phone";
                                }
                                return null;
                              },
                            ),
                            CustomTextField(
                              hintText:'Enter email',
                              textInputAction: TextInputAction.next,
                              keyboardtype: TextInputType.emailAddress,
                              prefix: Icon(Icons.person),
                              onsave: (email){
                                _formData['cemail']=email??"";
                              },
                              validate: (email){
                                if(email!.isEmpty||
                                    email.length<3||
                                    !email.contains("@")){
                                  return "Enter correct email";
                                }
                                return null;
                              },
                            ),
                            CustomTextField(
                              hintText:'Enter guardian email',
                              textInputAction: TextInputAction.next,
                              keyboardtype: TextInputType.emailAddress,
                              prefix: Icon(Icons.person),
                              onsave: (gemail){
                                _formData['gemail']=gemail??"";
                              },
                              validate: (email){
                                if(email!.isEmpty||
                                    email.length<3||
                                    !email.contains("@")){
                                  return "Enter correct email";
                                }
                                return null;
                              },
                            ),
                            CustomTextField(
                              hintText:'Enter password',
                              isPassword: isPasswordShown,
                              prefix: Icon(Icons.vpn_key_rounded),
                              onsave: (password){
                                _formData['password']=password??"";
                              },
                              validate: (password){
                                if(password!.isEmpty|| password.length<7){
                                  return "Enter correct password";
                                }
                                return null;
                              },
                              suffix: IconButton(onPressed: (){
                                setState(() {
                                  isPasswordShown=!isPasswordShown;
                                });
                              },
                                  icon:isPasswordShown
                                      ?Icon(Icons.visibility_off)
                                      : Icon(Icons.visibility)),
                            ),
                            CustomTextField(
                              hintText:'Retype password',
                              isPassword: isRetypePasswordShown,
                              prefix: Icon(Icons.vpn_key_rounded),
                              onsave: (password){
                                _formData['rpassword']=password??"";
                              },
                              validate: (password){
                                if(password!.isEmpty|| password.length<7){
                                  return "Enter correct password";
                                }
                                return null;
                              },
                              suffix: IconButton(onPressed: (){
                                setState(() {
                                  isRetypePasswordShown =!isRetypePasswordShown ;
                                });
                              },
                                  icon:isRetypePasswordShown
                                      ?Icon(Icons.visibility_off)
                                      : Icon(Icons.visibility)),
                            ),

                            PrimaryButton(
                                title: 'REGISTER',
                                onPressed: (){
                                  if(_formkey.currentState!.validate()){
                                    _onSubmit();
                                  }
                                }),
                          ],
                        ),
                      ),
                    ),

                    SecondaryButton(
                        title:"Login with your account",
                        onPressed: (){
                          goTo(context, LoginScreen());
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}