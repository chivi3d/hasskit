import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/model/Entity.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class EntityControlClimate extends StatelessWidget {
  final String entityId;
  const EntityControlClimate({@required this.entityId});

  @override
  Widget build(BuildContext context) {
//    var hvacVal = "Off";
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.entities[entityId].state}" +
          "${generalData.entities[entityId].hvacModeIndex}" +
          "${generalData.entities[entityId].temperature}" +
          "${generalData.entities[entityId].getFriendlyName}" +
          "${generalData.entities[entityId].getOverrideIcon}",
      builder: (context, data, child) {
        var entity = gd.entities[entityId];
        var info04 = InfoProperties(
//            bottomLabelStyle: Theme.of(context).textTheme.title,
//        bottomLabelStyle: TextStyle(
//            color: HexColor('#54826D'),
//            fontSize: 14,
//            fontWeight: FontWeight.w600),
//            bottomLabelText: entity.getOverrideName,
            mainLabelStyle: Theme.of(context).textTheme.display3,
//        mainLabelStyle: TextStyle(
//            color: HexColor('#54826D'),
//            fontSize: 30.0,
//            fontWeight: FontWeight.w600),
            modifier: (double value) {
              var temp = value.toInt();
              return '$temp˚';
            });

        var customColors05 = CustomSliderColors(
          trackColor: Colors.amber,
          progressBarColors: [Colors.amber, Colors.green],
          gradientStartAngle: 0,
          gradientEndAngle: 180,
          dotColor: Colors.white,
          hideShadow: true,
          shadowColor: Colors.black12,
          shadowMaxOpacity: 0.25,
          shadowStep: 1,
        );
        var customWidths = CustomSliderWidths(
          handlerSize: 8,
          progressBarWidth: 20,
        );

        var slider = SleekCircularSlider(
          appearance: CircularSliderAppearance(
            customColors: customColors05,
            infoProperties: info04,
            customWidths: customWidths,
          ),
          min: entity.minTemp,
          max: entity.maxTemp,
          initialValue: entity.getTemperature,
          onChangeEnd: (double value) {
            print('onChangeEnd $value');

            var outMsg = {
              "id": gd.socketId,
              "type": "call_service",
              "domain": "climate",
              "service": "set_temperature",
              "service_data": {
                "entity_id": entity.entityId,
                "temperature": value.toInt(),
              }
            };
            var outMsgEncoded = json.encode(outMsg);
            gd.sendSocketMessage(outMsgEncoded);
          },
        );

        return Column(
          children: <Widget>[
            SizedBox(
              width: 240,
              height: 240,
              child: slider,
            ),
            FanSpeed(entityId: entityId),
            SizedBox(height: 16),
            HvacModes(entityId: entityId),
          ],
        );
      },
    );
  }
}

class FanSpeed extends StatefulWidget {
  final String entityId;
  const FanSpeed({@required this.entityId});
  @override
  _FanSpeedState createState() => _FanSpeedState();
}

class _FanSpeedState extends State<FanSpeed> {
  final children = <String, Widget>{};
  Entity entity;
  String groupValue;
  @override
  void initState() {
    super.initState();
    entity = gd.entities[widget.entityId];
    groupValue = entity.fanMode;
  }

  @override
  Widget build(BuildContext context) {
//    log.d("entity.fanMode ${entity.fanModes}");
    for (String fanMode in entity.fanModes) {
      children[fanMode] = Text(
        gd.textToDisplay(fanMode),
        textScaleFactor: gd.textScaleFactorFix,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Container(
      child: CupertinoSlidingSegmentedControl<String>(
        thumbColor: ThemeInfo.colorBottomSheetReverse.withOpacity(0.75),
        children: children,
        onValueChanged: (String val) {
          setState(() {
            groupValue = val;
            var outMsg = {
              "id": gd.socketId,
              "type": "call_service",
              "domain": "climate",
              "service": "set_fan_mode",
              "service_data": {
                "entity_id": widget.entityId,
                "fan_mode": "$groupValue"
              }
            };
            var message = json.encode(outMsg);
            gd.sendSocketMessage(message);
          });
        },
        groupValue: groupValue,
      ),
    );
  }
}

class HvacModes extends StatefulWidget {
  final String entityId;
  const HvacModes({@required this.entityId});
  @override
  _HvacModesState createState() => _HvacModesState();
}

class _HvacModesState extends State<HvacModes> {
  final children = <String, Widget>{};
  Entity entity;
  String groupValue;
  @override
  void initState() {
    super.initState();
    entity = gd.entities[widget.entityId];
    groupValue = entity.state;
  }

  @override
  Widget build(BuildContext context) {
    log.d("entity.hvacModes ${entity.hvacModes}");
    for (String hvacMode in entity.hvacModes) {
      children[hvacMode] = Text(
        gd.textToDisplay(hvacMode),
        textScaleFactor: gd.textScaleFactorFix,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Container(
      child: CupertinoSlidingSegmentedControl<String>(
        thumbColor: gd.climateModeToColor(groupValue),
        children: children,
        onValueChanged: (String val) {
          setState(() {
            groupValue = val;
            var outMsg = {
              "id": gd.socketId,
              "type": "call_service",
              "domain": "climate",
              "service": "set_hvac_mode",
              "service_data": {
                "entity_id": widget.entityId,
                "hvac_mode": "$groupValue"
              }
            };
            var message = json.encode(outMsg);
            gd.sendSocketMessage(message);
          });
        },
        groupValue: groupValue,
      ),
    );
  }
}
