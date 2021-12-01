import 'package:cloud_firestore/cloud_firestore.dart';

// User that want to use accross the app
class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String phoneNumber;
  final int numPosts;
  final int numClaims;
  // final String bio;

  // constuctor
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.displayName,
    required this.phoneNumber,
    required this.numPosts,
    required this.numClaims,
    // required this.bio,
  });

  // factory method is like a static method
  // Other class can use this without creating an instance
  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      phoneNumber: doc['phoneNumber'],
      numPosts: doc['numPosts'],
      numClaims: doc['numClaims'],
      // bio: doc['bio'],
    );
  }
}
