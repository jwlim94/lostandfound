import 'dart:async';

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

  submit() {
    final form = _formkey.currentState;

    // validate function will go through validate one more time in TextFormField
    if (form!.validate()) {
      // use Global key to save state
      // this happens when submit button has been pushed so
      // username by that time will be sent back to the previous page
      form.save();

      // showSnackBar used to be work with scaffold key as well as formkey
      // but now it is deprecated and does not need to make a key
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Welcome $username!')));
      Timer(const Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: "Set up your profile",
        removeBackButton: true,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      'Create a username',
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
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
                          labelText: 'Username',
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: 'Must be at least 3 characters',
                        ),
                      ),
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
                        'Submit',
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
          ),
        ],
      ),
    );
  }
}
