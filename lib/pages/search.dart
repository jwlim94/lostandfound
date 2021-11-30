import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/home.dart';
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
    Future<QuerySnapshot> users =
        userRef.where('displayName', isGreaterThanOrEqualTo: query).get();

    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        cursorColor: Colors.teal,
        decoration: InputDecoration(
          hintText: 'Search for a user...',
          filled: true,
          // bottom line color when focused
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.teal),
          ),
          prefixIcon: const Icon(
            Icons.account_box,
            size: 28.0,
            color: Colors.teal,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            color: Colors.teal,
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
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
      child: Center(
        // Listview prevents from overflow because it resizes itself
        // when keyboard is open as user try to search for users
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            // in order to use SvgPicture, need to implement dependency
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 300.0 : 200.0,
            ),
            const Text(
              'Find Users',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60.0,
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
        // the reason why UserResult is made is to store it in the List
        // searchResult and user is just the same but User(Model) cannot be stored as a List
        List<UserResult> searchResults = [];
        snapshot.data!.docs.forEach((doc) {
          // This step is needed to deserialize the documents
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
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

// showing the results from searching
class UserResult extends StatelessWidget {
  final User user;

  // constructor
  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => print('tapped'),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user.username,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // Divider() is used to divide each child in children
          const Divider(
            height: 2.0,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
