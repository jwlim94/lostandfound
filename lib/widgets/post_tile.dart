import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/item.dart';
import 'package:flutter_application_1/pages/item_info.dart';
import 'package:flutter_application_1/widgets/custom_image.dart';

class PostTile extends StatelessWidget {
  final Item item;

  PostTile(this.item);

  showPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ItemInfo(
                  item: item,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImage(item.mediaUrl),
    );
  }
}
