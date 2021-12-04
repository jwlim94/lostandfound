import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/item.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/home.dart';
import 'package:flutter_application_1/widgets/header.dart';
import 'package:flutter_application_1/widgets/post.dart';
import 'package:flutter_application_1/widgets/post_tile.dart';
import 'package:flutter_application_1/widgets/progress.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'edit_profile.dart';

// FIXME: fetch claimed items as well (just like posts) to show
class Profile extends StatefulWidget {
  final String? profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // this might be different when viewing other people's profile
  final String? currentUserId = currentUser?.id;

  // default to show posts
  String postOrientation = 'posts';

  bool isLoding = false;
  int postCount = 0;
  List<Item> items = [];

  @override
  void initState() {
    super.initState();
    getProfilePosts();
  }

  // fetching posts from 'post.dart'
  getProfilePosts() async {
    setState(() {
      isLoding = true;
    });
    QuerySnapshot snapshot =
        await itemRef.orderBy('timestamp', descending: true).get();
    setState(() {
      isLoding = false;
      postCount = snapshot.docs.length;
      items = snapshot.docs.map((doc) => Item.fromDocument(doc)).toList();
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  editProfile() {
    // .then() and setState was added to automatically get the updated data
    // when we got back from Edit Profile page
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                EditProfile(currentUserId: currentUserId))).then((value) {
      setState(() {});
    });
  }

  // VoidCallback is just shorthand for Void Function()
  Container buildButton({String? text, VoidCallback? function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: TextButton(
        onPressed: function,
        child: Container(
          width: 250.0,
          height: 27.0,
          child: Text(
            text!,
            style: TextStyle(
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
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    // viewing your own profile - should show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        text: 'Edit Profile',
        function: editProfile,
      );
    }
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: userRef.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        // as DocumentSnapshot to convert the type
        User user = User.fromDocument(snapshot.data as DocumentSnapshot);
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // first Row
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    flex: 1, // set the priority
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn('posts', postCount),
                            buildCountColumn('claims', 0),
                          ],
                        ),
                        // why Row() here? it is just a button?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  user.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 2.0),
                // child: Text(user.bio),
              ),
            ],
          ),
        );
      },
    );
  }

  // display posts after fetching them
  buildProfilePosts() {
    if (isLoding) {
      return circularProgress();
    } else if (items.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset('assets/images/no_content.svg', height: 260.0),
            Padding(
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
    } else if (postOrientation == 'posts') {
      List<GridTile> postsGridTiles = [];
      items.forEach((item) {
        postsGridTiles.add(GridTile(
          // PostTile came from 'post_tile.dart'
          child: PostTile(item),
        ));
      });
      return GridView.count(
        padding: EdgeInsets.all(1.5),
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: postsGridTiles,
      );
    } else if (postOrientation == 'claims') {
      /* FIXME: change every 'posts' to 'claims' */
      List<GridTile> postsGridTiles = [];
      items.forEach((item) {
        postsGridTiles.add(GridTile(
          // PostTile came from 'post_tile.dart'
          child: PostTile(item),
        ));
      });
      return GridView.count(
        padding: EdgeInsets.all(1.5),
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: postsGridTiles,
      );
    }
  }

  // set orientation between posts and claims as it gets toggled
  setPostOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
      print(postOrientation);
    });
  }

  // toggle between posts and claims to show users of those items
  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        GestureDetector(
          /* without () => syntax, setPostOrientation() gets called automatically
          by putting () => syntax, if only works when we click */
          onTap: () => setPostOrientation('posts'),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Posts',
              style: TextStyle(
                color: postOrientation == 'posts' ? Colors.blue : Colors.grey,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        GestureDetector(
          /* without () => syntax, setPostOrientation() gets called automatically
          by putting () => syntax, if only works when we click */
          onTap: () => setPostOrientation('claims'),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Claims',
              style: TextStyle(
                color: postOrientation == 'claims' ? Colors.blue : Colors.grey,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: 'Profile',
        removeBackButton: true,
      ),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(),
          buildTogglePostOrientation(),
          Divider(
            height: 0.0,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
