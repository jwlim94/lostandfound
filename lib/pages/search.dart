import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/item.dart';
import 'package:flutter_application_1/pages/home.dart';
import 'package:flutter_application_1/pages/item_info.dart';
import 'package:flutter_application_1/widgets/custom_dropdown.dart';
import 'package:flutter_application_1/widgets/progress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String itemType = '';

  // state variable for users retrieved to be used in build method
  Future<QuerySnapshot>? searchResultsFuture;

  // ?: query is passed automatically
  handleSearch(String query) {
    // FIXME: only give results where isClaimed false (do compound query)
    query = query.toLowerCase();
    Future<QuerySnapshot> items = itemRef
        .where('type', isGreaterThanOrEqualTo: query)
        .where('type', isLessThan: query + 'z')
        .get();

    setState(() {
      searchResultsFuture = items;
    });
  }

  AppBar buildSearchField() {
    return AppBar(
      toolbarHeight: 70.0,
      leading: const Icon(
        Icons.search,
        color: Colors.black,
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(
            Icons.check,
            color: Colors.black,
          ),
          onPressed: () => handleSearch(itemType),
        ),
      ],
      backgroundColor: Colors.white,
      title: CustomDropDown(
        onSelectedParam: (String type) {
          setState(() {
            itemType = type;
          });
        },
      ),
    );
  }

  buildNoContent() {
    // when we are making a responsive design either portrait or landscape
    // it is good to use MediaQuery object to get the orientation
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      color: Colors.white,
      child: Center(
        // Listview prevents from overflow because it resizes itself
        // when keyboard is open as user try to search for users
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            // in order to use SvgPicture, need to implement dependency
            SvgPicture.asset(
              'assets/images/search-item.svg',
              height: orientation == Orientation.portrait ? 260.0 : 200.0,
            ),
            const Padding(padding: EdgeInsets.only(bottom: 20.0)),
            const Text(
              'Find Items',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 35.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    // Future builder is good to be run in conditional.
    // It does not always run but it runs by condition at some point in the future
    // ERROR: <QuerySnapshot> must be attached in order to retrieve data from snapshot.data.docs
    return FutureBuilder<QuerySnapshot>(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: StaggeredGridView.count(
            crossAxisCount: 4,
            padding: const EdgeInsets.all(2.0),
            children: snapshot.data!.docs.map<Widget>((doc) {
              Item item = Item.fromDocument(doc);
              return ItemResult(item);
            }).toList(),
            staggeredTiles: snapshot.data!.docs
                .map<StaggeredTile>((_) => const StaggeredTile.fit(2))
                .toList(),
            mainAxisSpacing: 3.0,
            crossAxisSpacing: 4.0,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

showItemInfo(context, item) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ItemInfo(
                item: item,
              )));
}

// showing item results from searching
class ItemResult extends StatefulWidget {
  final Item item;

  ItemResult(this.item);

  @override
  _ItemResultState createState() => _ItemResultState();
}

class _ItemResultState extends State<ItemResult> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showItemInfo(context, widget.item),
      child: Card(
        semanticContainer: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CachedNetworkImage(imageUrl: widget.item.mediaUrl),
            Container(
              padding: EdgeInsets.only(
                left: 4.0,
              ),
              child: Text(
                widget.item.title,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
