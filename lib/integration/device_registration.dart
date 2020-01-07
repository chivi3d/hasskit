import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/theme_info.dart';

class DeviceRegistration extends StatefulWidget {
  @override
  _DeviceRegistrationState createState() => _DeviceRegistrationState();
}

class _DeviceRegistrationState extends State<DeviceRegistration> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    if (gd.deviceIntegration.deviceName != "") {
      _controller.text = gd.deviceIntegration.deviceName;
    } else {
      getDeviceInfo();
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
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "Add HassKit Mobile App component to Home Assistant to enable location tracking and push notification feature.",
                  style: Theme.of(context).textTheme.body1,
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
                  onChanged: (val) {
                    setState(() {
                      _controller.text = val;
                    });
                  },
                ),
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
                  child: Text(gd.deviceIntegration.webHookId == ""
                      ? "Register Mobile App"
                      : "Update Mobile App"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
