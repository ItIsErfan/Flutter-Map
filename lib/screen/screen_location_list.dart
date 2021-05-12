import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_work_with_map/main.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'screen_home.dart';

class LocationListScreen extends StatelessWidget {
  static String id = 'Location_List_Screen';
  final dbRef = FirebaseDatabase.instance.reference().child("Locations");
  Size size;


  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Location List'),
        centerTitle: true,
      ),
      body: ListLocation(),
    );
  }

  Widget ListLocation() {
    List lists = [];
    return FutureBuilder(
      future: dbRef.once(),
      builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
        if (snapshot.hasData) {
          lists.clear();
          Map<dynamic, dynamic> values = snapshot.data.value;
          values.forEach((key, values) {
            lists.add(values);
          });
          return ListView.builder(
              itemCount: lists.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 5,
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.02,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: size.height * 0.01),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.my_location,
                                      color: Colors.grey,
                                      size: size.height * 0.025,
                                    ),
                                    SizedBox(
                                      width: size.width * 0.005,
                                    ),
                                    Text(
                                      "Lat: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey),
                                    ),
                                    Text(
                                      lists[index]["Latitude"].toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.01),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.my_location,
                                      color: Colors.grey,
                                      size: size.height * 0.025,
                                    ),
                                    SizedBox(
                                      width: size.width * 0.005,
                                    ),
                                    Text(
                                      "Lon: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      lists[index]["Longitude"].toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.01),
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.date_range,
                                          color: Colors.grey,
                                          size: size.height * 0.025,
                                        ),
                                        SizedBox(
                                          width: size.width * 0.005,
                                        ),
                                        Text(
                                          lists[index]["Date"],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: size.width * 0.05,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: Colors.grey,
                                          size: size.height * 0.025,
                                        ),
                                        SizedBox(
                                          width: size.width * 0.005,
                                        ),
                                        Text(
                                          lists[index]["Time"].toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.01),
                              ],
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                onShowMapPressed(
                                    context: context,
                                    latLng: LatLng(
                                    lists[index]["Latitude"],
                                    lists[index]["Longitude"],
                                ),
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.map,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: size.width * 0.005,
                                  ),
                                  Text(
                                    "Show On Map",
                                  ),
                                ],
                              ))
                        ],
                      )),
                );
              });
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  onShowMapPressed({LatLng latLng, BuildContext context}) {
    context.read<MapLocation>().setMapLocation(latLng);
    context.read<MapLocation>().setIsLoc(true);

    Navigator.pop(context);

  }
}
