import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/item.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/home.dart';
import 'package:flutter_application_1/widgets/custom_image.dart';
import 'package:flutter_application_1/widgets/header.dart';
import 'package:flutter_application_1/widgets/progress.dart';
import 'package:string_extensions/string_extensions.dart';
import 'package:uuid/uuid.dart';

class ItemInfo extends StatefulWidget {
  final Item item;

  ItemInfo({required this.item});

  @override
  _ItemInfoState createState() => _ItemInfoState();
}

class _ItemInfoState extends State<ItemInfo> {
  late bool isAuthor;
  late bool hasClaimed;
  late Item itemUpToDate;
  late bool isApproved;
  bool isLoading = true;
  User? currentUser;
  late var claimedMapUpToDate;
  List<User> claimersList = [];

  @override
  void initState() {
    super.initState();
    currentUser = MyApp.staticStore!.state.currentUser;
    
    if (currentUser?.id == widget.item.ownerId) {
      fetchThoseWhoClaimed();
      setState(() {
        isAuthor = true;
        isLoading = false; 
      });
    } else {
      fetchItem();
      checkIfClaimed();
      setState(() {
        isAuthor = false;
        isLoading = false;
      });
    }
  }

  checkIfClaimed() async { 
    //key: userId of those who have claimed and not cancelled
    //value: boolean
    if (widget.item.currClaimed[currentUser!.id] == true) {
      setState(() {
        hasClaimed = true;
      });
    } else {
      setState(() { 
        hasClaimed = false;
      });
    }
  }

  fetchItem() async {
    Item item = Item.fromDocument(await itemRef.doc(widget.item.postId).get());
    setState(() {
      itemUpToDate = item;
      claimedMapUpToDate = itemUpToDate.claimedMap;
    });
  }

  fetchThoseWhoClaimed() async {
    await fetchItem();
    List<User> userList = [];
    var currClaimed = (claimedMapUpToDate == null ? itemUpToDate : widget.item.currClaimed) as Map;
    for (String k in currClaimed.keys) {
        userList.add(User.fromDocument(await userRef.doc(k).get()));
    }
    setState(() {
      claimersList = userList;
    });
  }

  handleClaim() async {
    //Update claimed Map
    
    if (!widget.item.claimedMap.containsKey(currentUser!.id)) {
      String transactionId = Uuid().v4();
      itemRef.doc(widget.item.postId).update({
        'claimedMap.${currentUser!.id}': transactionId,
        'currClaimed.${currentUser!.id}': true,
      });

      claimedMapUpToDate[currentUser!.id] = transactionId;

      //Create Transaction
      transactionRef.doc(transactionId).set({
        'transactionId': transactionId,
        'timestamp': timestamp,
        'isApproved': false,
        'isDeclined': false,
        'isCancelled': false,
        'itemId': widget.item.postId,
        'founderId': widget.item.ownerId
      });
    } else {
      String transactionId = widget.item.claimedMap[currentUser!.id];
      itemRef.doc(widget.item.postId).update({
        'currClaimed.${currentUser!.id}': true,
      });
      transactionRef.doc(transactionId).update({
        'isCancelled': false
      });
    }
    setState(() {
      hasClaimed = true;
    });
    
  }

  handleUnclaim() async {
    String transactionId = claimedMapUpToDate[currentUser!.id];
    itemRef.doc(widget.item.postId).update({
        'currClaimed.${currentUser!.id}': false,
      });
    transactionRef.doc(transactionId).update({
      'isCancelled': true
    });

    setState(() {
      hasClaimed = false;
    });
  }

  approveClaim(String userId) async {
    //Not dynamic 
    String transactionId = widget.item.claimedMap[userId];
    await transactionRef.doc(transactionId).update({
      'isApproved': true,
    });
    await itemRef.doc(widget.item.postId).update({
      'isReturned': true,
    });
  }

  Scaffold buildInfoScreen(context) {
    return Scaffold(
        appBar: header(
          context,
          titleText: widget.item.title,
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(
                  top: 32.0,
                ),
              ),
              // image
              SizedBox(
                height: 220.0,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
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
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
              ),

              // type
              ListTile(
                leading: const Icon(
                  Icons.list,
                  color: Colors.black,
                  size: 35.0,
                ),
                title: Container(
                  width: 250.0,
                  child: Text(
                    widget.item.type.capitalize!,
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Color
              ListTile(
                leading: const Icon(
                  Icons.colorize,
                  color: Colors.black,
                  size: 35.0,
                ),
                title: Container(
                  width: 250.0,
                  child: Text(
                    widget.item.color,
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // location
              ListTile(
                leading: const Icon(
                  Icons.pin_drop,
                  color: Colors.red,
                  size: 35.0,
                ),
                title: Container(
                  width: 250.0,
                  child: Text(
                    widget.item.location,
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // timestamp
              FutureBuilder(
                future: itemRef.doc(widget.item.postId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return circularProgress();
                  }
                  Timestamp time =
                      (snapshot.data as DocumentSnapshot).get('timestamp');

                  return ListTile(
                    leading: const Icon(
                      Icons.date_range,
                      color: Colors.orange,
                      size: 35.0,
                    ),
                    title: Container(
                      width: 250.0,
                      child: Text(
                        time.toDate().toString(),
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),

              // description
              ListTile(
                leading: const Icon(
                  Icons.description,
                  color: Colors.black,
                  size: 35.0,
                ),
                title: Container(
                  width: 250.0,
                  child: Text(
                    widget.item.description,
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Divider(),
              widget.item.isReturned
                ? Text("This item has already been returned.")
                : claimSection(context)    
              ],
            ),
          ),
    );
  }


  Widget claimSection(BuildContext context) {
    return isLoading 
      ? circularProgress()
        : isAuthor 
          ? ListView.builder(
            shrinkWrap: true,
            itemCount: claimersList.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: const Icon(
                  Icons.person,
                  color: Colors.grey,
                  size: 35.0,
                ),
                trailing: ElevatedButton(
                  onPressed: (() => approveClaim(claimersList[index].id)), 
                  child: Text("Return"),
                ),
                title: Container(
                  width: 250.0,
                  child: Text(
                    claimersList[index].displayName,
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }
          ) 
          : Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 5.0),
            child: TextButton(
              onPressed: hasClaimed ? handleUnclaim : handleClaim,
              child: Container(
                width: 200.0,
                height: 40.0,
                child: Text(
                  hasClaimed ? 'Unclaim' : 'Claim',
                  style: const TextStyle(
                    fontSize: 20.0,
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
                  borderRadius: BorderRadius.circular(15),
                ),
            ),
          ),
        );
  }

  

  @override
  Widget build(BuildContext context) {
    return buildInfoScreen(context);
  }
}
