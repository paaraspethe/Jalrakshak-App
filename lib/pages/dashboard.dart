import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project4/pages/education.dart';
import 'package:project4/pages/feedback.dart';
import 'package:project4/pages/flowanalyser.dart';
import 'package:project4/pages/home_page.dart';
import 'package:project4/pages/profile.dart';
import 'package:project4/pages/reward.dart';
import 'package:location/location.dart' as loc;
import 'package:project4/pages/water%20usage.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late bool _serviceEnabled;
  loc.LocationData? _userLocation;
  late loc.PermissionStatus _permissionGranted;
  String locality = '';
  String country = '';
  String locationDisplay = '';

  List<String> imgData = [
    "images/water usage.png",
    "images/flow analyser.png",
    "images/complaint.png",
    "images/edu.png",
    "images/rewards.png",
    "images/feedback.png"
  ];

  List<String> titles = [
    "Water Usage",
    "Flow Analyser",
    "Complaints",
    "Tips to Save Water",
    "Rewards",
    "Feedback"
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10.0),
                child: buildTopBar(context),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15, top: 10),
                child: buildTitle(),
              ),
              SizedBox(height: 10),
              buildGrid(context),
              SizedBox(height: 30),
              buildFooter(), // Custom footer added here
              SizedBox(height: 10), // Optional spacing after the footer

            ],
          ),
        ),
      ),
    );
  }

  Row buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            buildCircleAvatar(Icons.location_on, () {
              _getUserLocation();
            }),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locality,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  country,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        buildCircleAvatar(Icons.person, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
        }),
      ],
    );
  }


  CircleAvatar buildCircleAvatar(IconData icon, VoidCallback onTap) {
    return CircleAvatar(
      backgroundColor: Colors.blueAccent.withOpacity(0.1),
      radius: 25,
      child: IconButton(
        icon: Icon(icon, color: Colors.blueAccent, size: 35),
        onPressed: onTap,
      ),
    );
  }

  Text buildTitle() {
    return Text(
      "JalRakshak",
      style: GoogleFonts.openSans(
          color: Colors.blueAccent, fontSize: 30, fontWeight: FontWeight.bold),
    );
  }

  GridView buildGrid(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        mainAxisSpacing: 10, // Increased spacing between rows
        crossAxisSpacing: 10, // Increased spacing between columns
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: imgData.length,
      itemBuilder: (context, index) {
        return buildGridItem(context, index);
      },
    );
  }

  InkWell buildGridItem(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        navigation(context, index);
      },
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.blueAccent.withOpacity(0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imgData[index],
              width: 80,
            ),
            SizedBox(height: 8),
            Text(
              titles[index],
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }

  void navigation(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = HomePage(); // Replace with actual WaterUsage page
        break;
      case 1:
        page = FlowAnalyser(); // Replace with actual FlowAnalyser page
        break;
      case 2:
        page = AddNote(); // Replace with actual Complaints page
        break;
      case 3:
        page = Edu(); // Replace with actual Education page
        break;
      case 4:
        page = RewardsPage(); // Replace with actual Rewards page
        break;
      case 5:
        page = MyFeedback(); // Replace with actual Feedback page
        break;
      default:
        return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<void> _getUserLocation() async {
    loc.Location location = loc.Location();
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    final locationData = await location.getLocation();
    setState(() {
      _userLocation = locationData;
    });

    if (_userLocation != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _userLocation!.latitude!, _userLocation!.longitude!);
      Placemark place = placemarks[0];

      setState(() {
        locality = place.locality ?? 'Unknown';
        country = place.country ?? 'Unknown';
        locationDisplay = '$locality, $country';
      });
    }
  }
}

Widget buildFooter() {
  return Padding(
    padding: EdgeInsets.only(bottom: 10),
    child: Text(
      "Made by Team Sigma",
      style: GoogleFonts.bebasNeue(
        color: Colors.blueAccent,
        fontSize: 20,
        fontStyle: FontStyle.italic,
      ),
      textAlign: TextAlign.center,
    ),
  );
}

