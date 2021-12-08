import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/home.dart';
import 'package:flutter_application_1/redux/state.dart';
import 'package:flutter_application_1/redux/reducer.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final store = Store<AppState>(
    reducer,
    initialState: AppState(currentUser: null),
  );
  runApp(MyApp(store));
}

class MyApp extends StatefulWidget {
  final Store<AppState> store;
  static Store<AppState>? staticStore;

  // const MyApp({Key? key, required this.store}) : super(key: key);
  MyApp(this.store, {Key? key}) : super(key: key) {
    staticStore = this.store;
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  bool _error = false;

  // define an async function to initialize Flutterfire
  void initializedFlutterFire() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializedFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
        store: widget.store,
        child: MaterialApp(
          title: 'Lost & Found',
          theme: ThemeData().copyWith(
            colorScheme: ThemeData()
                .colorScheme
                .copyWith(primary: Colors.blue, secondary: Colors.teal),
          ),
          home: StoreConnector<AppState, AppState>(
              converter: (store) => store.state,
              builder: (context, currentUser) => Home()),
        ));
  }
}
