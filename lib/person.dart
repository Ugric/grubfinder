import 'dart:convert';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grubfinder/bounds.dart';
import 'package:grubfinder/geolocation.dart';
import 'package:grubfinder/main.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class Person {
  final String id;
  final String name;
  final String? profilePicture;
  final LatLng latLng;

  Person({required this.id,required this.name, required this.profilePicture, required this.latLng});

  // Factory constructor to create a Person from JSON
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
        id: json["id"],
      name: json['name'],
      profilePicture: json['profilePicture'],
      latLng: LatLng(json['lat'].toDouble(), json['lng'].toDouble())
    );
  }
}

String nameToInitials(String name) {
  String initials = name.split(" ").map((name)=>(name.isNotEmpty?name[0]:"")).join("").replaceAll(" ", "");
  return initials.substring(0, min(3, initials.length));
}

class PeopleMap extends StatefulWidget {
  const PeopleMap({super.key, required this.baseURL});

  final String baseURL;

  @override
  State<PeopleMap> createState() => _PeopleMapState();
}

class _PeopleMapState extends State<PeopleMap> {
  late MapController mapController;
  List<Person> people = [];
  bool deleted = false;
  String? following;
  bool isProgrammaticMovement = false;
  bool firstLoad = true;


  @override
  void initState() {
    super.initState();
    mapController = MapController();
    (()async {
      while (!deleted) {
        try {
          await updateLocations();
        } catch (_) {
        }
        await Future.delayed(Duration(seconds: 5));
      }
    })();
  }

  @override
  void dispose() {
    deleted = true;
    super.dispose();
  }

  Future<void> updateLocations() async {
    http.Response resp = await http.get(Uri.parse(widget.baseURL).resolve("api/people"));
    List<Person> peopleTemp = [];
    List<dynamic> jsonData = jsonDecode(resp.body);
    for (int i = 0; i < jsonData.length; i++) {
      Person person = Person.fromJson(jsonData[i]);
      peopleTemp.add(person);
      if (person.id == following) {
        isProgrammaticMovement = true;
        mapController.move(person.latLng, mapController.camera.zoom);
      }
    }
    setState(() {
      people = peopleTemp;
    });
    if (firstLoad && following == null) {
      LatLngBounds bounds = getBoundsFromMarkers(people.map((person)=>person.latLng).toList());

      isProgrammaticMovement = true;
      mapController.fitCamera(CameraFit.bounds(bounds: bounds,padding: EdgeInsets.all(50)));
      firstLoad = false;
    }
  }
  void onMapEvent(MapEvent mapEvent) {
    if (isProgrammaticMovement) {
      // Ignore events triggered programmatically
      isProgrammaticMovement = false; // Reset the flag
      return;
    }
    if (mapEvent is MapEventMove || mapEvent is MapEventMoveEnd) {
      following = null;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerSignal: (pointerSignal) {
          if (pointerSignal is PointerScrollEvent){
            if (pointerSignal.scrollDelta.dy < 0) {
              mapController.move(mapController.camera.center, mapController.camera.zoom+1);
            } else {
              mapController.move(mapController.camera.center, mapController.camera.zoom-1);
            }
          }
        },
        child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          onMapEvent: onMapEvent,
          backgroundColor:
          Theme
              .of(context).colorScheme.surface,
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
          MarkerLayer(markers: people.map((person)=>personMarker(person, mapController, context, (id)=>setState(() {
            isProgrammaticMovement = true;
            following = id;
          }), following)).toList())
        ]));
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

CircleAvatar personProfilePicture(Person person) {
  return person.profilePicture == null?CircleAvatar(
    radius: 30,
    child: Text(nameToInitials(person.name)),
  ):CircleAvatar(
    radius: 30,
    backgroundImage: NetworkImage(person.profilePicture!),
  );
}

Marker personMarker(
    Person person, MapController? mapController, BuildContext context, void Function(String id) onclick, String? following) {
  return Marker(
      point: LatLng(person.latLng.latitude, person.latLng.longitude),
      width: 60,
      height: 60,
      alignment: Alignment.center,
      child: GestureDetector(
          onTap: () {
            mapController?.move(
                LatLng(person.latLng.latitude, person.latLng.longitude), 19);
            if (person.id == following) personMenu(person, context);
            onclick(person.id);
          },
          child: personProfilePicture(person)));
}

void personMenu(Person person, BuildContext context) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Drawer(
          width: MediaQuery.sizeOf(context).width,
            child: ListView(
              children: [
                SizedBox(height: 20),
                Center(child: personProfilePicture(person)),
                ListTile(
                  title: Text(person.name,textAlign: TextAlign.center),
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
