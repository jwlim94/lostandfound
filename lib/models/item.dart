import 'package:cloud_firestore/cloud_firestore.dart';

// Item that want to use accross the app
class Item {
  final String postId;
  final String ownerId;
  final String username;
  final String mediaUrl;
  final String type;
  final String color;
  final String title;
  final String description;
  final String location;
  final bool isReturned;
  //key: userId
  //value: transactionId
  final Map claimedMap;
  //key: userId
  //value: boolean
  final Map currClaimed;
  

  // constuctor
  Item({
    required this.postId,
    required this.ownerId,
    required this.username,
    required this.mediaUrl,
    required this.type,
    required this.color,
    required this.title,
    required this.description,
    required this.location,
    required this.claimedMap,
    required this.currClaimed,
    required this.isReturned,
  });

  // factory method is like a static method
  // Other class can use this without creating an instance
  factory Item.fromDocument(DocumentSnapshot doc) {
    return Item(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      mediaUrl: doc['mediaUrl'],
      type: doc['type'],
      color: doc['color'],
      title: doc['title'],
      description: doc['description'],
      location: doc['location'],
      claimedMap: doc['claimedMap'] as Map,
      currClaimed: doc['currClaimed'] as Map,
      isReturned: doc['isReturned'],
    );
  }
}
