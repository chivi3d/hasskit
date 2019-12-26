import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/model/entity.dart';
import 'package:hasskit/model/location.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:intl/intl.dart';

class EntityControlGoogleMaps extends StatefulWidget {
  final String entityId;
  const EntityControlGoogleMaps({@required this.entityId});
  @override
  _EntityControlGoogleMapsState createState() =>
      _EntityControlGoogleMapsState();
}

class _EntityControlGoogleMapsState extends State<EntityControlGoogleMaps> {
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  List<Widget> locationListViews = [];
  String locationSelected = "";
//  double offset = 0.037;
  double offset = 0.0;
  final Set<Factory> gestureRecognizers = [
    Factory(() => EagerGestureRecognizer()),
  ].toSet();

  bool inAsyncCall = true;
  @override
  void initState() {
    super.initState();
    gd.locations = [];
    getHistory();
  }

  @override
  Widget build(BuildContext context) {
    Entity entity = gd.entities[widget.entityId];

    return ModalProgressHUD(
      inAsyncCall: inAsyncCall,
      opacity: 0,
      progressIndicator: SpinKitThreeBounce(
        size: 40,
        color: ThemeInfo.colorIconActive.withOpacity(0.5),
      ),
      child: inAsyncCall
          ? Container()
          : Column(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      GoogleMap(
                        gestureRecognizers: gestureRecognizers,
                        mapType: MapType.normal,
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                        initialCameraPosition: CameraPosition(
                            target: LatLng(entity.latitude + offset,
                                entity.longitude + offset),
                            zoom: 15),
                        markers: Set<Marker>.of(markers.values),
                      ),
//                      Container(
//                        height: 28,
//                        color: Colors.white.withOpacity(0.8),
//                      ),
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                        height: 30,
                        child: listViewBuilder(locationSelected),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> goToLocation(Location loc) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(
          loc.latitude + offset,
          loc.longitude + offset,
        ),
      ),
    );
  }

  void placeMarker(Location loc) {
    final MarkerId markerId = MarkerId(loc.entityId);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        loc.latitude + offset,
        loc.longitude + offset,
      ),
    );
    markers[markerId] = marker;
  }

  void getHistory() async {
    log.d("getHistory Start");
    var startPeriod = DateTime.now().subtract(Duration(hours: 168));
    var startPeriodString =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(startPeriod);
    startPeriodString = startPeriodString + DateTime.now().timeZoneName + ":00";

    var endPeriodString =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now());
    endPeriodString = endPeriodString + DateTime.now().timeZoneName + ":00";
    endPeriodString = Uri.encodeComponent(endPeriodString);
    var client = new http.Client();
//    var url = gd.currentUrl +
//        "/api/history/period?filter_entity_id=${widget.entityId}";
    var url = gd.currentUrl +
        "/api/history/period/$startPeriodString"
            "?"
            "end_time=$endPeriodString"
            "&"
            "filter_entity_id=${widget.entityId}"
            "";
    Map<String, String> headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer ${gd.loginDataCurrent.longToken}',
    };
    print("url $url");
    try {
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print("jsonResponse $jsonResponse");

        for (var rec in jsonResponse[0]) {
          var location = Location.fromJson(rec);
          print(
              "${location.latitude} ${location.longitude} ${location.lastChanged} ${location.source} ${location.state}");
          if (location.lastChanged == null ||
              location.latitude == null ||
              location.longitude == null) {
            continue;
          }

          gd.locations.add(location);
        }

        if (gd.locations.length > 0) {
          placeMarker(gd.locations[0]);
        }

        print("gd.locations.length ${gd.locations.length}");
      } else {
        log.e("Request failed with status: ${response.statusCode}.");
      }
    } catch (e) {
      inAsyncCall = false;
      log.e("getHistory $e");
    } finally {
      setState(() {
//        log.d("getHistory finally");
        inAsyncCall = false;
        client.close();
      });
    }
  }

  Widget listViewBuilder(String selected) {
    print("listViewBuilder $selected");
    locationListViews = [];
    int i = 0;
    for (Location location in gd.locations) {
      String timeDisplay;
      if (location.lastChanged.toLocal().day != DateTime.now().toLocal().day) {
        timeDisplay = DateFormat("EEE, dd MMM HH:mm")
            .format(location.lastChanged.toLocal());
      } else {
        timeDisplay =
            DateFormat("HH:mm").format(location.lastChanged.toLocal());
      }
      var locationListView = InkWell(
        onTap: () {
          setState(() {
            locationSelected = location.lastChanged.toString();
            goToLocation(location);
            placeMarker(location);
          });
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: location.lastChanged.toString() == selected ||
                    i == gd.locations.length - 1 && selected == ""
                ? Colors.red.withOpacity(0.8)
                : ThemeInfo.colorIconActive.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(location.state == "not_home"
              ? "$timeDisplay"
              : "$timeDisplay ${gd.textToDisplay(location.state)}"),
        ),
      );
      locationListViews.add(locationListView);
      i++;
    }

    locationListViews = locationListViews.reversed.toList();

    return ListView(
        reverse: true,
        // This next line does the trick.
        scrollDirection: Axis.horizontal,
        children: locationListViews);
  }
}
