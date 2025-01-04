import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grubfinder/geolocation.dart';
import 'package:grubfinder/main.dart';
import 'package:latlong2/latlong.dart';

class Person {
  final String name;
  final String? profilePicture;
  final LatLng latLng;

  Person({required this.name, required this.profilePicture, required this.latLng});

  // Factory constructor to create a Person from JSON
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'],
      profilePicture: json['profilePicture'],
      latLng: LatLng(json['lat'], json['lng'])
    );
  }
}

class PeopleMap extends StatefulWidget {
  const PeopleMap({super.key});

  @override
  State<PeopleMap> createState() => _PeopleMapState();
}

class _PeopleMapState extends State<PeopleMap> {
  MapController? mapController;


  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {

    return FlutterMap(
        mapController: mapController,
        options: MapOptions(
          backgroundColor:
          Theme
              .of(context)
              .brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          minZoom: 1.0,
          maxZoom: 23.0,
          interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag),
          initialZoom: 1.0,
        ),
        children: [
          openStreetMapTileLayer(Theme
              .of(context)
              .brightness == Brightness.dark),

        ]);
    return FutureBuilder<Position>(
        future: determinePosition(),
        builder: (context, snapshot) {
          // Show loading screen while waiting
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Handle errors if any occur while getting location
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Once location is obtained, show the map
          if (snapshot.hasData) {
            Position position = snapshot.data!;
          }

          return Center(child: Text('No location data available.'));
        });
  }
}

CircleAvatar personProfilePicture() {
  return CircleAvatar(
    radius: 30,
    child: Text("WB"),
  );
}

Marker personMarker(
    Position position, MapController? mapController, BuildContext context) {
  return Marker(
      point: LatLng(position.latitude, position.longitude),
      width: 60,
      height: 60,
      alignment: Alignment.center,
      child: GestureDetector(
          onTap: () {
            mapController?.move(
                LatLng(position.latitude, position.longitude), 19);
            personMenu(position, context);
          },
          child: personProfilePicture()));
}

void personMenu(Position position, BuildContext context) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Drawer(
          width: MediaQuery.sizeOf(context).width,
            child: ListView(
              children: [
                SizedBox(height: 20),
                Center(child: personProfilePicture()),
                ListTile(
                  title: Text("William Bell",textAlign: TextAlign.center),
                ),
                ListTile(
                  leading: Icon(Icons.message),
                  title: Text('Messages'),
                ),
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Profile'),
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ],
            ));
      });
}
