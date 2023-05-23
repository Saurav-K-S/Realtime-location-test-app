// ignore_for_file: avoid_print

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Home());
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
            future: _fbApp,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print('You have an Error!!! ${snapshot.error.toString()}');
                return const Text('ERRORRRR!!!');
              } else if (snapshot.hasData) {
                return const AppBody();
              } else {
                const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return const Text("BLAH");
            }));
  }
}

class AppBody extends StatefulWidget {
  const AppBody({
    super.key,
  });

  @override
  State<AppBody> createState() => _AppBodyState();
}

class _AppBodyState extends State<AppBody> {
  // Location location = Location();
  // late bool _serviceEnabled;

  // late PermissionStatus _permissionGranted;

  // LocationData? _userLocation;

  // // This function will get user location
  // Future<void> _getUserLocation() async {
  //   // Check if location service is enable
  //   _serviceEnabled = await location.serviceEnabled();
  //   if (!_serviceEnabled) {
  //     _serviceEnabled = await location.requestService();
  //     if (!_serviceEnabled) {
  //       return;
  //     }
  //   }

  //   // Check if permission is granted
  //   _permissionGranted = await location.hasPermission();
  //   if (_permissionGranted == PermissionStatus.denied) {
  //     _permissionGranted = await location.requestPermission();
  //     if (_permissionGranted != PermissionStatus.granted) {
  //       return;
  //     }
  //   }
  //   LocationData locationData = await location.getLocation();

  //   print(locationData);
  //   setState(() {
  //     _userLocation = locationData;
  //   });
  // }
  String? lat;
  String? long;
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location Services are Disabled.");
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permissions are Denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permissions are permenantly denied");
    }

    return await Geolocator.getCurrentPosition();
  }

  void _liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high, distanceFilter: 100);

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      lat = position.latitude.toString();
      long = position.longitude.toString();
      setState(() {
        DatabaseReference latitude =
            FirebaseDatabase.instance.ref().child(_controller1.text.toString()).child("Latitude");
        latitude.set(lat);
        DatabaseReference longitude =
            FirebaseDatabase.instance.ref().child(_controller1.text.toString()).child("Longitude");
        longitude.set(long);
      });
    });
  }

  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
                controller: _controller1,
                decoration: const InputDecoration(hintText: "User Id")),
            TextField(
              controller: _controller2,
              decoration: const InputDecoration(hintText: "User Name"),
            ),
            ElevatedButton(
                onPressed: () {
                  _getCurrentLocation().then((value) {
                    lat = '${value.latitude}';
                    long = '${value.longitude}';
                  });
                  setState(() {
                    //_getUserLocation();
                    // if (_userLocation != null) {
                    DatabaseReference userID =
                        FirebaseDatabase.instance.ref().child(_controller1.text.toString()).child("User Id");
                    userID.set(_controller1.text.toString());
                    DatabaseReference userName =
                        FirebaseDatabase.instance.ref().child(_controller1.text.toString()).child("User Name");
                    userName.set(_controller2.text.toString());
                    DatabaseReference latitude =
                        FirebaseDatabase.instance.ref().child(_controller1.text.toString()).child("Latitude");
                    latitude.set(lat);
                    DatabaseReference longitude =
                        FirebaseDatabase.instance.ref().child(_controller1.text.toString()).child("Longitude");
                    longitude.set(long);
                  });
                  _liveLocation();
                  // } else {
                  //   print("NOTTTTTTT");
                  // }
                },
                child: const Icon(Icons.arrow_right_rounded))
          ],
        ),
      ),
    );
  }
}
