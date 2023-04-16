import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import '../helpers/shared_prefs.dart';
import 'dart:async';
import 'package:web_socket_channel/io.dart';
import 'package:location/location.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_switch/flutter_switch.dart';
import 'package:web_socket_channel/io.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../model/user_model.dart';
import 'login_screen.dart' as login;
import 'package:google_fonts/google_fonts.dart';

import 'login_screen.dart';
import 'registration_screen.dart';


class HomeManagement extends StatefulWidget {
  const HomeManagement({Key? key}) : super(key: key);

  @override
  State<HomeManagement> createState() => _HomeManagementState();
}

class _HomeManagementState extends State<HomeManagement> {
  String? _message;
  bool _isSending = false;
  bool status = false;
  LatLng latLng = getLatLngFromSharedPrefs();
  LatLng loc = getLatLngFromSharedPrefs();
  late CameraPosition _initialCameraPosition;
  late CameraPosition _currentCameraPosition;
  late MapboxMapController controller;
  late MapboxMapController _mapController;
  IOWebSocketChannel? channel;
  Location _location = Location();
  LocationData? _locationData;
  List<String> Locations = [];
  List<Map<String, dynamic>> locations = [
    {'name': 'Vivekananda auditorium', 'lat': 13.0115, 'long': 80.2364},
    {'name': 'Kurinji Hostel', 'lat': 13.0137, 'long': 80.2345},
    {'name': 'Thalam hostel', 'lat': 13.0111, 'long': 80.2314},
    {'name': 'hostel', 'lat': 10.0111, 'long': 80.2314},
  ];
  final TextEditingController _searchController = TextEditingController();
//final MapboxMapController _mapController = MapboxMapController();
  List<Map<String, dynamic>> _filteredLocations = [];

   User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  var Geolocator;

