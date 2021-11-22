import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/widgets/progress.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
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
    setState(() {
      // this is to convert XFile to File (image_picker: ^0.8.4+4 version)
      this.file = File(file!.path);
      // (image_picker: ^0.7.4 version)
      // file = File(pickedFile!.path);
    });
    // final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    // setState(() {
    //   this.file = File(file!.path);
    // });
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
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/upload.svg', height: 260.0),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.deepOrange),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              child: const Text(
                'Upload Image',
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

  createPostInFirestore(
      {String? mediaUrl, String? location, String? description}) {
    postRef
        .doc(widget.currentUser!.id)
        .collection('userPosts')
        .doc(postId)
        .set({
      'postId': postId,
      'ownerId': widget.currentUser!.id,
      'username': widget.currentUser!.username,
      'mediaUrl': mediaUrl,
      'description': description,
      'location': location,
      'timestamp': timestamp,
      'likes': {},
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String? mediaUrl = await uploadImage(file);
    createPostInFirestore(
        mediaUrl: mediaUrl,
        location: locationController.text,
        description: captionController.text);
    // clearing out
    captionController.clear();
    locationController.clear();
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
          'Caption Post',
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
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser!.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: const InputDecoration(
                  hintText: 'Write a caption...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.pin_drop,
              color: Colors.teal,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  hintText: 'Where was this photo taken?',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              label: const Text(
                'Use current location',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => print('get user location'),
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

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
