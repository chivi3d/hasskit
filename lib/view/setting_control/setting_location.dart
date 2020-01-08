import 'package:flutter/material.dart';
import 'package:background_location/background_location.dart';

class SettingLocation extends StatefulWidget {
  @override
  _SettingLocationState createState() => _SettingLocationState();
}

class _SettingLocationState extends State<SettingLocation> {
  String latitude = "waiting...";
  String longitude = "waiting...";
  String altitude = "waiting...";
  String accuracy = "waiting...";
  String bearing = "waiting...";
  String speed = "waiting...";

  @override
  void initState() {
    super.initState();

    BackgroundLocation.startLocationService();
    BackgroundLocation.getLocationUpdates((location) {
      setState(() {
        this.latitude = location.latitude.toString();
        this.longitude = location.longitude.toString();
        this.accuracy = location.accuracy.toString();
        this.altitude = location.altitude.toString();
        this.bearing = location.bearing.toString();
        this.speed = location.speed.toString();
      });

      print("""\n
      Latitude:  $latitude
      Longitude: $longitude
      Altitude: $altitude
      Accuracy: $accuracy
      Bearing:  $bearing
      Speed: $speed
      """);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        locationData("Latitude: " + latitude),
        locationData("Longitude: " + longitude),
        locationData("Altitude: " + altitude),
        locationData("Accuracy: " + accuracy),
        locationData("Bearing: " + bearing),
        locationData("Speed: " + speed),
        RaisedButton(
            onPressed: () {
              print("BackgroundLocation.startLocationService");
              BackgroundLocation.startLocationService();
            },
            child: Text("Start Location Service")),
        RaisedButton(
            onPressed: () {
              print("BackgroundLocation.stopLocationService");
              BackgroundLocation.stopLocationService();
            },
            child: Text("Stop Location Service")),
        RaisedButton(
            onPressed: () {
              print("getCurrentLocation");
              getCurrentLocation();
            },
            child: Text("Get Current Location")),
        RaisedButton(
            onPressed: () {
              print("BackgroundLocation.getPermissions");
              BackgroundLocation.getPermissions(
                onGranted: () {
                  print("BackgroundLocation.getPermissions onGranted");
                },
                onDenied: () {
                  print("BackgroundLocation.getPermissions onGranted");
                },
              );
            },
            child: Text("getPermissions")),
        RaisedButton(
            onPressed: () {
              print("BackgroundLocation.checkPermissions");
              BackgroundLocation.checkPermissions().then((status) {
                print("BackgroundLocation.checkPermissions $status");
              });
            },
            child: Text("checkPermissions")),
      ]),
    );
  }

  Widget locationData(String data) {
    return Text(
      data,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }

  getCurrentLocation() {
    BackgroundLocation().getCurrentLocation().then((location) {
      print("This is current Location" + location.longitude.toString());
    });
  }

  @override
  void dispose() {
    BackgroundLocation.stopLocationService();
    super.dispose();
  }
}
