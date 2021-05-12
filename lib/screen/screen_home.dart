import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_work_with_map/main.dart';
import 'package:flutter_work_with_map/screen/screen_location_list.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart' as loc;

MapController mapController = MapController();
LatLng maploc;
bool isLoc;
loc.Location locationR = loc.Location();

class HomeScreen extends StatefulWidget {
  static String id = 'Home_Screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child('Locations');

  @override
  Widget build(BuildContext context) {
    maploc = Provider.of<MapLocation>(context).mapLoc;
    isLoc = Provider.of<MapLocation>(context).isLoc;
    if (isLoc) {
      mapController.move(maploc, 18);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
        centerTitle: true,
      ),
      drawer: homeScreenDrawer(),
      body: map(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.location_on,
        ),
        onPressed: () {
          onFloatButtonPressed(context);
        },
      ),
    );
  }

  onFloatButtonPressed(BuildContext context) async {
    Position position = await determinePosition();
    LatLng latLng = LatLng(position.latitude, position.longitude);
    mapController.move(latLng, 15);
    context.read<MapLocation>().setIsLoc(false);
    context.read<MapLocation>().setLocation(latLng);
    DateTime dateTime = DateTime.now();
    String id = generateId(dateTime);
    await dbRef.child(id).set(
      {
        'Id': id,
        'Latitude': latLng.latitude,
        'Longitude': latLng.longitude,
        'Date': dateFormat(dateTime),
        'Time': timeFormat(dateTime),
      },
    );
    print(position);
  }

  onPinPressed() {}

  onLocationListPressed() {
    Navigator.pop(context);
    Navigator.pushNamed(context, LocationListScreen.id);
  }

  Widget map(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        zoom: 13.0,
        maxZoom: 18,
        minZoom: 5,
        interactive: true,
      ),
      layers: [
        TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        MarkerLayerOptions(
          markers: [
            if (Provider.of<MapLocation>(context).currectLoc != null) ...[
              Marker(
                width: 80.0,
                height: 80.0,
                point: Provider.of<MapLocation>(context).currectLoc,
                builder: (ctx) => Container(
                  child: IconButton(
                    icon: Icon(
                      Icons.location_pin,
                      size: 70,
                      color: Colors.blue,
                    ),
                    onPressed: onPinPressed,
                  ),
                ),
              ),
            ],
            if (Provider.of<MapLocation>(context).mapLoc != null &&
                isLoc == true) ...[
              Marker(
                width: 80.0,
                height: 80.0,
                point: Provider.of<MapLocation>(context).mapLoc,
                builder: (ctx) => Container(
                  child: IconButton(
                    icon: Icon(
                      Icons.push_pin,
                      size: 70,
                      color: Colors.red,
                    ),
                    onPressed: onPinPressed,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget homeScreenDrawer() {
    return Drawer(
      child: Container(
        child: ListView(
          padding: EdgeInsets.all(0),
          children: <Widget>[
            DrawerHeader(
              child: Icon(
                Icons.map_outlined,
                size: 120,
                color: Colors.white,
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.my_location),
                  SizedBox(
                    width: 5,
                  ),
                  Text('Location List')
                ],
              ),
              onTap: onLocationListPressed,
            ),
          ],
        ),
      ),
    );
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled){
      showErrorDialog(
        yesPressed: () {

          locationR.requestService();
        },
        context: context,
        text: 'Your Location Services Are Disable',
        text2: 'Do You Want Enable Your Location?',
      );
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
  }
}

String generateId(DateTime dateTime) {
  String ID = dateTime.toString();
  ID = ID.replaceAll(" ", "-");
  ID = ID.replaceAll(":", "-");
  ID = ID.replaceAll(".", "-");
  return ID;
}

String dateFormat(DateTime dateTime) {
  String day = dateTime.day.toString();
  String month = dateTime.month.toString();
  String year = dateTime.year.toString();
  String format = year + '/' + month + '/' + day;
  return format;
}

String timeFormat(DateTime dateTime) {
  String minute = dateTime.minute.toString();
  String hour = dateTime.hour.toString();
  String format = hour + ':' + minute;
  return format;
}

void showErrorDialog(
    {@required BuildContext context,
    @required String text,
    @required String text2,
    @required Function yesPressed}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Center(
            child: Column(
              children: [
                Text(
                  text,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  text2,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('No'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    yesPressed();
                    Navigator.pop(context);
                  },
                  child: Text('Yes'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                ),
              ),
            ],
          ));
    },
  );
}
