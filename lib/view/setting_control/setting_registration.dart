import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:background_location/background_location.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/material_design_icons.dart';
import 'package:hasskit/helper/theme_info.dart';

class SettingRegistration extends StatefulWidget {
  @override
  _SettingRegistrationState createState() => _SettingRegistrationState();
}

class _SettingRegistrationState extends State<SettingRegistration> {
  TextEditingController _controller;

  @override
  void initState() {
    print("SettingRegistration initState ${gd.deviceIntegration.deviceName}");
    super.initState();
    _controller = TextEditingController();
    if (gd.deviceIntegration.deviceName != "") {
      _controller.text = gd.deviceIntegration.deviceName;
    } else {
      getDeviceInfo();
    }

    initLocation();
  }

  void initLocation() {
    if (gd.deviceIntegration.trackLocation &&
        gd.deviceIntegration.webHookId != "") {
      print("initState BackgroundLocation.startLocationService");
      BackgroundLocation.startLocationService();
    }

    BackgroundLocation.getLocationUpdates((location) {
      updateLocation(
        location.latitude,
        location.longitude,
        location.accuracy,
        location.speed,
        location.altitude,
      );
    });
  }

  void updateLocation(double latitude, double longitude, double accuracy,
      double speed, double altitude) {
    bool isAfter =
        DateTime.now().isAfter(gd.locUpdateTime.add(Duration(minutes: 1)));
    double distance =
        gd.getDistanceFromLatLonInKm(latitude, longitude, gd.locLat, gd.locLon);

    print("isAfter $isAfter distance $distance");

//     0.05 = 50 meter
    if (isAfter || distance > 0.05) {
      print(".");
      print("latitude $latitude");
      print("longitude $longitude");
      print("altitude $altitude");
      print("accuracy $accuracy");
      print("speed $speed");
      print(".");

      gd.locUpdateTime = DateTime.now();
      gd.locLat = latitude;
      gd.locLon = longitude;
      String url =
          gd.currentUrl + "/api/webhook/${gd.deviceIntegration.webHookId}";

      var getLocationUpdatesData = {
        "type": "update_location",
        "data": {
          "gps": [latitude, longitude],
          "gps_accuracy": accuracy,
          "speed": speed,
          "altitude": altitude
        }
      };
      String body = jsonEncode(getLocationUpdatesData);
      print("getLocationUpdates.url $url");
      print("getLocationUpdates.body $body");

      http.post(url, body: body).then((response) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          print(
              "updateLocation Response From Server With Code ${response.statusCode}");
        } else {
          print("updateLocation Response Error Code ${response.statusCode}");
        }
      }).catchError((e) {
        print("updateLocation Response Error $e");
      });
    }
  }

  void getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var deviceModel = "";
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.utsname.machine}');
      deviceModel = "-" + iosInfo.utsname.machine;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"
      deviceModel = "-" + androidInfo.model;
    }
    _controller.text = "HassKit$deviceModel";
  }

  @override
  Widget build(BuildContext context) {
    print("SettingRegistration build ${gd.deviceIntegration.deviceName}");
    if (gd.deviceIntegration.deviceName != "") {
      _controller.text = gd.deviceIntegration.deviceName;
    } else {
      getDeviceInfo();
    }
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
            decoration: BoxDecoration(
                color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "Add HassKit Mobile App component to Home Assistant to enable this device location tracking and push notification.",
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.justify,
                  textScaleFactor: gd.textScaleFactorFix,
                ),
                TextField(
                  autofocus: false,
                  controller: _controller,
                  decoration: new InputDecoration(
                    labelText: gd.deviceIntegration.webHookId == ""
                        ? "Register Mobile App"
                        : "Update Mobile App",
                    hintText: gd.deviceIntegration.webHookId == ""
                        ? "Enter Mobile App Name"
                        : "Enter Mobile App Name",
                  ),
//                  onChanged: (val) {
//                    setState(() {});
//                  },
                ),
                gd.deviceIntegration.trackLocation &&
                        gd.deviceIntegration.webHookId != ""
                    ? SizedBox(height: 8)
                    : Container(),
                gd.deviceIntegration.trackLocation &&
                        gd.deviceIntegration.webHookId != ""
                    ? Row(
                        children: <Widget>[
                          Icon(MaterialDesignIcons.getIconDataFromIconName(
                              "mdi:map-marker")),
                          Text(
                            "Lat: ${gd.locLat} - Lon: ${gd.locLon}",
                            style: Theme.of(context).textTheme.caption,
                            textAlign: TextAlign.justify,
                            textScaleFactor: gd.textScaleFactorFix,
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: <Widget>[
                Switch.adaptive(
                    value: gd.deviceIntegration.trackLocation,
                    onChanged: (val) {
                      setState(() {
                        gd.deviceIntegration.trackLocation = val;
                        print(
                            "onChanged $val gd.deviceIntegration.trackLocation ${gd.deviceIntegration.trackLocation}");
                        if (val == true) {
                          if (gd.deviceIntegration.webHookId != "") {
                            print(
                                "Switch.adaptive BackgroundLocation.startLocationService");
                            BackgroundLocation.startLocationService();
                          }
                        } else {
                          print(
                              "Switch.adaptive BackgroundLocation.stopLocationService");
                          BackgroundLocation.stopLocationService();
                        }
                        gd.deviceIntegrationSave();
                      });
                    }),
                Expanded(child: Text("Track Location")),
                RaisedButton(
                  onPressed: _controller.text.trim().length > 0 &&
                          gd.connectionStatus == "Connected"
                      ? () {
                          if (gd.deviceIntegration.webHookId == "") {
                            gd.deviceIntegration
                                .register(_controller.text.trim());
                          } else {
                            gd.deviceIntegration
                                .updateRegistration(_controller.text.trim());
                          }
                          FocusScope.of(context).requestFocus(new FocusNode());
                        }
                      : null,
                  child: Text(
                    gd.deviceIntegration.webHookId == ""
                        ? "Register"
                        : "Update",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
