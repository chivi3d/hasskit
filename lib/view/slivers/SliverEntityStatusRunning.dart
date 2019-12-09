import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:provider/provider.dart';

class SliverEntityStatusRunning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var buttonSize = (gd.mediaQueryWidth / gd.layoutButtonCount);

    if (gd.isTablet && gd.mediaQueryOrientation == Orientation.landscape) {
      buttonSize = gd.mediaQueryLongestSide / gd.layoutButtonCount;
    }

    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.activeDevicesShow} " +
          "${generalData.activeDevicesOn.length} ",
      builder: (context, data, child) {
        List<Widget> status2ndRowButtons = [];

        for (var entity in gd.activeDevicesOn) {
          status2ndRowButtons.add(Status2ndRowItem(
            entityId: entity.entityId,
            buttonSize: buttonSize,
          ));
        }
        return gd.activeDevicesShow && gd.activeDevicesOn.length > 0
            ? SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      margin: EdgeInsets.fromLTRB(8, 2, 8, 2),
                      height: buttonSize / 2,
                      child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: status2ndRowButtons),
                    ),
                  ],
                ),
              )
            : SliverList(
                delegate: SliverChildListDelegate(
                  [],
                ),
              );
      },
    );
  }
}

class Status2ndRowItem extends StatelessWidget {
  const Status2ndRowItem({
    @required this.entityId,
    @required this.buttonSize,
  });

  final String entityId;
  final double buttonSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        gd.toggleStatus(gd.entities[entityId]);
        if (gd.activeDevicesOn.length <= 0) {
          gd.activeDevicesOffTimer(0);
        } else {
          gd.activeDevicesOffTimer(60);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(2),
        width: buttonSize - 9.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: entityId.contains("binary_sensor")
              ? ThemeInfo.colorBackgroundActive.withOpacity(0.1)
              : ThemeInfo.colorBackgroundActive,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: FittedBox(
                child: Icon(
                  MaterialDesignIcons.getIconDataFromIconName(
                      gd.entities[entityId].getDefaultIcon),
                  color: ThemeInfo.colorIconActive,
                  size: 100,
                ),
              ),
            ),
//            SizedBox(width: 4),
            Expanded(
              flex: 4,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AutoSizeText(
                  "${gd.textToDisplay(gd.entities[entityId].getOverrideName)}",
                  style: ThemeInfo.textNameButtonActive,
                  textScaleFactor: gd.textScaleFactor,
                  overflow: TextOverflow.ellipsis,
//                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
