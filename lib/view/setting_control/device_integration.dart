import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:http/http.dart' as http;

class DeviceIntegration {
  String deviceName = "";
  String cloudHookUrl = "";
  String remoteUiUrl = "";
  String secret = "";
  String webHookId = "";
  bool trackLocation = true;

  DeviceIntegration({
    @required this.deviceName,
    @required this.cloudHookUrl,
    @required this.remoteUiUrl,
    @required this.secret,
    @required this.webHookId,
    @required this.trackLocation,
  });

  Map<String, dynamic> toJson() => {
        'deviceName': deviceName,
        'cloudhook_url': cloudHookUrl,
        'cloudhook_url': remoteUiUrl,
        'secret': secret,
        'webhook_id': webHookId,
        'trackLocation': trackLocation,
      };

  factory DeviceIntegration.fromJson(Map<String, dynamic> json) {
    return DeviceIntegration(
      deviceName: json['deviceName'] != null ? json['deviceName'] : "",
      cloudHookUrl: json['cloudhook_url'] != null ? json['cloudhook_url'] : "",
      remoteUiUrl: json['remote_ui_url'] != null ? json['remote_ui_url'] : "",
      secret: json['secret'] != null ? json['secret'] : "",
      webHookId: json['webhook_id'] != null ? json['webhook_id'] : "",
      trackLocation:
          json['trackLocation'] != null ? json['trackLocation'] : true,
    );
  }

  String manufacturer = "manufacturer";
  String model = "model";
  String osName = "os_name";
  String osVersion = "os_version";

  getOsInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    manufacturer = "manufacturer";
    model = "model";
    osName = "os_name";
    osVersion = "os_version";

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      manufacturer = androidInfo.manufacturer;
      model = androidInfo.model;
      osName = androidInfo.version.baseOS;
      osVersion = androidInfo.version.release;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      manufacturer = "Apple";
      model = iosInfo.utsname.machine;
      osName = iosInfo.utsname.sysname;
      osVersion = iosInfo.utsname.version;
    }
  }

  register(String deviceName) async {
    print("\n\nDeviceIntegrationn.register($deviceName)\n\n");
    if (deviceName.trim().length < 1) {
      print("deviceName.trim().length<1");
      return;
    }
    await getOsInfo();

    var registerData = {
      "app_id": "hasskit",
      "app_name": "HassKit",
      "app_version": "4.0",
      "device_name": deviceName,
      "manufacturer": manufacturer,
      "model": model,
      "os_name": osName,
      "os_version": osVersion,
      "supports_encryption": false,
      "app_data": {
        "push_token": gd.firebaseMessagingToken,
        "push_url":
            "https://us-central1-hasskit-a81c7.cloudfunctions.net/sendPushNotification",
      }
    };

    String body = jsonEncode(registerData);
    String url = gd.currentUrl + "/api/mobile_app/registrations";
    print("registerDataEncoded $body");
    print("url $url");

    Map<String, String> headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer ${gd.loginDataCurrent.longToken}',
    };

    http.post(url, headers: headers, body: body).then((response) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("register response from server with code ${response.statusCode}");
        var bodyDecode = json.decode(response.body);
        print("register bodyDecode $bodyDecode");
        gd.deviceIntegration = DeviceIntegration.fromJson(bodyDecode);
        gd.deviceIntegration.deviceName = deviceName;
        print(
            "gd.deviceIntegration.deviceName ${gd.deviceIntegration.deviceName}");
        print(
            "gd.deviceIntegration.cloudHookUrl ${gd.deviceIntegration.cloudHookUrl}");
        print(
            "gd.deviceIntegration.remoteUiUrl ${gd.deviceIntegration.remoteUiUrl}");
        print("gd.deviceIntegration.secret ${gd.deviceIntegration.secret}");
        print(
            "gd.deviceIntegration.webHookId ${gd.deviceIntegration.webHookId}");

        gd.deviceIntegrationSave();

//        Fluttertoast.showToast(
//            msg: "Register Mobile App Success\n"
//                "- Device Name: ${gd.deviceIntegration.deviceName}\n"
//                "- Cloudhook Url: ${gd.deviceIntegration.cloudHookUrl}\n"
//                "- Remote UI Url: ${gd.deviceIntegration.remoteUiUrl}\n"
//                "- Secret: ${gd.deviceIntegration.secret}\n"
//                "- Webhook Id: ${gd.deviceIntegration.webHookId}",
//            toastLength: Toast.LENGTH_LONG,
//            gravity: ToastGravity.TOP,
//            backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
//            textColor: Theme.of(gd.mediaQueryContext).textTheme.title.color,
//            fontSize: 14.0);

        showDialog(
          context: gd.mediaQueryContext,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text("Register Mobile App Success"),
              content: new Text("Restart Home Assistant Now?"),
              backgroundColor: ThemeInfo.colorBottomSheet,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                RaisedButton(
                  child: new Text("Later"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                RaisedButton(
                  child: new Text("Restart"),
                  onPressed: () {
                    var outMsg = {
                      "id": gd.socketId,
                      "type": "call_service",
                      "domain": "homeassistant",
                      "service": "restart",
                    };

                    var outMsgEncoded = json.encode(outMsg);
                    gd.sendSocketMessage(outMsgEncoded);

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        print(
            "Register Mobile App Response From Server With Code ${response.statusCode}");
        Fluttertoast.showToast(
            msg: "Register Mobile App Fail\n"
                "Server Response With Code ${response.statusCode}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
            textColor: Theme.of(gd.mediaQueryContext).textTheme.title.color,
            fontSize: 14.0);
      }
    }).catchError((e) {
      print("Register error $e");
      Fluttertoast.showToast(
          msg: "Register Mobile App Fail\n"
              "Error $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
          textColor: Theme.of(gd.mediaQueryContext).textTheme.title.color,
          fontSize: 14.0);
    });
  }

  updateRegistration(String deviceName) async {
    print("\n\nDeviceIntegrationn.updateRegistration($deviceName)\n\n");

    await getOsInfo();

    String url =
        gd.currentUrl + "/api/webhook/${gd.deviceIntegration.webHookId}";

    var registerUpdateData = {
      "type": "update_registration",
      "data": {
        "app_data": {
          "push_token": gd.firebaseMessagingToken,
          "push_url":
              "https://us-central1-hasskit-a81c7.cloudfunctions.net/sendPushNotification",
        },
        "app_version": "4.0",
        "device_name": deviceName,
        "manufacturer": manufacturer,
        "model": model,
        "os_version": osVersion,
      }
    };
//          "push_url": "https://fcm.googleapis.com/fcm/send",
    String body = jsonEncode(registerUpdateData);
    print("registerUpdateData.url $url");
    print("registerUpdateData.body $body");

    http.post(url, body: body).then((response) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print(
            "updateRegistration response from server with code ${response.statusCode}");

        if (response == null || response.body.isEmpty) {
          print("updateRegistration response == null || response.body.isEmpty");
          print(
              "No registration data in response - MobileApp integration was removed");
          register(deviceName);
        } else {
          var bodyDecode = json.decode(response.body);
          print("updateRegistration bodyDecode $bodyDecode");
          print("bodyDecode[device_name] ${bodyDecode["device_name"]}");
          gd.deviceIntegration.deviceName = bodyDecode["device_name"];
          gd.deviceIntegrationSave();

//          Fluttertoast.showToast(
//              msg: "Update Mobile App Success\n"
//                  "- Device Name: ${gd.deviceIntegration.deviceName}\n"
//                  "- Cloudhook Url: ${gd.deviceIntegration.cloudHookUrl}\n"
//                  "- Remote UI Url: ${gd.deviceIntegration.remoteUiUrl}\n"
//                  "- Secret: ${gd.deviceIntegration.secret}\n"
//                  "- Webhook Id: ${gd.deviceIntegration.webHookId}",
//              toastLength: Toast.LENGTH_LONG,
//              gravity: ToastGravity.TOP,
//              backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
//              textColor: Theme.of(gd.mediaQueryContext).textTheme.title.color,
//              fontSize: 14.0);

          showDialog(
            context: gd.mediaQueryContext,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                title: new Text("Update Mobile App Success"),
                content: new Text("Restart Home Assistant Now?"),
                backgroundColor: ThemeInfo.colorBottomSheet,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  RaisedButton(
                    child: new Text("Later"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  RaisedButton(
                    child: new Text("Restart"),
                    onPressed: () {
                      var outMsg = {
                        "id": gd.socketId,
                        "type": "call_service",
                        "domain": "homeassistant",
                        "service": "restart",
                      };

                      var outMsgEncoded = json.encode(outMsg);
                      gd.sendSocketMessage(outMsgEncoded);

                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        print(
            "Update Mobile App Response From Server With Code ${response.statusCode}");
        Fluttertoast.showToast(
            msg: "Update Mobile App Fail\n"
                "Server Response With Code ${response.statusCode}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
            textColor: Theme.of(gd.mediaQueryContext).textTheme.title.color,
            fontSize: 14.0);
      }
    }).catchError((e) {
      print("Update Mobile App Error $e");
      Fluttertoast.showToast(
          msg: "Update Mobile App Fail\n"
              "Error $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
          textColor: Theme.of(gd.mediaQueryContext).textTheme.title.color,
          fontSize: 14.0);
    });
  }
}
