import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/model/Entity.dart';

class TemperatureDropdownButton extends StatefulWidget {
  final int roomIndex;
  const TemperatureDropdownButton({@required this.roomIndex});

  @override
  _TemperatureDropdownButtonState createState() =>
      _TemperatureDropdownButtonState();
}

class _TemperatureDropdownButtonState extends State<TemperatureDropdownButton> {
  @override
  Widget build(BuildContext context) {
    var selectedValue = gd.roomList[widget.roomIndex].tempEntityId;
    List<DropdownMenuItem<String>> dropdownMenuItems = [];

    List<Entity> entities = gd.entities.values
        .where((e) =>
            !e.entityId.contains("binary_sensor.") &&
            e.entityId.contains("sensor.") &&
            double.tryParse(e.state) != null)
        .toList();
    entities.sort((a, b) => gd
        .textToDisplay(a.getOverrideName)
        .compareTo(gd.textToDisplay(b.getOverrideName)));

    for (Entity entity in entities) {
      var dropdownMenuItem = DropdownMenuItem<String>(
        value: entity.entityId,
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(4, 2, 2, 2),
          title: Text(
            gd.textToDisplay("${entity.getFriendlyName}"),
            style: Theme.of(context).textTheme.body1,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: gd.textScaleFactorFix,
          ),
          trailing: Text(
            "${double.parse(entity.state).toStringAsFixed(1)} ${entity.unitOfMeasurement.trim()}",
            style: Theme.of(context).textTheme.body1,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: gd.textScaleFactorFix,
          ),
        ),
      );
      dropdownMenuItems.add(dropdownMenuItem);
    }
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "${gd.roomList[widget.roomIndex].name} Temperature",
                overflow: TextOverflow.ellipsis,
                textScaleFactor: gd.textScaleFactorFix,
              ),
              DropdownButton<String>(
                underline: Container(),
                isExpanded: true,
                value: selectedValue,
                items: dropdownMenuItems,
                onChanged: (String newValue) {
                  setState(() {
                    gd.roomList[widget.roomIndex].tempEntityId = newValue;
                  });
                },
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
