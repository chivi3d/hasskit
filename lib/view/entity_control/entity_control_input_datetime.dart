import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/web_socket.dart';
import 'package:intl/intl.dart';

class EntityControlInputDateTime extends StatefulWidget {
  final String entityId;
  const EntityControlInputDateTime({@required this.entityId});

  @override
  _EntityControlInputDateTimeState createState() =>
      _EntityControlInputDateTimeState();
}

class _EntityControlInputDateTimeState
    extends State<EntityControlInputDateTime> {
  DateTime entityStateDateTime;
  String entityState;
  @override
  void initState() {
    super.initState();
    entityState = gd.entities[widget.entityId].state;
    if (entityState.contains("-")) {
      entityStateDateTime = DateTime.parse(entityState);
    } else {
      entityStateDateTime = DateTime.parse("2020-01-01 " + entityState);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget pickerDateTime() {
      return CupertinoDatePicker(
        backgroundColor: Colors.transparent,
        initialDateTime: entityStateDateTime,
        onDateTimeChanged: (DateTime newDate) {
          String newValue = DateFormat("yyyy-MM-dd HH:mm:ss").format(newDate);
          print("date $newValue");
          var outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": "input_datetime",
            "service": "set_datetime",
            "service_data": {
              "entity_id": widget.entityId,
              "datetime": newValue,
            }
          };
          var outMsgEncoded = json.encode(outMsg);
          webSocket.send(outMsgEncoded);
        },
        use24hFormat: true,
        mode: CupertinoDatePickerMode.dateAndTime,
      );
    }

    Widget pickerDate() {
      return CupertinoDatePicker(
        backgroundColor: Colors.transparent,
        initialDateTime: entityStateDateTime,
        onDateTimeChanged: (DateTime newDate) {
          String newValue = DateFormat("yyyy-MM-dd").format(newDate);
          print("date $newValue");
          var outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": "input_datetime",
            "service": "set_datetime",
            "service_data": {
              "entity_id": widget.entityId,
              "date": newValue,
            }
          };
          var outMsgEncoded = json.encode(outMsg);
          webSocket.send(outMsgEncoded);
        },
        use24hFormat: true,
        mode: CupertinoDatePickerMode.date,
      );
    }

    Widget pickerTime() {
      return CupertinoDatePicker(
        backgroundColor: Colors.transparent,
        initialDateTime: entityStateDateTime,
        onDateTimeChanged: (DateTime newDate) {
          String newValue = DateFormat("HH:mm:ss").format(newDate);
          print("time $newValue");
          var outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": "input_datetime",
            "service": "set_datetime",
            "service_data": {
              "entity_id": widget.entityId,
              "time": newValue,
            }
          };
          var outMsgEncoded = json.encode(outMsg);
          webSocket.send(outMsgEncoded);
        },
        use24hFormat: true,
        mode: CupertinoDatePickerMode.time,
      );
    }

    return Column(
      children: <Widget>[
        Spacer(),
        Container(
          width: 300,
          height: 187.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey.withOpacity(1),
                  Colors.white.withOpacity(1),
                  Colors.grey.withOpacity(1),
                ]),
          ),
          child: gd.entities[widget.entityId].state.contains(":") &&
                  gd.entities[widget.entityId].state.contains("-")
              ? pickerDateTime()
              : gd.entities[widget.entityId].state.contains("-")
                  ? pickerDate()
                  : pickerTime(),
        ),
        Spacer(),
      ],
    );
  }
}
