import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/model/Entity.dart';

class EntityControlVacuum extends StatefulWidget {
  final String entityId;
  const EntityControlVacuum({@required this.entityId});
  @override
  _EntityControlVacuumState createState() => _EntityControlVacuumState();
}

class _EntityControlVacuumState extends State<EntityControlVacuum> {
  Entity entity;
  String fanSpeed;
  @override
  void initState() {
    super.initState();
    entity = gd.entities[widget.entityId];
    fanSpeed = entity.fanSpeed;
  }

  Widget buttonWidget(String buttonText, String buttonIcon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(MaterialDesignIcons.getIconDataFromIconName(buttonIcon)),
        Text(
          buttonText,
          overflow: TextOverflow.ellipsis,
          textScaleFactor: gd.textScaleFactor,
          maxLines: 1,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    entity = gd.entities[widget.entityId];

    Map<String, Widget> childrenSegment = {};
    for (String fanSpeed in entity.fanSpeedList) {
      var entry = {
        fanSpeed: Text(gd.textToDisplay(fanSpeed)),
      };
      childrenSegment.addAll(entry);
    }

    List<bool> isSelected1 = [];
    List<Widget> toggleButtons1 = [];
    Map<int, Map<String, dynamic>> commandMap = {};
    int i = 0;
    String supportedFeaturesVacuumList = entity.getSupportedFeaturesVacuum;
    if (supportedFeaturesVacuumList.contains("SUPPORT_TURN_ON")) {
      var outMsg = {
        "service": "turn_on",
        "service_data": {"entity_id": widget.entityId},
      };
      toggleButtons1.add(buttonWidget("Turn On", "mdi:power-cycle"));
      isSelected1.add(false);
      commandMap[i] = outMsg;
      i = i + 1;
    }
    if (supportedFeaturesVacuumList.contains("SUPPORT_TURN_OFF")) {
      var outMsg = {
        "service": "turn_off",
        "service_data": {"entity_id": widget.entityId},
      };
      toggleButtons1.add(buttonWidget("Turn Off", "mdi:power-off"));
      isSelected1.add(false);
      commandMap[i] = outMsg;
      i = i + 1;
    }
    if (supportedFeaturesVacuumList.contains("SUPPORT_START")) {
      var outMsg = {
        "service": "start",
        "service_data": {"entity_id": widget.entityId},
      };
      toggleButtons1.add(buttonWidget("Start", "mdi:play"));
      isSelected1.add(false);
      commandMap[i] = outMsg;
      i = i + 1;
    }
    if (supportedFeaturesVacuumList.contains("SUPPORT_PAUSE")) {
      var outMsg = {
        "service": "pause",
        "service_data": {"entity_id": widget.entityId},
      };
      toggleButtons1.add(buttonWidget("Pause", "mdi:pause"));
      isSelected1.add(false);
      commandMap[i] = outMsg;
      i = i + 1;
    }
    if (supportedFeaturesVacuumList.contains("SUPPORT_STOP")) {
      var outMsg = {
        "service": "stop",
        "service_data": {"entity_id": widget.entityId},
      };
      toggleButtons1.add(buttonWidget("Stop", "mdi:stop"));
      isSelected1.add(false);
      commandMap[i] = outMsg;
      i = i + 1;
    }
    if (supportedFeaturesVacuumList.contains("SUPPORT_CLEAN_SPOT")) {
      var outMsg = {
        "service": "clean_spot",
        "service_data": {"entity_id": widget.entityId},
      };
      toggleButtons1.add(buttonWidget("Spot", "mdi:broom"));
      isSelected1.add(false);
      commandMap[i] = outMsg;
      i = i + 1;
    }
    if (supportedFeaturesVacuumList.contains("SUPPORT_LOCATE")) {
      var outMsg = {
        "service": "locate",
        "service_data": {"entity_id": widget.entityId},
      };
      toggleButtons1.add(buttonWidget("Locate", "mdi:map-marker"));
      isSelected1.add(false);
      commandMap[i] = outMsg;
      i = i + 1;
    }
    if (supportedFeaturesVacuumList.contains("SUPPORT_RETURN_HOME")) {
      var outMsg = {
        "service": "return_to_base",
        "service_data": {"entity_id": widget.entityId},
      };
      toggleButtons1.add(buttonWidget("Home", "mdi:home-map-marker"));
      isSelected1.add(false);
      commandMap[i] = outMsg;
      i = i + 1;
    }

    return Column(
      children: <Widget>[
        Icon(
          MaterialDesignIcons.getIconDataFromIconName(entity.getDefaultIcon),
          size: 200,
          color: entity.isStateOn
              ? ThemeInfo.colorIconActive
              : ThemeInfo.colorIconInActive,
        ),
        SizedBox(height: 8),
        Text(
          gd.textToDisplay(entity.getStateDisplay),
          style: Theme.of(context).textTheme.display1,
          overflow: TextOverflow.ellipsis,
          textScaleFactor: gd.textScaleFactorFix,
        ),
        SizedBox(height: 8),
        childrenSegment.length > 1
            ? CupertinoSlidingSegmentedControl<String>(
                padding: EdgeInsets.all(8),
                thumbColor: ThemeInfo.colorIconActive,
                backgroundColor: Colors.transparent,
                children: childrenSegment,
                onValueChanged: (String val) {
                  setState(() {
                    fanSpeed = val;
                    print("setState fanSpeed $fanSpeed");
                    var outMsg = {
                      "id": gd.socketId,
                      "type": "call_service",
                      "domain": widget.entityId.split('.').first,
                      "service": "set_fan_speed",
                      "service_data": {
                        "entity_id": widget.entityId,
                        "fan_speed": fanSpeed
                      },
                    };
                    var message = jsonEncode(outMsg);
                    gd.sendSocketMessage(message);
                  });
                },
                groupValue: fanSpeed,
              )
            : Container(),
        SizedBox(height: 8),
        ToggleButtons(
          borderWidth: 0,
          borderRadius: BorderRadius.circular(8),
          children: toggleButtons1,
          isSelected: isSelected1,
          onPressed: (int val) {
            setState(() {
              print("onPressed $val commandMap ${commandMap[val].toString()}");
              Map<String, dynamic> jsonCombined = {
                "id": gd.socketId,
                "type": "call_service",
                "domain": "vacuum",
              };
              jsonCombined.addAll(commandMap[val]);
              gd.sendSocketMessage(jsonEncode(jsonCombined));
            });
          },
        ),
      ],
    );
  }
}
