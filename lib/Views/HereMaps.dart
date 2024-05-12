
// ---------------------------------------- HERE MAPS -------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:here_sdk/core.dart';
// import 'package:here_sdk/mapview.dart';
// import 'package:geolocator/geolocator.dart';

// class CustomHereMaps extends StatefulWidget {
//   const CustomHereMaps({super.key});

//   @override
//   State<CustomHereMaps> createState() => _CustomHereMapsState();
// }

// class _CustomHereMapsState extends State<CustomHereMaps> {
//   late Position _currentPosition;

//   @override
//   void initState() {
//     super.initState();
//     _determinePosition();
//     getCurrentLocation();
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("Here 1");
//     print("LAT:${_currentPosition.latitude}");
//     print("LONG:${_currentPosition.longitude}");
//     print("Here 2");
//     return HereMap(onMapCreated: _onMapCreated);
//   }

//   // get current location
//   void getCurrentLocation() async {
//     print("Here 3");
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     print("Position: $position");
//     setState(() {
//       _currentPosition = position;
//     });
//   }

//   Future<Position> _determinePosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     // Test if location services are enabled.
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Location services are not enabled.
//       return Future.error('Location services are disabled.');
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       // Permissions are denied forever, handle appropriately.
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }

//     return await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//   }

//   void _onMapCreated(HereMapController hereMapController) {
//     print("Here 4");
//     hereMapController.mapScene.loadSceneForMapScheme(MapScheme.normalDay,
//         (MapError? error) {
//       if (error != null) {
//         print('Map scene not loaded. MapError: ${error.toString()}');
//         return;
//       }

//       const double distanceToEarthInMeters = 8000;
//       MapMeasure mapMeasureZoom =
//           MapMeasure(MapMeasureKind.distance, distanceToEarthInMeters);
//       hereMapController.camera.lookAtPointWithMeasure(
//           // GeoCoordinates(52.530932, 13.384915), mapMeasureZoom);
//           GeoCoordinates(31.469541, 74.411763),
//           mapMeasureZoom);
//       // GeoCoordinates(_currentPosition.latitude, _currentPosition.longitude),
//       // mapMeasureZoom);
//     });
//   }
// }