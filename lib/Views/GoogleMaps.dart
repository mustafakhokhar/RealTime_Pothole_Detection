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
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    final marker = Marker(
      markerId: const MarkerId('place_name'),
      position: _currentPosition,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(
        title: 'title',
        snippet: 'address',
      ),
    );
    setState(() {
      markers[const MarkerId('place_name')] = marker;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15.0,
            ),
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
                  contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {},
                    iconSize: 30.0,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 170.0,
            left: 280.0,
            right: 15.0,
            child: Container(
              height: 50.0,
              width: double.infinity,
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
          // Suggestions End Overlay
          if (startSuggestions.predictions != null && _showSuggestionsStart)
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
                                startLocationController.text = startSuggestions
                                    .predictions![index].description
                                    .toString();
                                setState(() {
                                  _showSuggestionsStart = false;
                                  _showSuggestionsEnd = false;
                                  startSuggestions =
                                      webServices.PlacesAutocompleteResponse(
                                          status: 'null');
                                });
                              },
                            ),
                            Divider(),
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
                                endLocationController.text = endSuggestions
                                    .predictions![index].description
                                    .toString();
                                setState(() {
                                  _showSuggestionsStart = false;
                                  _showSuggestionsEnd = false;
                                  endSuggestions =
                                      webServices.PlacesAutocompleteResponse(
                                          status: 'null');
                                });
                              },
                            ),
                            Divider()
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
                  contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {},
                    iconSize: 30.0,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 15.0,
            right: 15.0,
            child: ElevatedButton(
              onPressed: () {
                _getPolylines();
              },
              child: const Text('Show Route'),
            ),
          ),
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

  Future<void> _getPolylines() async {
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

  void _drawRoute(List<LatLng> polylineCoordinates) {
    _polylines.clear();
    _polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      points: polylineCoordinates,
      width: 5,
      color: Colors.blue,
    ));
  }

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
}
