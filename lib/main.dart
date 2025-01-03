import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grubfinder/person.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'geolocation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grub Finder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink, brightness: Brightness.light),
        /* light theme settings */

        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink, brightness: Brightness.dark),
        /* light theme settings */

        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(title: 'Grub Finder'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool loading = true;
  MapController? _mapController;
  int currentPageIndex = 0;
  Position? currentPos;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return loading
        ? Scaffold(
            body: Center(
                child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Loading, please wait...'),
            ],
          )))
        : Scaffold(
            extendBodyBehindAppBar: false,
            appBar: AppBar(
              title: Text("Grub Finder"),
              centerTitle: true,
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            body: currentPageIndex == 0 ? content() : null,
            bottomNavigationBar: NavigationBar(
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              selectedIndex: currentPageIndex,
              destinations: const <Widget>[
                NavigationDestination(
                  selectedIcon: Icon(Icons.group),
                  icon: Icon(Icons.group_outlined),
                  label: 'People',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.devices),
                  icon: Icon(Icons.devices_outlined),
                  label: 'Devices',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.account_circle),
                  icon: Icon(Icons.account_circle_outlined),
                  label: 'Me',
                ),
              ],
            ),
          );
  }

  Widget content() {
    return FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          minZoom: 1.0,
          maxZoom: 23.0,
          interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag),
          initialZoom: 1.0,
        ),
        children: [
          Theme.of(context).brightness == Brightness.dark
              ? openStreetMapTileLayerDark
              : openStreetMapTileLayer,
          MarkerLayer(markers: [])
        ]);
     /*
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
            return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                  initialCenter: LatLng(position.latitude, position.longitude),
                  minZoom: 1.0,
                  maxZoom: 23.0,
                  interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag),
                  initialZoom: 17.0,
                ),
                children: [
                  Theme.of(context).brightness == Brightness.dark
                      ? openStreetMapTileLayerDark
                      : openStreetMapTileLayer,
                  MarkerLayer(markers: [
                    personMarker(position, _mapController, context)
                  ])
                ]);
          }

          return Center(child: Text('No location data available.'));
        });
      */
  }
}

Widget _darkModeTileBuilder(
  BuildContext context,
  Widget tileWidget,
  TileImage tile,
) {
  return ColorFiltered(
    colorFilter: const ColorFilter.matrix(<double>[
      -0.2126, -0.7152, -0.0722, 0, 255, // Red channel
      -0.2126, -0.7152, -0.0722, 0, 255, // Green channel
      -0.2126, -0.7152, -0.0722, 0, 255, // Blue channel
      0, 0, 0, 1, 0, // Alpha channel
    ]),
    child: tileWidget,
  );
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.wbell.grubfinder',
    );

TileLayer get openStreetMapTileLayerDark => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.wbell.grubfinder',
      tileBuilder: _darkModeTileBuilder,
    );
