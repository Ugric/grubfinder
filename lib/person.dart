import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

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
          child: CircleAvatar(
            child: Text("WB"),
          )));
}

void personMenu(Position position, BuildContext context) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Drawer(
            child: ListView(
              children: [
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
