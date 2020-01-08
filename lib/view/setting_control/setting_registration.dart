import 'dart:io';

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

  String latitude = "waiting...";
  String longitude = "waiting...";
  String altitude = "waiting...";
  String accuracy = "waiting...";
  String bearing = "waiting...";
  String speed = "waiting...";

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

    if (gd.deviceIntegration.trackLocation &&
        gd.deviceIntegration.webHookId != "") {
      print("initState BackgroundLocation.startLocationService");
      BackgroundLocation.startLocationService();
    }

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

  void getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var deviceModel = "";
    String millisecondsSinceEpoch =
        DateTime.now().millisecondsSinceEpoch.toString();
    millisecondsSinceEpoch = millisecondsSinceEpoch.substring(
        millisecondsSinceEpoch.length - 4, millisecondsSinceEpoch.length);

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.utsname.machine}');
      deviceModel =
          "-" + iosInfo.utsname.machine + "-" + millisecondsSinceEpoch;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"
      deviceModel = "-" + androidInfo.model + "-" + millisecondsSinceEpoch;
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
                            "Lat: $latitude Long: $longitude",
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
                          print(
                              "Switch.adaptive BackgroundLocation.startLocationService");
                          BackgroundLocation.startLocationService();
                        } else {
                          print(
                              "Switch.adaptive BackgroundLocation.stopLocationService");
                          BackgroundLocation.stopLocationService();
                        }
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
