import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/create_account.dart';
import 'package:flutter_application_1/pages/profile.dart';
import 'package:flutter_application_1/pages/search.dart';
import 'package:flutter_application_1/pages/timeline.dart';
import 'package:flutter_application_1/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

// global variables. This is available anywhere.
final GoogleSignIn googleSignIn = GoogleSignIn();
// google signin for android
final authHeaders = googleSignIn.currentUser!.authHeaders;
// 'StorageReference' deprecated to 'Reference'
final Reference storageRef = FirebaseStorage.instance.ref();
final userRef = FirebaseFirestore.instance.collection('users');
final postRef = FirebaseFirestore.instance.collection('posts');
final itemRef = FirebaseFirestore.instance.collection('items');
final DateTime timestamp = DateTime.now();
User? currentUser;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  late PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();

    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });

    // FIXME: this makes the screen show twice. How can we prevent that?
    // Reauthenticate user when app is opened
    // this method returns a Promise
    // googleSignIn.signInSilently(suppressErrors: false).then((account) {
    //   handleSignIn(account);
    // }).catchError((err) {
    //   print('Error signing in: $err');
    // });
  }

  handleSignIn(GoogleSignInAccount? account) {
    if (account != null) {
      createUserInFirestore();

      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    // 1. check if user exists in users collection in database (accordding to their id)
    final user = googleSignIn.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await userRef.doc(user.id).get();

      // 2. if the user does not exist, then we want to take them to the create account page
      if (!doc.exists) {
        // 3. get username and phoneNumber from create account
        final info = await Navigator.push(
            context, MaterialPageRoute(builder: (context) => CreateAccount()));
        final username = info.username;
        final phoneNumber = info.phoneNumber;

        // 4. use the retrieved username to make new user document in users collection
        userRef.doc(user.id).set({
          'id': user.id,
          'username': username,
          'photoUrl': user.photoUrl,
          'email': user.email,
          'displayName': user.displayName,
          'phoneNumber': phoneNumber,
          // 'bio': '',
          'timestamp': timestamp,
          'numPosts': 0,
          'numClaims': 0,
        });

        // update the doc since some property has changed (ex. username)
        doc = await userRef.doc(user.id).get();
      }
      // currentUser is a logged in user
      // now currentUser can be used by passing through param to each pages where needed
      currentUser = User.fromDocument(doc);
      print(currentUser);
      print(currentUser!.username);
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    // jumpToPage() to snaps to the page
    // pageController.jumpToPage(
    //   pageIndex,
    // );

    // animateToPage() provides adding page animations
    pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(currentUser: currentUser),
          // ElevatedButton(
          //   onPressed: logout,
          //   child: const Text('Logout'),
          //   style: ElevatedButton.styleFrom(
          //     primary: Colors.black,
          //   ),
          // ),
          Upload(currentUser: currentUser),
          const Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: Colors.blue,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.whatshot),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.upload_file),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
            ),
          ]),
    );
    // logout button
    // return ElevatedButton(
    //   onPressed: logout,
    //   child: Text('Logout'),
    //   style: ElevatedButton.styleFrom(
    //     primary: Colors.black,
    //   ),
    // );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          // gradient: LinearGradient(
          //   begin: Alignment.topRight,
          //   end: Alignment.bottomLeft,
          //   colors: [
          //     Theme.of(context).colorScheme.primary.withOpacity(0.3),
          //     Theme.of(context).colorScheme.secondary,
          //   ],
          // ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Lost & Found',
              style: TextStyle(
                fontFamily: 'Signatra',
                fontSize: 90.0,
                color: Colors.blue,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: GestureDetector(
                onTap: login,
                child: Container(
                  width: 260.0,
                  height: 60.0,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image:
                          AssetImage('assets/images/google_signin_button.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
