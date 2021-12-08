import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/item.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/home.dart';
import 'package:flutter_application_1/pages/item_info.dart';
import 'package:flutter_application_1/pages/profile.dart';
import 'package:flutter_application_1/widgets/custom_image.dart';
import 'package:flutter_application_1/widgets/progress.dart';
import 'package:string_extensions/string_extensions.dart';

class PostItem extends StatefulWidget {
  final Item item;

  PostItem({required this.item});

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  @override
  Widget build(BuildContext context) {
    showProfile(context) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Profile(
                    profileId: widget.item.ownerId,
                    clickedFromBottomMenu: false,
                  )));
    }

    buildPostHeader(parentContext) {
      return FutureBuilder(
        future: userRef.doc(widget.item.ownerId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(snapshot.data as DocumentSnapshot);
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: () => showProfile(parentContext),
              child: Text(
                user.username,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: Text(widget.item.location),
            trailing: IconButton(
              onPressed: () => print('deleting post'),
              icon: const Icon(Icons.more_vert),
            ),
          );
        },
      );
    }

    showPost(context) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ItemInfo(
                    item: widget.item,
                  )));
    }

    buildPostImage(context) {
      return GestureDetector(
        // what is Stack() widget? => Stack them up!
        onTap: () => showPost(context),
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
      );
    }

    buildPostFooter() {
      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(left: 20.0),
                child: Text(
                  'Type: ' + widget.item.type.capitalize!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(
                  left: 20.0,
                  top: 5.0,
                ),
                child: const Text(
                  'Click on the image to see more in details...',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 10.0)),
          const Divider(
            height: 2.0,
            thickness: 1,
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(context),
        buildPostImage(context),
        const Padding(padding: EdgeInsets.only(top: 10.0)),
        buildPostFooter(),
      ],
    );
  }
}
