import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/header.dart';
import 'package:flutter_application_1/widgets/progress.dart';

// getting users collection from Firebase
final userRef = FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  const Timeline({Key? key}) : super(key: key);

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  // this is used when not using StreamBuilder; only works for Stateful
  // List<dynamic> users = [];

  @override
  void initState() {
    // getUsers();
    // getUserById();
    // updateUser();
    // createUser();
    // deleteUser();
    super.initState();
  }

  // get 'users' collections
  // this is used when not using StreamBuilder
  getUsers() async {
    // get() returns a Future
    // where() helps us to query by fields
    // need to set indexes in web console when where() is nested
    QuerySnapshot snapshot =
        // await userRef.where('isAdmin', isEqualTo: true).get();
        // await userRef.orderBy('postsCount', descending: true).get();
        await userRef.limit(1).get();

    // this is used when not using StreamBuilder; only works for Staseful
    // setState(() {
    //   users = snapshot.docs;
    // });

    snapshot.docs.forEach((DocumentSnapshot doc) {
      // print(doc.data);
      // print(doc.exists);
      // print(doc.id);
      // print(doc['username']);
    });
  }

  // get specific user document
  // this is used when not using StreamBuilder
  getUserById() async {
    // hard coding document id for testing
    const String id = 'K68hRVZJk1SFCrBoyNxc';

    // chaining the document from 'users' collection
    // get() returns a Future
    DocumentSnapshot doc = await userRef.doc(id).get();
    print(doc.exists);
    print(doc.id);
  }

  // create an user
  // set() vs add()
  createUser() async {
    await userRef.doc("asdfasd").set({
      'username': 'Jake',
      'postsCount': 0,
      'isAdmin': false,
    });
  }

  // update an user
  updateUser() async {
    DocumentSnapshot doc = await userRef.doc('asdfasd').get();

    if (doc.exists) {
      doc.reference.update({'username': 'Jongmin'});
    }
  }

  // delete an user
  deleteUser() async {
    DocumentSnapshot doc = await userRef.doc('asdfasd').get();

    if (doc.exists) {
      doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      // StreamBuilder makes it possible to put logic only in build method
      // both for fetching and showing data
      // StreamBuilder vs FutureBuilder
      // body: StreamBuilder<QuerySnapshot>(
      //   stream: userRef.snapshots(),
      //   builder: (context, snapshot) {
      //     if (!snapshot.hasData) {
      //       return circularProgress();
      //     }
      //     final List<Text> children =
      //         snapshot.data!.docs.map((doc) => Text(doc['username'])).toList();
      //     return Container(
      //       child: ListView(
      //         children: children,
      //       ),
      //     );
      //   },
      // ),
      // this is used when not using StreamBuilder
      // body: Container(
      //   child: ListView(
      //     children: users.map((user) => Text(user['username'])).toList(),
      //   ),
      // ),
    );
  }
}
