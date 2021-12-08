import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/item.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/home.dart';
import 'package:flutter_application_1/widgets/header.dart';
import 'package:flutter_application_1/widgets/post_item.dart';
import 'package:flutter_application_1/widgets/progress.dart';
import 'package:flutter_svg/flutter_svg.dart';

// getting users collection from Firebase
final userRef = FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  bool isPostRetrieved = false;
  List<PostItem> postItems = [];
  List<String> prevItemsId = [];

  @override
  void initState() {
    super.initState();
    getTimeline();
  }

  getTimeline() async {
    // retrieve items doc
    QuerySnapshot snapshot = await itemRef.firestore
        .collection('items')
        .where('isReturned', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .get();

    // retrieve list of items
    List<Item> items =
        snapshot.docs.map((doc) => Item.fromDocument(doc)).toList();

    // set states
    setState(() {
      isPostRetrieved = true;
      items.forEach((item) {
        if (!prevItemsId.contains(item.postId)) {
          prevItemsId.add(item.postId);
          postItems.add(PostItem(item: item));
        }
      });
    });
  }

  buildTimeline() {
    if (isPostRetrieved == false) {
      return circularProgress();
    } else if (postItems.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset('assets/images/no_content.svg', height: 260.0),
            const Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                'No Posts',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return ListView(children: postItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context, titleText: 'Lost Items', removeBackButton: true),
        body: RefreshIndicator(
            onRefresh: () => getTimeline(), child: buildTimeline()));
  }
}
