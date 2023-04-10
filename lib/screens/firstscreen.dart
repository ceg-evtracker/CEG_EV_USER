import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({Key? key}) : super(key: key);
  //const FirstScreen({required Key key}) : super(key: key);

  @override
  FirstScreenState createState() => FirstScreenState();
}

class FirstScreenState extends State<FirstScreen> {
  final _themeData = GetStorage();
  bool _isdarkMode = false;
  @override
  void initState() {
    super.initState();
    _themeData.writeIfNull("darkmode", false);
    _isdarkMode = _themeData.read("darkmode");
  }

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EV Tracker'),
      ),
      drawer: _customDrawer(context),
      body: Center(
        child: Container(),
      ),
    );
  }*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _customDrawer(context),
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/map.jfif',
            fit: BoxFit.cover,
          ),
          searchBarUI(),
        ],
      ),
    );
  }

  Widget searchBarUI() {
    return FloatingSearchBar(
      hint: 'Search.....',
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 17),

      openAxisAlignment: 0.0,
      openWidth: 600,
      axisAlignment: 0.0,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 20),
      elevation: 4.0,

      physics: const BouncingScrollPhysics(),
      onQueryChanged: (query) {
        //Your methods will be here
      },
      //showDrawerHamburger: false,
      transitionCurve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 0),
      transition: CircularFloatingSearchBarTransition(),
      debounceDelay: const Duration(milliseconds: 0),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place, color: Colors.grey),
            onPressed: () {
              print('Places Pressed');
            },
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          //color: Colors.grey,
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Material(
            color: Colors.grey,
            child: Container(
              height: 200.0,
              color: Colors.grey,
              child: Column(
                children: const [
                  ListTile(
                    title: Text('Thalam'),
                    subtitle: Text('Boys Hostel,CEG Hostels........'),
                  ),
                  ListTile(
                    title: Text('Main gate'),
                    subtitle: Text('Anna University,SardalPatel road....'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _customDrawer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: const Text("Sanjay Ramasamy"),
              accountEmail: const Text("sanjay19@gmail.com"),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage(
                  "assets/profile.jfif",
                ),
              ),
              decoration: BoxDecoration(
                color: _isdarkMode
                    ? Colors.black
                    : const Color.fromARGB(255, 1, 138, 81),
                /*image: DecorationImage(
                  image: AssetImage("assets/giphy.gif"),
                  fit: BoxFit.cover,
                  ),*/
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.ac_unit),
              title: const Text(
                "Theme",
              ),
              value: _isdarkMode,
              onChanged: (value) {
                setState(() {
                  _isdarkMode = value;
                });
                _isdarkMode
                    ? Get.changeTheme(ThemeData.dark())
                    : Get.changeTheme(ThemeData.light());
                _themeData.write('darkmode', value);
              },
              //activeThumbImage: const AssetImage("assets/half_moon.jfif"),
              //inactiveThumbImage: const AssetImage("assets/sun.png"),
              activeColor: Colors.blue,
              inactiveTrackColor: Colors.black,
            ),
             ActionChip(
                  label: const Text("Logout"),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setBool('isLoggedIn',false);
                    logout(context);
                  }),
              
             
                 
             
            
          ],
        ),
      ),
    );
  
}

Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
  
 
}