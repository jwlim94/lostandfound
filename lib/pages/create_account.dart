import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  CreateAccount({Key? key}) : super(key: key);

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  // GlobalKey is unique accross the entire app. it uniquely identify elements
  final _formkey = GlobalKey<FormState>();
  String username = 'deafult';

  // Phone verification
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  late String _verificationId;

  submit() async {
    final form = _formkey.currentState;

    // validate function will go through validate one more time in TextFormField
    if (form!.validate()) {
      // use Global key to save state
      // this happens when submit button has been pushed so
      // username by that time will be sent back to the previous page
      form.save();

      try {
        final AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: _smsController.text,
        );

        await _auth.signInWithCredential(credential);

        // showSnackBar used to be work with scaffold key as well as formkey
        // but now it is deprecated and does not need to make a key
        showSnackbar('Welcome $username!');
        Timer(const Duration(seconds: 2), () {
          Navigator.pop(context, username);
        });
      } catch (e) {
        showSnackbar("Failed to sign in: " + e.toString());
      }
    }
  }

  showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  verifyPhoneNumber() async {
    // check if the user has previously authenticated, and if they can be
    // automatically signed in to Firebase without sumitting another SMS verification code
    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential PhoneAuthCredential) async {
      await _auth.signInWithCredential(PhoneAuthCredential);
      showSnackbar(
          'Phone number automatically verified and user signed in: ${_auth.currentUser!.uid}');
    };

    // listen for errors
    PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      showSnackbar(
          'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
    };

    // callback for when the code is sent
    PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      showSnackbar('Please check your phone for the verification code');
      _verificationId = verificationId;
    };

    // notify app when an SMS auto-retrival times out
    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      showSnackbar("verification code: " + verificationId);
      _verificationId = verificationId;
    };

    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: _phoneNumberController.text,
          timeout: const Duration(seconds: 5),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      showSnackbar("Failed to Verify Phone Number: ${e}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: "Sign up",
        removeBackButton: true,
      ),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 25.0, bottom: 16.0),
                child: const Center(
                  child: Text(
                    'Set up your profile',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formkey,
                  autovalidateMode: AutovalidateMode.always,
                  // val from TextFormField indicates input value from user
                  child: TextFormField(
                    validator: (val) {
                      if (val!.trim().length < 3 || val.isEmpty) {
                        return 'Username too short';
                      } else if (val.trim().length > 12) {
                        return 'Username too long';
                      } else {
                        return null;
                      }
                    },
                    // onSaved() to return the input text (in state) to previous page
                    onSaved: (val) => username = val!,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelText: 'Username',
                      labelStyle: TextStyle(fontSize: 15.0),
                      hintText: 'Must be at least 3 characters',
                    ),
                    cursorColor: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                    top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
                child: TextFormField(
                  controller: _phoneNumberController,
                  cursorColor: Colors.black,
                  decoration: const InputDecoration(
                    hoverColor: Colors.black,
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    labelText: 'Phone number',
                    hintText: 'Follow this format (+xx xxx-xxx-xxxx)',
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  child: const Text('Verify Number'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  ),
                  onPressed: () async {
                    verifyPhoneNumber();
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 48.0,
                ),
                child: TextFormField(
                  controller: _smsController,
                  cursorColor: Colors.black,
                  decoration: const InputDecoration(
                    hoverColor: Colors.black,
                    labelText: 'Verification code',
                    hintText: 'Enter 6 digits',
                  ),
                ),
              ),
              GestureDetector(
                onTap: submit,
                child: Container(
                  height: 50.0,
                  width: 350.0,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: const Center(
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