  /*Future<Map<String, dynamic>> fetchPortLocation(int portNumber) async {
    final portNumber = 3000; // Replace with your desired port number
    final locationData = await fetchPortLocation(portNumber);
    final latitude = locationData['latitude'];
    final longitude = locationData['longitude'];

    final response = await http.get(Uri.parse('ws://10.11.150.102:3000'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to retrieve port location');
    }
  }*/

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
    _initialCameraPosition = CameraPosition(target: latLng, zoom: 15);
    channel = IOWebSocketChannel.connect('ws://10.0.2.2:3000');
  }

  _onMapCreated(MapboxMapController controller) async {
    this.controller = controller;
  }

  void _startSending() async {
    setState(() {
      _isSending = true;
    });
    // Timer.periodic(Duration(seconds: 1), (timer) async {
    if (!_isSending) {
      // timer.cancel();
      return;
    }
    String? msg;
    _locationData = await _location.getLocation();

    loc = LatLng(_locationData!.latitude!.toDouble(),
        _locationData!.longitude!.toDouble());

    _currentCameraPosition = CameraPosition(target: loc, zoom: 15);
    msg = loc.toString();
    channel?.sink.add(loc.toString());
  }

  void _stopSending() {
    setState(() {
      _isSending = false;
    });
  }

  void sendMsg(msg) {
    // IOWebSocketChannel? channel;
    // try {
    //   print(_message);
    //   // Connect to our backend.
    //   channel = IOWebSocketChannel.connect('ws://10.0.2.2:3000');
    // } catch (e) {
    //   // If there is any error that might be because you need to use another connection.
    //   print("Error on connecting to websocket: " + e.toString());
    // }
    // Send message to backend
    // channel?.sink.add(msg);

    // Listen for any message from backend
    // channel?.stream.listen((event) {
    //   // Just making sure it is not empty
    //   if (event!.isNotEmpty) {
    //     print(event);
    //     // Now only close the connection and we are done here!
    //     channel!.sink.close();
    //   }
    // });
  }
   int selectedIndex = 0;
  List<IconData> data = [
    Icons.home_outlined,
    Icons.person_outline_sharp
  ];

  _onStyleLoadedCallback() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: MapboxMap(
                accessToken: dotenv.env['MAPBOX_ACCESS_TOKEN'],
                initialCameraPosition: _initialCameraPosition,
                onMapCreated: _onMapCreated,
                onStyleLoadedCallback: _onStyleLoadedCallback,
                myLocationEnabled: true,
                myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
                minMaxZoomPreference: const MinMaxZoomPreference(14, 17),
              ),
            ),
             Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.all(20.0),
        //color: Colors.amber,
        child: Material(
           elevation: 10,
          borderRadius: BorderRadius.circular(20),
          color: Colors.black.withOpacity(0.75),
          child: Container(
            height: 60,
            width: double.infinity,
            child: ListView.builder(
                itemCount: data.length,
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 65),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = i;
                          });
                          if(selectedIndex == 0) {
                             Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeManagement()));
                        
                          }
                          else {
                            showModalBottomSheet(
                              backgroundColor: Colors.transparent,
                              context: context, 
                            shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(20.0),),
                            builder: ((context) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height / 2.8,
                                color: Colors.white.withOpacity(0),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(
                                      bottom: 0,
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: 170,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(50),
                                            topLeft: Radius.circular(50))
                                          )
                                        ),
                                    ),
                                    Positioned(
                                      top: 100,
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Color.fromARGB(255, 46, 46, 46),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),

                                    )),
                                    Positioned(
                                      top: 190,
                                      child: Text(
                                        "${loggedInUser.name}",
                                        style: GoogleFonts.yantramanav(
                                          color: Colors.black,
                                          fontSize: 30,
                                          fontWeight: FontWeight.w800,
                                        )
                                      )
                                    ),
                               Column(
                                  children: <Widget>[
                                    SizedBox(height: 200,),
                  Divider(
                    height: 60,
                    thickness: 1.0,
                    color: Colors.black,
                    indent: 32,
                    endIndent: 32,                     
                  ),
             
                  Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerRight,
      child: Icon(
        Icons.exit_to_app,
        size: 30,
        
        color: Colors.black,
      ),
    ),
              GestureDetector(
                onTap: ()async {
                      final prefs = await SharedPreferences.getInstance();
                    prefs.setBool('isLoggedIn',false);
                    logout(context);
                },
              child: Text(
                ' Logout',
              style:  GoogleFonts.raleway(
                color: Colors.black,
                fontSize: 27.0,
                fontWeight: FontWeight.w500,
              
              ),
              ),
              ),
            ],
          ),
        ),
            ],
                                  ),
                                  ],
                                )
                              );
                                }));
                          }
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 250),
                          width: 35,
                          decoration: BoxDecoration(
                            border: i == selectedIndex
                                ? Border(
                                    top: BorderSide(
                                        width: 3.0, color: Colors.white))
                                : null,
                            gradient: i == selectedIndex
                                ? LinearGradient(
                                    colors: [
                                        Colors.grey.shade800,
                                        Colors.black
                                      ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter)
                                : null,
                          ),
                          child: Icon(
                            data[i],
                            size: 35,
                            color: i == selectedIndex
                                ? Colors.white
                                : Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                    scrollDirection: Axis.horizontal,
                    ),
          ),
        ),
      ),
            /* StreamBuilder(
                stream: IOWebSocketChannel.connect('ws://10.0.2.2:3000').stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData) {
                    return Text('Connecting...');
                  } else {
                    final latlongData = snapshot.data;
                    Object? myObject = latlongData;
                    String myString = (myObject ?? '') as String;
                    var lat = myString.substring(10, 20);
                    var long = myString.substring(22, 28);
                    final messageDatalat = jsonDecode(lat);
                    final messageDatalong = jsonDecode(long);

                    //final latitude = messageDatalat['latitude'];
                    //final longitude = messageDatalong['longitude'];
                    final marker = MarkerOptions(
                      //geometry: LatLng(latitude, longitude),
                      geometry: LatLng(messageDatalat, messageDatalong),

                      iconImage: 'assets/mapbox.png',
                      iconSize: 1.5,
                    );
                    //controller.addMarker(MarkerOptions());

                    //double driverloc = double.parse(latlongData);
                    // final lat = latlongData['lat'];
                    // final long = latlongData['long'];
                    return Text('Latitude: $latlongData');
                  }
                }),*/
                SizedBox(height: 20,),
            searchBarUI(),
            /* Positioned(
              top: 4,
              height: 50,
              width: 500,
              left: 60,
              child: DropdownButton<String>(
                iconEnabledColor: Colors.blue,
                //borderRadius: BorderRadius.circular(30),
                dropdownColor: Colors.red,
                value: _selectedLocation,
                onChanged: (value) {
                  setState(() {
                    _selectedLocation = value!;
                    _goToLocationOnMap(value);
                  });
                },
                items: locations
                    .map((location) => DropdownMenuItem<String>(
                          child: Text(location['name']),
                          value: location['name'],
                        ))
                    .toList(),
              ),
            )*/
          ],
        )),
        floatingActionButton: Stack(
          children: [
            Positioned(
              bottom: 80.0,
              right: 16.0,
              child: FloatingActionButton(
                 backgroundColor: Colors.black.withOpacity(0.7),
                onPressed: () {
                  controller.animateCamera(
                      CameraUpdate.newCameraPosition(_initialCameraPosition));
                },
                child: Icon(Icons.my_location),
              ),
            ),
            Positioned(
              bottom: 145.0,
              left: 320.0,
              child: FloatingActionButton(
                backgroundColor: Colors.black.withOpacity(0.7),
                onPressed: () {
                  // Add your onPressed logic here
                  _message = "Hello World!";
                  _message = latLng.toString();
                  if (_message!.isNotEmpty) {
                    if (_isSending == false) {
                      _isSending = true;
                      _startSending();
                    } else {
                      _isSending = false;
                      _stopSending();
                    }
                    // sendMsg(_message);
                  }
                  controller.animateCamera(
                      CameraUpdate.newCameraPosition(_currentCameraPosition));
                },
                child: Icon(Icons.back_hand_outlined),
              ),
            ),
          ],
        ));
  }

  Widget searchBarUI() {
    String _selectedLocation = 'Vivekananda auditorium';
    //return Column(
    // children: [
    return FloatingSearchBar(
      hint: 'Search.....',
      openAxisAlignment: 0.0,
      openWidth: 600,
      axisAlignment: 0.0,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 20),
      elevation: 4.0,

      physics: BouncingScrollPhysics(),
      onQueryChanged: (query) {
        setState(() {
          _filteredLocations = locations
              .where((location) =>
                  location['name'].toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      },
      //showDrawerHamburger: false,
      transitionCurve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 500),
      transition: CircularFloatingSearchBarTransition(),
      debounceDelay: const Duration(milliseconds: 500),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: Icon(Icons.place),
            onPressed: () {
              print('Places Pressed');
            },
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Material(
            color: Colors.white,
            child: Container(
              height: 300.0,
              color: Colors.white,
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredLocations.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_filteredLocations[index]['name']),
                        onTap: () {
                          String selectedListItem =
                              _filteredLocations[index]['name'];
                          _goToLocationOnMap(selectedListItem);
                          // print(selectedListItem);
                          // handle location selection
                          /* setState(() {
                  selectedLatLng = (_filteredLocations[index] as String?)!;
                  _goToLocationOnMap(selectedLatLng!);
                });*/
                          /* double lat = _filteredLocations[index]['lat'];
                double long = _filteredLocations[index]['long'];

                if (kDebugMode) {
                  print('Latitude: $lat, Longitude: $long');
                }*/
                        },
                      );
                    },
                  ),
                  /*ListTile(
                        title: Text('Home'),
                        subtitle: Text('more info here........'),
                      ),*/
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _goToLocationOnMap(String locationName) {
    final location =
        locations.firstWhere((location) => location['name'] == locationName);
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location['lat'], location['long']),
        14,
      ),
    );
  }
   Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
        Navigator.pushReplacementNamed(context, '/login');
  }
}

MarkerOptions(
    {required LatLng geometry,
    required String iconImage,
    required double iconSize}) {}
