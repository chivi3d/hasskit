import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:provider/provider.dart';

class SliverEntityStatusRunning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    final buttonSize = (gd.mediaQueryWidth - (12 * 2) - (10 * 5)) / 6;
    final buttonSize = (gd.mediaQueryWidth * 0.1);
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.activeDevicesShow} " +
          "${generalData.activeDevicesOn.length} ",
      builder: (context, data, child) {
        List<Widget> status2ndRowButtons = [];

        for (var entity in gd.activeDevicesOn) {
          status2ndRowButtons.add(Status2ndRowItem(entityId: entity.entityId));
        }
        return gd.activeDevicesShow && gd.activeDevicesOn.length > 0
            ? SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      margin: EdgeInsets.fromLTRB(8, 2, 8, 2),
                      height: buttonSize,
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
  });

  final String entityId;

  @override
  Widget build(BuildContext context) {
    final buttonSize = (gd.mediaQueryWidth * 0.1);
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
        width: buttonSize / 9 * 21,
        height: buttonSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(buttonSize / 8),
          color: entityId.contains("binary_sensor")
              ? ThemeInfo.colorBackgroundActive.withOpacity(0.1)
              : ThemeInfo.colorBackgroundActive,
        ),
        child: Row(
          children: <Widget>[
            FittedBox(
              child: Icon(
                MaterialDesignIcons.getIconDataFromIconName(
                    gd.entities[entityId].getDefaultIcon),
                color: ThemeInfo.colorIconActive,
                size: 100,
              ),
            ),
//            SizedBox(width: 4),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: AutoSizeText(
                  "${gd.textToDisplay(gd.entities[entityId].getOverrideName)}",
                  style: ThemeInfo.textNameButtonActive,
                  textScaleFactor: gd.textScaleFactorFix,
                  overflow: TextOverflow.ellipsis,
//                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
