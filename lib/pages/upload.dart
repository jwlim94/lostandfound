import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/widgets/progress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as im;
import 'package:uuid/uuid.dart';

import 'home.dart';

class Upload extends StatefulWidget {
  final User? currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController typeController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  // (image_picker: ^0.8.4+4 version) and (image_picker: ^0.7.4 version)
  // this is File because Widget image: FileImage() only accepts File
  File? file;
  bool isUploading = false;
  String postId = Uuid().v4();

  final ImagePicker _picker = ImagePicker();

  // does not work in iso emulator?
  handleTakePhoto() async {
    Navigator.pop(context);
    // final file = await ImagePicker().pickImage(
    //   source: ImageSource.camera,
    //   maxHeight: 675,
    //   maxWidth: 960,
    // );
    // setState(() {
    //   this.file = File(file!.path);
    // });
  }

  // The first default image does not work because there is a known issue
  // to pick HEIC images (the first flower image is HEIC format) with PHPicker
  // implementation.
  // It seems like Apple still has not solved this issue
  handleChooseFromGallery() async {
    Navigator.pop(context);

    // (image_picker: ^0.8.4+4 version)
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    // (image_picker: ^0.7.4 version)
    // final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        // this is to convert XFile to File (image_picker: ^0.8.4+4 version)
        this.file = File(file.path);
        // (image_picker: ^0.7.4 version)
        // file = File(pickedFile!.path);
      });
      // final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      // setState(() {
      //   this.file = File(file!.path);
      // });
    }
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Create Post'),
            children: <Widget>[
              SimpleDialogOption(
                child: const Text('Photo with Camera'),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: const Text('Image from Gallery'),
                onPressed: handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  Container buildSplashScreen() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/upload.svg', height: 260.0),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              child: const Text(
                'Upload Item',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              onPressed: () => selectImage(context),
            ),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    im.Image? imageFile = im.decodeImage(file!.readAsBytesSync());
    // .. syntax is used to chain, quality is for quality of the image(0 - 100)
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(im.encodeJpg(imageFile!, quality: 85));
    setState(() {
      file = compressedImageFile;
      // print(file);
    });
  }

  Future<String?> uploadImage(imageFile) async {
    // 'StorageUploadTask' deprecated to 'UploadTask'
    UploadTask uploadTask =
        storageRef.child('post_$postId.jpg').putFile(imageFile);
    final res = await uploadTask;
    return res.ref.getDownloadURL();
    // uploadTask.then((res) {
    //   return res.ref.getDownloadURL();
    // }).catchError((onError) {
    //   print(onError);
    //   return throw Exception('Exception');
    // });
  }

  // create an item in the firestore
  createPostInFirestore(
      {String? mediaUrl,
      String? type,
      String? color,
      String? title,
      String? description,
      String? location}) {
    itemRef
        .doc(widget.currentUser!.id)
        .collection('userItems')
        .doc(postId)
        .set({
      'postId': postId,
      'ownerId': widget.currentUser!.id,
      'username': widget.currentUser!.username,
      'mediaUrl': mediaUrl,
      'type': type,
      'color': color,
      'title': title,
      'description': description,
      'location': location,
      'timestamp': timestamp,
    });
  }

  updateUserPostCountInFireStore() async {
    DocumentSnapshot doc = await userRef.doc(widget.currentUser!.id).get();
    User user = User.fromDocument(doc);
    final int currentNumPosts = user.numPosts;

    userRef.doc(widget.currentUser!.id).update({
      'numPosts': currentNumPosts + 1,
    });
  }

  handleSubmit() async {
    // set states
    setState(() {
      isUploading = true;
    });

    // compress image
    await compressImage();

    // get mediaUrl
    String? mediaUrl = await uploadImage(file);

    // create post in firestore
    createPostInFirestore(
        mediaUrl: mediaUrl,
        type: typeController.text,
        color: colorController.text,
        title: titleController.text,
        description: descriptionController.text,
        location: locationController.text);

    // update post count in firestore
    updateUserPostCountInFireStore();

    // FIXME: make sure to clear out as well when user went back by back button
    // clearing out
    typeController.clear();
    colorController.clear();
    titleController.clear();
    descriptionController.clear();
    locationController.clear();

    // set states
    setState(() {
      file = null;
      isUploading = false;
      postId = const Uuid().v4();
    });
  }

  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        title: const Text(
          'Post an item',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: const Text(
              'Post',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : const Text(''),

          // image
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      // (image_picker: ^0.8.4+4 version) and (image_picker: ^0.7.4 version)
                      image: FileImage(file!),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),

          // FIXME: make sure to use dropdown menu for choosing the type
          // type
          Row(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 12.0,
                  bottom: 12.0,
                ),
                child: Icon(
                  Icons.list,
                  color: Colors.black,
                  size: 35.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  width: 250.0,
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    autocorrect: false,
                    controller: typeController,
                    decoration: const InputDecoration(
                      hintText: 'What is the type of this item?',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),

          // color
          Row(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 12.0,
                  bottom: 12.0,
                ),
                child: Icon(
                  Icons.colorize,
                  color: Colors.black,
                  size: 35.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  width: 250.0,
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    autocorrect: false,
                    controller: colorController,
                    decoration: const InputDecoration(
                      hintText: 'What is the color of this item?',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),

          // title
          Row(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 12.0,
                  bottom: 12.0,
                ),
                child: Icon(
                  Icons.title,
                  color: Colors.black,
                  size: 35.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  width: 250.0,
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    autocorrect: false,
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'Write a title',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),

          // description
          Row(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 12.0,
                  bottom: 12.0,
                ),
                child: Icon(
                  Icons.description,
                  color: Colors.black,
                  size: 35.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  width: 250.0,
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    autocorrect: false,
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Write a description',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),

          // location
          ListTile(
            leading: const Icon(
              Icons.pin_drop,
              color: Colors.black,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  hintText: 'Where was this item found?',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // get current ocation button
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              label: const Text(
                'Use current location',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: getUserLocation,
              icon: const Icon(
                Icons.my_location,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  getUserLocation() async {
    final GeolocatorPlatform _geoLocatorPlatform = GeolocatorPlatform.instance;
    final position = await _geoLocatorPlatform.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final GeocodingPlatform _geoCodingPlatform = GeocodingPlatform.instance;
    List<Placemark> placemarks = await _geoCodingPlatform
        .placemarkFromCoordinates(position.latitude, position.longitude);
    // this placemark gives a lot of information about the address(user location)
    Placemark placemark = placemarks[0];
    String formattedAddress = '${placemark.locality}, ${placemark.country}';
    locationController.text = formattedAddress;
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
