import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/material_design_icons.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/view/custom_popup_menu.dart';
import 'package:hasskit/view/entitycontrol/entity_control_parent.dart';
import 'package:provider/provider.dart';

class SliverNavigationBar extends StatelessWidget {
  final int roomIndex;
  const SliverNavigationBar({@required this.roomIndex});

  @override
  Widget build(BuildContext context) {
//    log.w("Widget build SliverNavigationBar");

    Widget temperatureWidget = Container();
//    Color backgroundColor;
    Color iconColor;

    IconData topIcon;
    if (gd.viewMode == ViewMode.edit || gd.viewMode == ViewMode.sort) {
      topIcon = MaterialDesignIcons.getIconDataFromIconName("mdi:content-save");
    } else {
      topIcon = Icons.menu;
    }

    return Selector<GeneralData, String>(
      selector: (_, generalData) => "${generalData.roomList.length} "
          "${generalData.roomList[roomIndex].imageIndex} "
          "${generalData.roomList[roomIndex].tempEntityId} "
          "${generalData.roomList[roomIndex].row2.length} "
          "${generalData.eventsEntities} "
          "${generalData.activeDevicesShow} "
          "${generalData.activeDevicesOn.length} "
          "${generalData.viewMode} ",
      builder: (context, data, child) {
        //        if (roomIndex != null &&
//            gd.roomList[roomIndex] != null &&
//            gd.roomList[roomIndex].tempEntityId != null &&
//            gd.roomList[roomIndex].tempEntityId.length > 0 &&
//            gd.entities[gd.roomList[roomIndex].tempEntityId].state != null &&
//            gd.entities[gd.roomList[roomIndex].tempEntityId].state.length > 0) {

        double tempState;
        try {
          tempState = double.tryParse(
              gd.entities[gd.roomList[roomIndex].tempEntityId].state);
        } catch (e) {
//          log.w("tempState $e");
        }

        if (tempState != null) {
//          log.d("tempState $tempState");

          if (tempState > 35) {
//            backgroundColor = ThemeInfo.colorTemp05.withOpacity(0.5);
            iconColor = ThemeInfo.colorTemp05;
          } else if (tempState > 30) {
//            backgroundColor = ThemeInfo.colorTemp04.withOpacity(0.5);
            iconColor = ThemeInfo.colorTemp04;
          } else if (tempState > 20) {
//            backgroundColor = ThemeInfo.colorTemp03.withOpacity(0.5);
            iconColor = ThemeInfo.colorTemp03;
          } else if (tempState > 15) {
//            backgroundColor = ThemeInfo.colorTemp02.withOpacity(0.5);
            iconColor = ThemeInfo.colorTemp02;
          } else {
//            backgroundColor = ThemeInfo.colorTemp01.withOpacity(0.5);
            iconColor = ThemeInfo.colorTemp01;
          }
          temperatureWidget = InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                elevation: 1,
                backgroundColor: ThemeInfo.colorBottomSheet,
                isScrollControlled: true,
                useRootNavigator: true,
                builder: (BuildContext context) {
                  return EntityControlParent(
                      entityId: gd.entities[gd.roomList[roomIndex].tempEntityId]
                          .entityId);
                },
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  MaterialDesignIcons.getIconDataFromIconName(
                      "mdi:thermometer"),
                  size: 24,
                  color: iconColor,
                ),
                Expanded(
                  child: Text(
                    "${tempState.toStringAsFixed(1)} ${gd.entities[gd.roomList[roomIndex].tempEntityId].unitOfMeasurement.trim()}",
                    textScaleFactor: gd.textScaleFactorFix,
                    style: TextStyle(color: ThemeInfo.colorBottomSheetReverse),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }

        return CupertinoSliverNavigationBar(
          leading: temperatureWidget,
          backgroundColor: ThemeInfo.colorBottomSheet.withOpacity(0.5),
          largeTitle: AutoSizeText(
            gd.getRoomName(roomIndex),
            style: TextStyle(color: ThemeInfo.colorBottomSheetReverse),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              gd.activeDevicesOn.length > 0
                  ? InkWell(
                      onTap: () {
                        gd.activeDevicesShow = !gd.activeDevicesShow;
                        if (gd.activeDevicesShow)
                          gd.viewNormalController.animateTo(0,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn);
                      },
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: <Widget>[
                          Icon(Icons.notifications,
                              color: Theme.of(context).textTheme.title.color),
                          Container(
                            width: 15,
                            height: 15,
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: ThemeInfo.colorIconActive,
                              shape: BoxShape.circle,
                            ),
                            child: FittedBox(
                              child: AutoSizeText(
                                "${gd.activeDevicesOn.length}",
                                style: TextStyle(color: Colors.white),
                                maxLines: 1,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  : Container(),
              gd.roomList.length > 0 && !gd.deviceSetting.settingLocked
                  ? InkWell(
                      onTap: () {
                        if (gd.viewMode != ViewMode.sort &&
                            gd.viewMode != ViewMode.edit) {
                          bottomSheetMenu.mainBottomSheet(roomIndex, context);
                        } else {
                          gd.viewMode = ViewMode.normal;
                        }
                      },
                      child: Container(
//                          padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
//                          decoration: BoxDecoration(
//                              borderRadius: BorderRadius.circular(4),
//                              color: Colors.black.withOpacity(0.5)),
                        child: Icon(
                          topIcon,
                          color: Theme.of(context).textTheme.title.color,
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        );
      },
    );
  }
}
