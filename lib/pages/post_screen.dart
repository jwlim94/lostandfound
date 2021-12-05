import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/home.dart';
import 'package:flutter_application_1/widgets/header.dart';
import 'package:flutter_application_1/widgets/post.dart';
import 'package:flutter_application_1/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final String postId;
  final String userId;

  PostScreen({required this.postId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postRef.doc(userId).collection('userPosts').doc(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data as DocumentSnapshot);
        return Center(
          child: Scaffold(
            // FIXME: change titleText to post 'title'
            appBar: header(context, titleText: 'post'),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
