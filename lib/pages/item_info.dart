import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/item.dart';
import 'package:flutter_application_1/pages/home.dart';
import 'package:flutter_application_1/widgets/custom_image.dart';
import 'package:flutter_application_1/widgets/header.dart';
import 'package:flutter_application_1/widgets/progress.dart';
import 'package:string_extensions/string_extensions.dart';

class ItemInfo extends StatefulWidget {
  final Item item;

  ItemInfo({required this.item});

  @override
  _ItemInfoState createState() => _ItemInfoState();
}

class _ItemInfoState extends State<ItemInfo> {
  late bool isAuthor;

  @override
  void initState() {
    super.initState();

    if (FirebaseAuth.instance.currentUser?.uid == widget.item.ownerId) {
      setState(() {
        isAuthor = true;
      });
    } else {
      setState(() {
        isAuthor = false;
      });
    }
  }

  Scaffold buildInfoScreen(context) {
    return Scaffold(
        appBar: header(
          context,
          titleText: widget.item.title,
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(
                  top: 32.0,
                ),
              ),

              // image
              SizedBox(
                height: 220.0,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // this is from 'custom_image.dart' to show an image
                        // in better user experience way in profile
                        cachedNetworkImage(
                          widget.item.mediaUrl,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
              ),

              // type
              ListTile(
                leading: const Icon(
                  Icons.list,
                  color: Colors.black,
                  size: 35.0,
                ),
                title: Container(
                  width: 250.0,
                  child: Text(
                    widget.item.type.capitalize!,
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Color
              ListTile(
                leading: const Icon(
                  Icons.colorize,
                  color: Colors.black,
                  size: 35.0,
                ),
                title: Container(
                  width: 250.0,
                  child: Text(
                    widget.item.color,
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // location
              ListTile(
                leading: const Icon(
                  Icons.pin_drop,
                  color: Colors.red,
                  size: 35.0,
                ),
                title: Container(
                  width: 250.0,
                  child: Text(
                    widget.item.location,
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // timestamp
              FutureBuilder(
                future: itemRef.doc(widget.item.postId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return circularProgress();
                  }
                  Timestamp time =
                      (snapshot.data as DocumentSnapshot).get('timestamp');

                  return ListTile(
                    leading: const Icon(
                      Icons.date_range,
                      color: Colors.orange,
                      size: 35.0,
                    ),
                    title: Container(
                      width: 250.0,
                      child: Text(
                        time.toDate().toString(),
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),

              // description
              ListTile(
                leading: const Icon(
                  Icons.description,
                  color: Colors.black,
                  size: 35.0,
                ),
                title: Container(
                  width: 250.0,
                  child: Text(
                    widget.item.description,
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              isAuthor 
                ? Container() // A list of those who claimed 
                : Container( 
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 5.0),
                  child: TextButton(
                    onPressed: claimItem,
                    child: Container(
                      width: 200.0,
                      height: 40.0,
                      child: const Text(
                        'claim',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        border: Border.all(
                          color: Colors.blue,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
              ),
            ],
          ),
        ));
  }

  claimItem() {
    print("claim button clicked.");
  }

  @override
  Widget build(BuildContext context) {
    return buildInfoScreen(context);
  }
}
