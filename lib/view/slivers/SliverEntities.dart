import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/model/Entity.dart';
import 'package:hasskit/view/EntityControl/EntityControlCameraWebView.dart';
import 'package:hasskit/view/EntityControl/EntityControlCameraVideoPlayer.dart';
import 'package:reorderables/reorderables.dart';
import '../EntityControl/EntityControlParent.dart';
import '../EntityCamera.dart';
import '../EntityButton.dart';

class SliverEntitiesNormal extends StatelessWidget {
  final int roomIndex;
  final double aspectRatio;
  final bool isCamera;
  final List<Entity> entities;

  const SliverEntitiesNormal({
    @required this.roomIndex,
    @required this.aspectRatio,
    @required this.isCamera,
    @required this.entities,
  });
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.all(12),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              isCamera ? gd.layoutCameraCount : gd.layoutButtonCount,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: aspectRatio,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return entities[index].entityType == EntityType.cameras
                ? EntityCamera(
                    entityId: entities[index].entityId,
                    borderColor: Colors.transparent,
                    onTapCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesNormal onTapCallback");
                      gd.cameraStreamUrl = "";
                      gd.cameraStreamId = 0;
                      gd.requestCameraStream(entities[index].entityId);

                      showModalBottomSheet(
                        context: context,
                        backgroundColor: ThemeInfo.colorBottomSheet,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        builder: (BuildContext context) {
                          return Theme.of(context).platform ==
                                  TargetPlatform.iOS
                              ? EntityControlCameraWebView(
                                  entityId: entities[index].entityId)
                              : EntityControlCameraVideoPlayer(
                                  entityId: entities[index].entityId);
                        },
                      );
                    },
                    onLongPressCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesNormal onTapCallback");
                      gd.cameraStreamUrl = "";
                      gd.cameraStreamId = 0;
                      gd.requestCameraStream(entities[index].entityId);

                      showModalBottomSheet(
                        context: context,
                        backgroundColor: ThemeInfo.colorBottomSheet,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        builder: (BuildContext context) {
                          return Theme.of(context).platform ==
                                  TargetPlatform.iOS
                              ? EntityControlCameraWebView(
                                  entityId: entities[index].entityId)
                              : EntityControlCameraVideoPlayer(
                                  entityId: entities[index].entityId);
                        },
                      );
                    },
                  )
                : EntityButton(
                    entityId: entities[index].entityId,
                    borderColor: Colors.transparent,
                    onTapCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesNormal onTapCallback");

                      if (entities[index].entityType == EntityType.group ||
                          entities[index].entityType ==
                              EntityType.mediaPlayers ||
                          entities[index].entityType ==
                              EntityType.climateFans ||
                          entities[index].entityType ==
                              EntityType.accessories ||
                          entities[index].entityType == EntityType.cameras ||
                          !entities[index].isStateOn &&
                              gd.entitiesOverride[entities[index].entityId] !=
                                  null &&
                              gd.entitiesOverride[entities[index].entityId]
                                      .openRequireAttention !=
                                  null ||
                          entities[index].entityId.contains('lock.') &&
                              !entities[index].isStateOn ||
                          entities[index].currentPosition != null) {
                        showModalBottomSheet(
                          context: context,
                          elevation: 1,
                          backgroundColor: ThemeInfo.colorBottomSheet,
                          isScrollControlled: true,
                          useRootNavigator: true,
                          builder: (BuildContext context) {
                            return EntityControlParent(
                                entityId: entities[index].entityId);
                          },
                        );
                      } else {
                        gd.toggleStatus(entities[index]);
                        gd.clickedStatus[entities[index].entityId] = true;
                      }
                    },
                    onLongPressCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesNormal onLongPressCallback");
                      showModalBottomSheet(
                        context: context,
                        elevation: 1,
                        backgroundColor: ThemeInfo.colorBottomSheet,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        builder: (BuildContext context) {
                          return EntityControlParent(
                              entityId: entities[index].entityId);
                        },
                      );
                    },
                    indicatorIcon: "SliverEntitiesNormal",
                  );
          },
          childCount: entities.length,
        ),
      ),
    );
  }
}

class SliverEntitiesEdit extends StatelessWidget {
  final int roomIndex;
  final int itemPerRow;
  final List<Entity> entities;
  final bool clickToAdd;
  final Color borderColor;

