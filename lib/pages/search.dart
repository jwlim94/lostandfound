import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/item.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/home.dart';
import 'package:flutter_application_1/pages/item_info.dart';
import 'package:flutter_application_1/widgets/custom_image.dart';
import 'package:flutter_application_1/widgets/progress.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  // this does not need to initialize in init and no need of dispose function
  // this is for clearing when X is clicked in search bar
  TextEditingController searchController = TextEditingController();

  // state variable for users retrieved to be used in build method
  Future<QuerySnapshot>? searchResultsFuture;

  // ?: query is passed automatically
  handleSearch(String query) {
    // to search item without case sensitive
    // query = query.toLowerCase();

    // FIXME: only give results where isClaimed false (do compound query)
    Future<QuerySnapshot> items = itemRef
        .where('type', isGreaterThanOrEqualTo: query)
        .where('type', isLessThan: query + 'z')
        .get();

    setState(() {
      searchResultsFuture = items;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  // FIXME: make it search through dropdown meny by item types
  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          // remove underline border
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,

          hintText: 'Search item by type',

          prefixIcon: const Icon(
            Icons.search,
            size: 28.0,
            color: Colors.black,
          ),

          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            color: Colors.black,
            onPressed: clearSearch,
          ),
        ),
        // ?: this gets called as user types in the text field
        onFieldSubmitted: handleSearch,
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

        /* the reason why ItemResult is made is to store it in the List
        searchResult and item is just the same but Item(Model) cannot be stored as a List*/
        List<ItemResult> searchResults = [];
        snapshot.data!.docs.forEach((doc) {
          Item item = Item.fromDocument(doc);
          ItemResult searchResult = ItemResult(item);
          searchResults.add(searchResult);
        });
        return ListView(
          children: searchResults,
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
class ItemResult extends StatelessWidget {
  final Item item;

  // constructor
  ItemResult(this.item);

  @override
  Widget build(BuildContext context) {
    // FIXME: make a bigger good UI for search result of items
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.all(2.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showItemInfo(context, item),
            child: ListTile(
              leading: cachedNetworkImage(item.mediaUrl),
              title: Text(
                'Type: ' + item.type,
              ),
              subtitle: Text(
                'Color: ' + item.color,
              ),
            ),
          ),
          const Divider(
            height: 2.0,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
