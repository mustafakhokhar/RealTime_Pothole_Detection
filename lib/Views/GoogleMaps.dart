import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice_ex/places.dart' as webServices;
import 'package:http/http.dart' as http;

class CustomMaps extends StatefulWidget {
  const CustomMaps({Key? key}) : super(key: key);

  @override
  State<CustomMaps> createState() => _CustomMapsState();
}

class _CustomMapsState extends State<CustomMaps> {
  late GoogleMapController mapController;
  TextEditingController startLocationController = TextEditingController();
  TextEditingController endLocationController = TextEditingController();

  LatLng _currentPosition = const LatLng(31.46962997555804, 74.41178582113115);
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  late List<LatLng> polylineCoordinates;
  late Set<Polyline> _polylines;
  List<String> _turnByTurnInstructions = [];

  List<LatLng> potholesCheckpoints = [
    const LatLng(31.471192, 74.411032),
    const LatLng(31.470673, 74.411456),
    const LatLng(31.471604, 74.410675),
    const LatLng(31.471935, 74.410376),
    const LatLng(31.472025, 74.410073),
  ];

  Timer locationUpdateTimer = Timer(const Duration(seconds: 30), () {});

  bool _showSuggestionsStart = false;
  bool _showSuggestionsEnd = false;
  String distanceBetween = '';

