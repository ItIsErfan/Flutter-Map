import 'package:flutter/material.dart';
import 'package:flutter_work_with_map/screen/screen_home.dart';
import 'package:flutter_work_with_map/screen/screen_location_list.dart';
import 'package:provider/provider.dart';
import 'package:latlong/latlong.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MapLocation>(create: (_) => MapLocation()),
      ],
      child: MyApp(),
    ),
  );
}

class MapLocation extends ChangeNotifier {
  LatLng currectLoc;
  LatLng mapLoc;
  bool isLoc = false;

  void setIsLoc(bool isloc){
    isLoc = isloc;
    notifyListeners();
  }

  void setMapLocation(LatLng location){
    mapLoc = location;
    notifyListeners();
  }

  void setLocation(LatLng location){
    currectLoc = location;
    notifyListeners();
  }

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
        LocationListScreen.id: (context) => LocationListScreen(),
      },
      initialRoute: HomeScreen.id,
    );
  }
}
