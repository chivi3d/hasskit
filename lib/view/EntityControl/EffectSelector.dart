import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/model/Entity.dart';

class EffectSelector extends StatefulWidget {
  final String entityId;
  const EffectSelector({@required this.entityId});

  @override
  _EffectSelectorState createState() => _EffectSelectorState();
}

class _EffectSelectorState extends State<EffectSelector> {
  @override
  Widget build(BuildContext context) {
    Entity entity = gd.entities[widget.entityId];
    String effect = entity.effect;
    if (!entity.isStateOn) effect = null;
    Map<String, Widget> childrenSegment = {"none": Text("No Effect")};
    for (String effect in entity.effectList) {
      var entry = {
        effect: Text(gd.textToDisplay(effect)),
      };
      childrenSegment.addAll(entry);
    }

    return CupertinoSlidingSegmentedControl<String>(
      padding: EdgeInsets.all(8),
      thumbColor: ThemeInfo.colorIconActive,
      backgroundColor: Colors.transparent,
      children: childrenSegment,
      onValueChanged: (String val) {
        setState(() {
          effect = val;
          print("setState effect $effect");
          var outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": widget.entityId.split('.').first,
            "service": "turn_on",
            "service_data": {"entity_id": widget.entityId, "effect": "none"},
          };
          var message = jsonEncode(outMsg);
          gd.sendSocketMessage(message);
          outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": widget.entityId.split('.').first,
            "service": "turn_on",
            "service_data": {"entity_id": widget.entityId, "effect": effect},
          };

          message = jsonEncode(outMsg);
          gd.sendSocketMessage(message);
        });
      },
      groupValue: effect,
    );
  }
}