  late webServices.PlacesAutocompleteResponse startSuggestions;
  late webServices.PlacesAutocompleteResponse endSuggestions;
  final places = webServices.GoogleMapsPlaces(
      apiKey: 'AIzaSyArxQ3hGHYv7xmzO-5IGzi-2SaeB92kTj0');

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    polylineCoordinates = [];
    _polylines = {};
    startSuggestions = webServices.PlacesAutocompleteResponse(status: 'null');
    endSuggestions = webServices.PlacesAutocompleteResponse(status: 'null');
    startLocationController.addListener(() {
      if (startLocationController.text.isNotEmpty) {
        _autocompleteStartLocation(startLocationController.text);
      }
    });
    endLocationController.addListener(() {
      if (endLocationController.text.isNotEmpty) {
        _autocompleteEndLocation(endLocationController.text);
      }
    });
  }

  @override
  void dispose() {
    startLocationController.dispose();
    endLocationController.dispose();
    locationUpdateTimer?.cancel();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // final marker = Marker(
    //   markerId: const MarkerId('place_name'),
    //   position: _currentPosition,
    //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    //   infoWindow: const InfoWindow(
    //     title: 'title',
    //     snippet: 'address',
    //   ),
    // );
    // setState(() {
    //   markers[const MarkerId('place_name')] = marker;
    // });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 15.0,
                  ),
                  trafficEnabled: true,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: markers.values.toSet(),
                  polylines: _polylines,
                ),
                Positioned(
                  top: 60.0,
                  left: 15.0,
                  right: 15.0,
                  child: Container(
                    height: 50.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                    ),
                    child: TextField(
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _showSuggestionsStart = true;
                          _showSuggestionsEnd = false;
                        }
                      },
                      controller: startLocationController,
                      decoration: InputDecoration(
                        hintText: 'From',
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.only(left: 15.0, top: 15.0),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {},
                          iconSize: 30.0,
                        ),
                      ),
                    ),
                  ),
                ),

                // Suggestions End Overlay
                if (startSuggestions.predictions != null &&
                    _showSuggestionsStart)
                  Visibility(
                    visible: _showSuggestionsStart,
                    child: Positioned(
                      top: 115.0,
                      left: 15.0,
                      right: 15.0,
                      child: Container(
                        height: 200,
                        child: Material(
                          elevation: 4.0,
                          child: ListView.builder(
                            itemCount: startSuggestions.predictions!.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(startSuggestions
                                        .predictions![index].description
                                        .toString()),
                                    onTap: () {
                                      startLocationController.text =
                                          startSuggestions
                                              .predictions![index].description
                                              .toString();
                                      setState(() {
                                        _showSuggestionsStart = false;
                                        _showSuggestionsEnd = false;
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        startSuggestions = webServices
                                            .PlacesAutocompleteResponse(
                                                status: 'null');
                                      });
                                    },
                                  ),
                                  const Divider(),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                if (endSuggestions.predictions != null && _showSuggestionsEnd)
                  Visibility(
                    visible: _showSuggestionsEnd,
                    child: Positioned(
                      top: 115.0,
                      left: 15.0,
                      right: 15.0,
                      child: Container(
                        height: 200,
                        child: Material(
                          elevation: 4.0,
                          child: ListView.builder(
                            itemCount: endSuggestions.predictions!.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(endSuggestions
                                        .predictions![index].description
                                        .toString()),
                                    onTap: () {
                                      endLocationController.text =
                                          endSuggestions
                                              .predictions![index].description
                                              .toString();
                                      setState(() {
                                        _showSuggestionsStart = false;
                                        _showSuggestionsEnd = false;
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        endSuggestions = webServices
                                            .PlacesAutocompleteResponse(
                                                status: 'null');
                                      });
                                    },
                                  ),
                                  const Divider()
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 115.0,
                  left: 15.0,
                  right: 15.0,
                  child: Container(
                    height: 50.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                    ),
                    child: TextField(
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _showSuggestionsStart = false;
                          _showSuggestionsEnd = true;
                        }
                      },
                      controller: endLocationController,
                      decoration: InputDecoration(
                        hintText: 'To',
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.only(left: 15.0, top: 15.0),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {},
                          iconSize: 30.0,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 160,
                  left: 15.0,
                  right: 15.0,
                  child: Container(
                    height: 150,
                    child: ListView.builder(
                      itemCount: _turnByTurnInstructions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_turnByTurnInstructions[index]),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // _getPolylines();
                    _getAlternativeRoutes();
                  },
                  child: const Text('Best Route'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _startJourney();
                  },
                  child: const Text('Start Journey'),
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.blue[100],
                    ),
                    child: Center(
                      child: Text(
                        distanceBetween,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _autocompleteStartLocation(String input) async {
    final response = await places.autocomplete(input);
    setState(() {
      startSuggestions = response;
    });
  }

  Future<void> _autocompleteEndLocation(String input) async {
    final response = await places.autocomplete(input);
    setState(() {
      endSuggestions = response;
    });
  }

  Future<List<LatLng>> _getPolylines() async {
    String apiKey = 'AIzaSyArxQ3hGHYv7xmzO-5IGzi-2SaeB92kTj0';
    String startLocation = startLocationController.text;
    String endLocation = endLocationController.text;

    String apiUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$startLocation&destination=$endLocation&key=$apiKey';

    var response = await http.get(Uri.parse(apiUrl));
    Map values = jsonDecode(response.body);

    List<dynamic> routes = values['routes'];
    dynamic route = routes[0]['overview_polyline']['points'];

    polylineCoordinates.clear();
    _polylines.clear();

    // Calculate distance between start and end locations
    var distance = values['routes'][0]['legs'][0]['distance']['text'];

    setState(() {
      _polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: _convertToLatLng(_decodePoly(route)),
        width: 5,
        color: Colors.blue,
      ));
      distanceBetween = distance;
    });

    // Add marker for start location
    var startLatLng = LatLng(
        values['routes'][0]['legs'][0]['start_location']['lat'],
        values['routes'][0]['legs'][0]['start_location']['lng']);
    _addMarker(startLatLng, 'A',
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen));

    // Add marker for end location
    var endLatLng = LatLng(
        values['routes'][0]['legs'][0]['end_location']['lat'],
        values['routes'][0]['legs'][0]['end_location']['lng']);
    _addMarker(endLatLng, 'B',
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));

    // Parse step-by-step instructions
    var steps = values['routes'][0]['legs'][0]['steps'];
    List<String> turnByTurnInstructions = [];
    for (var step in steps) {
      // Extract HTML instructions and remove HTML tags
      String instruction = step['html_instructions'];
      instruction =
          instruction.replaceAll(RegExp(r'<[^>]*>'), ''); // Remove HTML tags
      turnByTurnInstructions.add(instruction);
    }

    // Now, you can store or display `turnByTurnInstructions` as needed.
    setState(() {
      _turnByTurnInstructions = turnByTurnInstructions;
    });

    // Calculate LatLngBounds for both markers
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        startLatLng.latitude < endLatLng.latitude
            ? startLatLng.latitude
            : endLatLng.latitude,
        startLatLng.longitude < endLatLng.longitude
            ? startLatLng.longitude
            : endLatLng.longitude,
      ),
      northeast: LatLng(
        startLatLng.latitude > endLatLng.latitude
            ? startLatLng.latitude
            : endLatLng.latitude,
        startLatLng.longitude > endLatLng.longitude
            ? startLatLng.longitude
            : endLatLng.longitude,
      ),
    );

    // Animate camera to fit both markers
    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
    return polylineCoordinates;
  }

  void _startJourney() {
    if (startLocationController.text.isEmpty ||
        endLocationController.text.isEmpty) {
      // Show an error message or handle the case where start/end locations are not provided
      return;
    }

    getCurrentLocation2().then((currentPosition) {
      if (currentPosition != null) {
        // Set the start location to the current position
        startLocationController.text =
            "${currentPosition.latitude},${currentPosition.longitude}";
        // Fetch and display the route
        _getPolylines();

        // Update route periodically (e.g., every 30 seconds)
        locationUpdateTimer =
            Timer.periodic(const Duration(seconds: 30), (timer) {
          print("tick");
          _getPolylines();
        });
      } else {
        // Handle the case where current location couldn't be fetched
        // Show an error message or prompt the user to enable location services
      }
    });
  }

  Future<LatLng?> getCurrentLocation2() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    return LatLng(position.latitude, position.longitude);
  }

  void _addMarker(LatLng position, String title, BitmapDescriptor icon) {
    final MarkerId markerId = MarkerId(position.toString());

    // Creating a new marker
    final Marker marker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(
        title: title,
      ),
      icon: icon,
    );

    // Adding a new marker to map
    setState(() {
      markers[markerId] = marker;
    });
  }

  // void _drawRoute(List<LatLng> polylineCoordinates) {
  //   _polylines.clear();
  //   _polylines.add(Polyline(
  //     polylineId: const PolylineId('route'),
  //     points: polylineCoordinates,
  //     width: 5,
  //     color: Colors.blue,
  //   ));
  // }

  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = [];
    int index = 0;
    int len = poly.length;
    int c = 0;
    do {
      var shift = 0;
      int result = 0;
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];
    return lList;
  }

  // Calculate alternative routes considering checkpoints as waypoints
  Future<void> _getAlternativeRoutes() async {
    // Initialize a list to store the alternative routes
    List<List<LatLng>> alternativeRoutes = [];

    // // Loop through each checkpoint to calculate routes
    // for (LatLng checkpoint in potholesCheckpoints) {
    //   // Calculate route between "from" and "to" locations with the current checkpoint
    //   List<LatLng> route = await _calculateRouteWithCheckpoint(checkpoint);

    //   // Add the calculated route to the list of alternative routes
    //   alternativeRoutes.add(route);
    //   print("alternative routes: ${alternativeRoutes.length}");
    // }

    List<List<LatLng>> route =
        await _calculateRouteWithCheckpoint(potholesCheckpoints[0]);
    alternativeRoutes.add(route[0]);

    print(" routes: ${route.length}");

    // Determine the route that avoids the maximum number of checkpoints
    List<LatLng> bestRoute = _findBestRoute(alternativeRoutes);
    print("Best Route: ${bestRoute.length}");

    // Display the best route on the map
    // _displayRouteOnMap(bestRoute);
    setState(() {
      // Add the polyline representing the best route to the map
      _polylines.add(Polyline(
        polylineId: const PolylineId('best_route'),
        points: bestRoute,
        width: 5,
        color: Colors.green,
      ));
    });
  }

  // Calculate route between "from" and "to" locations with a checkpoint
  Future<List<List<LatLng>>> _calculateRouteWithCheckpoint(LatLng checkpoint) async {
    String apiKey = 'AIzaSyArxQ3hGHYv7xmzO-5IGzi-2SaeB92kTj0';
    String startLocation = startLocationController.text;
    String endLocation = endLocationController.text;
    String waypoint = '${checkpoint.latitude},${checkpoint.longitude}';

    // String apiUrl =
    //     'https://maps.googleapis.com/maps/api/directions/json?origin=$startLocation&destination=$endLocation&key=$apiKey&computeAlternativeRoutes=true';

    // var response = await http.get(Uri.parse(apiUrl));
    // Map values = jsonDecode(response.body);

    String apiUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$startLocation&destination=$endLocation&key=$apiKey&alternatives=true';

    var response = await http.get(Uri.parse(apiUrl));
    Map values = jsonDecode(response.body);

    List<dynamic> routes = values['routes'];

    print("Routes: $routes\n");

    print("\nJSON resp: $values\n");

    // dynamic route = routes[0]['overview_polyline']['points'];

    // // Parse polyline coordinates
    // List<LatLng> polylineCoordinates = _convertToLatLng(_decodePoly(route));

    // return polylineCoordinates;
    // Initialize a list to store the polyline coordinates of each route
  List<List<LatLng>> alternativeRoutes = [];

  // Iterate through each route and extract its polyline coordinates
  for (var route in routes) {
    dynamic overviewPolyline = route['overview_polyline']['points'];
    List<LatLng> polylineCoordinates = _convertToLatLng(_decodePoly(overviewPolyline));
    alternativeRoutes.add(polylineCoordinates);
  }

  return alternativeRoutes;

    // String apiKey = 'AIzaSyArxQ3hGHYv7xmzO-5IGzi-2SaeB92kTj0';
    // String startLocation = startLocationController.text;
    // String endLocation = endLocationController.text;
    // String waypoint = '${checkpoint.latitude},${checkpoint.longitude}';

    // String apiUrl =
    //     'https://maps.googleapis.com/maps/api/directions/json?origin=$startLocation&destination=$endLocation&waypoints=$waypoint&key=$apiKey';

    // var response = await http.get(Uri.parse(apiUrl));
    // Map values = jsonDecode(response.body);

    // List<dynamic> routes = values['routes'];
    // dynamic route = routes[0]['overview_polyline']['points'];

    // polylineCoordinates.clear();
    // _polylines.clear();

    // // Calculate distance between start and end locations
    // var distance = values['routes'][0]['legs'][0]['distance']['text'];

    // setState(() {
    //   _polylines.add(Polyline(
    //     polylineId: const PolylineId('route'),
    //     points: _convertToLatLng(_decodePoly(route)),
    //     width: 5,
    //     color: Colors.blue,
    //   ));
    //   distanceBetween = distance;
    // });
  }

  // Find the route that avoids the maximum number of checkpoints
  List<LatLng> _findBestRoute(List<List<LatLng>> alternativeRoutes) {
    // Find the route with the minimum number of checkpoints
    List<LatLng> bestRoute =
        alternativeRoutes.reduce((a, b) => a.length < b.length ? a : b);
    return bestRoute;
  }

  // Display the best route on the map
  void _displayRouteOnMap(List<LatLng> route) {
    // Clear existing polylines
    // _polylines.clear();

    setState(() {
      // Add the polyline representing the best route to the map
      _polylines.add(Polyline(
        polylineId: const PolylineId('best_route'),
        points: route,
        width: 5,
        color: Colors.green,
      ));
    });
  }
}