  const SliverEntitiesEdit({
    @required this.roomIndex,
    @required this.itemPerRow,
    @required this.clickToAdd,
    @required this.entities,
    @required this.borderColor,
  });
  @override
  Widget build(BuildContext context) {
    if (entities.length < 1) {
      return gd.emptySliver;
    }
    return SliverPadding(
      padding: EdgeInsets.all(12),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: itemPerRow,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: itemPerRow == 1 ? 8 / 5 : 8 / 5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return itemPerRow == 1
                ? EntityCamera(
                    entityId: entities[index].entityId,
                    borderColor: borderColor,
                    onTapCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesEdit onTapCallback");

                      if (!clickToAdd) {
                        gd.removeEntityInRoom(
                            entities[index].entityId,
                            roomIndex,
                            entities[index].getOverrideName,
                            context);
                      } else {
                        gd.showEntityInRoom(entities[index].entityId, roomIndex,
                            entities[index].getOverrideName, context);
                      }
                    },
                    onLongPressCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesEdit onLongPressCallback");

                      if (!clickToAdd) {
                        gd.removeEntityInRoom(
                            entities[index].entityId,
                            roomIndex,
                            entities[index].getOverrideName,
                            context);
                      } else {
                        gd.showEntityInRoom(entities[index].entityId, roomIndex,
                            entities[index].getOverrideName, context);
                      }
                    },
                  )
                : EntityButton(
                    entityId: entities[index].entityId,
                    borderColor: borderColor,
                    onTapCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesEdit onTapCallback");

                      if (!clickToAdd) {
                        gd.removeEntityInRoom(entities[index].entityId,
                            roomIndex, entities[index].friendlyName, context);
                      } else {
                        gd.showEntityInRoom(entities[index].entityId, roomIndex,
                            entities[index].friendlyName, context);
                      }
                    },
                    onLongPressCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesEdit onLongPressCallback");
                      if (!clickToAdd) {
                        gd.removeEntityInRoom(entities[index].entityId,
                            roomIndex, entities[index].friendlyName, context);
                      } else {
                        gd.showEntityInRoom(entities[index].entityId, roomIndex,
                            entities[index].friendlyName, context);
                      }
                    },
                    indicatorIcon: "SliverEntitiesEdit+$clickToAdd",
                  );
          },
          childCount: entities.length,
        ),
      ),
    );
  }
}

class SliverEntitiesSort extends StatelessWidget {
  final int roomIndex;
  final int rowNumber;
  final bool isCamera;
  final double aspectRatio;

  final List<Entity> entities;

  const SliverEntitiesSort({
    @required this.roomIndex,
    @required this.rowNumber,
    @required this.isCamera,
    @required this.aspectRatio,
    @required this.entities,
  });

  @override
  Widget build(BuildContext context) {
    if (entities.length < 2) {
      return SliverEntitiesNormal(
        roomIndex: roomIndex,
        entities: entities,
        isCamera: isCamera,
        aspectRatio: aspectRatio,
      );
    }

    var totalWidth = gd.mediaQueryWidth;

    var totalItemPerRow =
        isCamera ? gd.layoutCameraCount : gd.layoutButtonCount;
    if (totalItemPerRow < 1) totalItemPerRow = 1;
    var totalSpaceBetween = 8 * totalItemPerRow - 1;
    var width = (totalWidth - totalSpaceBetween - 8 * 2) / totalItemPerRow;
    log.d(
        "gd.mediaQueryWidth ${gd.mediaQueryWidth} totalWidth $totalWidth  totalItemPerRow $totalItemPerRow");
    List<Widget> entityShape = [];

    for (Entity entity in entities) {
      Widget widget = new Transform.scale(
        scale: 1,
        child: Container(
          width: width,
          height: width * 1 / aspectRatio,
          child: entity.entityType == EntityType.cameras
              ? EntityCamera(
                  entityId: entity.entityId,
                  borderColor: ThemeInfo.colorIconActive,
                  onTapCallback: null,
                  onLongPressCallback: null)
              : EntityButton(
                  entityId: entity.entityId,
                  borderColor: ThemeInfo.colorIconActive,
                  onTapCallback: null,
                  onLongPressCallback: null,
                  indicatorIcon: "SliverEntitiesSort",
                ),
        ),
      );
      entityShape.add(widget);
    }

    void _onReorder(int oldIndex, int newIndex) {
      String oldEntityId = entities[oldIndex].entityId;
      String newEntityId = entities[newIndex].entityId;
      gd.roomEntitySort(roomIndex, rowNumber, oldEntityId, newEntityId);
    }

    var wrap = ReorderableWrap(
      needsLongPressDraggable: false,
      spacing: 8,
      runSpacing: 8,
      padding: const EdgeInsets.all(0),
      children: entityShape,
      onReorder: _onReorder,
      onNoReorder: (int index) {
        //this callback is optional
        log.w("reorder cancelled. index: $index");
      },
      onReorderStarted: (int index) {
        //this callback is optional
        log.w("reorder started. index: $index");
        gd.delayCancelSortModeTimer(300);
      },
    );

//    var wrapCentered = Center(
//      child: wrap,
//    );

    return SliverPadding(
      padding: EdgeInsets.all(8),
      sliver: SliverList(
        delegate: SliverChildListDelegate([wrap]),
      ),
    );
  }
}
