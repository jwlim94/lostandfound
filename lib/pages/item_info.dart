import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemInfo extends StatefulWidget {
  const ItemInfo({Key? key}) : super(key: key);

  @override
  _ItemInfoState createState() => _ItemInfoState();
}

class _ItemInfoState extends State<ItemInfo> {
  // @override
  // void initState() {
  //   super.initState();
  // }

  clearImage(){
    // should go back to the timeline or search page
    print("back button pressed");
  }

  claimItem(){
    print("claim button clicked.");
  }

  Scaffold buildInfoScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: clearImage
        ),
        title: const Text(
          "Item Info",
          style: TextStyle(
            color: Colors.black,
            fontSize: 25.0,
          ),
        ),
        // actions: [
        //   TextButton(
        //     onPressed: () => print('pressed'), 
        //     child: child)
        // ], 
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 220.0,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16/9,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/macbook.jpg'),
                      ),
                    ),
                  )
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,     
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 5.0),
                  margin: const EdgeInsets.only(left: 85.0),
                  child: const Icon(Icons.pin_drop, color: Colors.red, size: 35.0,),
                ),
                Container(
                  // alignment: Alignment.center,
                  width: 250.0,
                  child: const Text(
                    'Talmage room 2021',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
              // child: const ListTile(
              //   leading: Icon(
              //     Icons.pin_drop, color: Colors.red, size: 35.0,),
              //   title: SizedBox(
              //     width: 250.0,
              //     child: Text(
              //       'Talmage room 2021',
              //       style: TextStyle(
              //         fontSize: 15.0,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              // ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                DateTime(2021, 12, 1, 17, 30).toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0  
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 5.0),
              child: const Text(
                'type: laptop',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0  
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 5.0),
              child: const Text(
                'color: gray',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0  
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 5.0),
              child: const Text(
                'description: I could\'ve sold this',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0  
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 5.0),
              child: TextButton(
                onPressed: claimItem, 
                child: Container(
                  width: 220.0,
                  height: 50.0,
                  child: const Text(
                    'claim',
                    style: TextStyle(
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
            ),
          ],
        ),
      )
      
    );
  } 

  @override
  Widget build(BuildContext context) {
    return buildInfoScreen();
  }

  // Scaffold buildUnAuthScreen(){
  //   return Scaffold(
  //     body: Container(
  //       decoration: const BoxDecoration(
  //         gradient: LinearGradient(
  //           begin: Alignment.topRight,
  //           end: Alignment.bottomLeft,
  //           colors: [
  //             Colors.blueGrey,
  //             Colors.orangeAccent,
  //           ]  
  //         ),
  //       ),
  //       alignment: Alignment.center,
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: <Widget>[
  //           const Text(
  //             'LostAndFound',
  //             style: TextStyle(
  //               fontFamily: "Signatra",
  //               fontSize: 90.0,
  //               color: Colors.white,
  //             ),
  //           ),
  //           GestureDetector(
  //             onTap: login,
  //             child: Container(
  //               width: 260.0,
  //               height: 60.0,
  //               decoration: const BoxDecoration(
  //                 image: DecorationImage(
  //                   image:
  //                     AssetImage('assets/images/google_signin_button.png'),
  //                   fit: BoxFit.cover
  //                 ),
  //               ),
  //             )
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  // }
}
