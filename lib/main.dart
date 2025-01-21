
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grubfinder/person.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const apiVersion = "0.0.1";

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
      builder: FToastBuilder(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange, brightness: Brightness.light),
        /* light theme settings */

        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange, brightness: Brightness.dark),
        /* light theme settings */

        useMaterial3: true,
      ),
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
  late FToast fToast;
  bool initilised = false;
  String baseURL = "";
  SharedPreferences? storage;
  int currentPageIndex = 0;
  TextEditingController txtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    // if you want to use context from globally instead of content we need to pass navigatorKey.currentContext!
    fToast.init(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
      SharedPreferences.getInstance().then((storage_) {
        setState(() {
          storage = storage_;
          loading = false;
          if (kIsWeb) {
            initilised = true;
            baseURL="/";
          } else {
            initilised = storage!.getBool('init') ?? false;
            baseURL = storage!.getString('url') ?? "";
          }
        });
      });

  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
          body: Center(
              child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Loading, please wait...'),
        ],
      )));
    } else if (!initilised) {

      /*return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                TextFormField(
                  controller: txtController,
                  onSaved: (value) =>
                      setState(() {baseURL = value!;}),
                  textCapitalization: TextCapitalization.none,
                  spellCheckConfiguration: SpellCheckConfiguration(
                    spellCheckService: null,
                  ),
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Server URL',
                      hintText: "https://example.com/"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      loading = true;
                    });
                    try {
                      if (!(Uri.tryParse(txtController.text)?.hasAbsolutePath ?? false)) {
                        setState(() {
                          loading = false;
                        });
                        return showToast(fToast, "Invalid URL: $txtController.text");
                      }
                      http.Response resp =
                          await http.get(Uri.parse(widget.baseURL).resolve("api/version"));
                      if (resp.statusCode != 200) {
                        setState(() {
                          loading = false;
                        });
                        return showToast(fToast, "Invalid Grub Finder Server, got status code ${resp.statusCode}");
                      }
                      if (apiVersion != jsonDecode(resp.body)) {
                        showToast(fToast, "Warning: apps API version and servers do not match.");
                      }
                      setState(() {
                        initilised = true;
                        loading = false;
                        baseURL = txtController.text;
                      });
                      storage!.setString("url", baseURL);
                        storage!.setBool("init", true);
                      } catch (e) {
                      setState(() {
                        loading = false;
                      });
                      return showToast(fToast, "There was an error.");
                    }
                  },
                  child: const Text('Submit'),
                )
              ])));*/
    }
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: content().elementAt(currentPageIndex),
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

  List<Widget> content() {
    /*
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
          openStreetMapTileLayer(Theme.of(context).brightness == Brightness.dark),
          MarkerLayer(markers: [])
        ]);
     */
    return [PeopleMap(baseURL: baseURL), const SizedBox.shrink(), const SizedBox.shrink()];
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

TileLayer openStreetMapTileLayer(bool darkMode) => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.wbell.grubfinder',
      tileBuilder: darkMode ? _darkModeTileBuilder : null,
    );
