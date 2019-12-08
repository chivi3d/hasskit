import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class EntityButton extends StatelessWidget {
  final String entityId;
  final Function onTapCallback;
  final Function onLongPressCallback;
  final Color borderColor;
  final String indicatorIcon;
  const EntityButton(
      {@required this.entityId,
      @required this.onTapCallback,
      @required this.onLongPressCallback,
      @required this.borderColor,
      @required this.indicatorIcon});

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.connectionStatus} " +
          "${generalData.eventEntity(entityId)} " +
          "${generalData.entities[entityId].getStateDisplay} " +
          "${generalData.entities[entityId].getOverrideName} " +
          "${generalData.entities[entityId].getOverrideIcon} ",
      builder: (context, data, child) {
        return Hero(
          tag: entityId,
          child: InkWell(
            onTap: onTapCallback,
            onLongPress: onLongPressCallback,
            child: gd.viewMode == ViewMode.sort
                ? EntityButtonDisplayAnimated(entityId: entityId)
                : EntityButtonDisplay(entityId: entityId),
          ),
        );
      },
    );
  }
}

class EntityButtonDisplayAnimated extends StatefulWidget {
  const EntityButtonDisplayAnimated({@required this.entityId});

  final String entityId;

  @override
  _EntityButtonDisplayAnimatedState createState() =>
      _EntityButtonDisplayAnimatedState();
}

class _EntityButtonDisplayAnimatedState
    extends State<EntityButtonDisplayAnimated>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: false);

    animation = Tween<double>(
      begin: 50.0,
      end: 120.0,
    ).animate(animationController);
  }

  vm.Vector3 shake() {
//    double progress = animationController.value;
//    double offset = sin(progress * pi * 10.0);
//    double offset = 1;
    return vm.Vector3(random.nextDouble() * random.nextInt(5),
        random.nextDouble() * random.nextInt(5), 0.0);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.translation(shake()),
          child: EntityButtonDisplay(entityId: widget.entityId),
        );
      },
    );
  }
}

class EntityButtonDisplay extends StatefulWidget {
  const EntityButtonDisplay({@required this.entityId});
  final String entityId;
  @override
  _EntityButtonDisplayState createState() => _EntityButtonDisplayState();
}

class _EntityButtonDisplayState extends State<EntityButtonDisplay> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          BorderRadius.all(Radius.circular(8 * 3 / gd.baseSetting.itemsPerRow)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          onEnd: () {
            setState(() {
              gd.clickedStatus.remove(widget.entityId);
            });
          },
          margin: gd.getClickedStatus(widget.entityId)
              ? EdgeInsets.fromLTRB(3, 3, 3, 3)
              : EdgeInsets.zero,
          padding: EdgeInsets.all(4 * 4 / gd.baseSetting.itemsPerRow),
          decoration: BoxDecoration(
            color: gd.entities[widget.entityId].isStateOn
                ? ThemeInfo.colorBackgroundActive
                : ThemeInfo.colorEntityBackground,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Text(
                        "${gd.textToDisplay(gd.entities[widget.entityId].getOverrideName)}",
                        style: gd.entities[widget.entityId].isStateOn
                            ? ThemeInfo.textNameButtonActive
                            : ThemeInfo.textNameButtonInActive,
                        maxLines: 2,
                        textScaleFactor:
                            gd.textScaleFactor * 3 / gd.baseSetting.itemsPerRow,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Stack(
                        children: <Widget>[
                          EntityIcon(entityId: widget.entityId),
                          EntityIconStatus(entityId: widget.entityId),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${gd.textToDisplay(gd.entities[widget.entityId].getStateDisplayTranslated(context))}",
                style: gd.entities[widget.entityId].isStateOn
                    ? ThemeInfo.textStatusButtonActive
                    : ThemeInfo.textStatusButtonInActive,
                maxLines: 1,
                textScaleFactor:
                    gd.textScaleFactor * 3 / gd.baseSetting.itemsPerRow,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EntityIconStatus extends StatelessWidget {
  const EntityIconStatus({
    Key key,
    @required this.entityId,
  }) : super(key: key);

  final String entityId;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: FittedBox(
        alignment: Alignment.centerRight,
        child: (gd.showSpin || gd.entities[entityId].state.contains("..."))
            ? SpinKitThreeBounce(
                size: 100,
                color: ThemeInfo.colorIconActive.withOpacity(0.5),
              )
            : Container(),
      ),
    );
  }
}

class EntityIcon extends StatelessWidget {
  final String entityId;

  const EntityIcon({@required this.entityId});
  @override
  Widget build(BuildContext context) {
//    log.d("Widget build _EntityIcon $entityId");

    var iconWidget;
    var entity = gd.entities[entityId];
    if (entity.entityId.contains("climate.")) {
      iconWidget = Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: gd.climateModeToColor(entity.state),
        ),
        child: FittedBox(
          child: Text(
            "${entity.getTemperature.toInt()}",
            style: ThemeInfo.textNameButtonActive.copyWith(
              color: ThemeInfo.colorBottomSheet,
            ),
            textScaleFactor: gd.textScaleFactor,
          ),
        ),
      );
    } else if (entity.entityId.contains("alarm_control_panel")) {
      iconWidget = FittedBox(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(
                entity.state.contains("disarmed")
                    ? MaterialDesignIcons.getIconDataFromIconName(
                        "mdi:shield-check")
                    : entity.state.contains("pending")
                        ? MaterialDesignIcons.getIconDataFromIconName(
                            "mdi:shield-outline")
                        : MaterialDesignIcons.getIconDataFromIconName(
                            "mdi:shield-lock"),
                color: entity.state.contains("disarmed")
                    ? Colors.green
                    : entity.state.contains("pending")
                        ? ThemeInfo.colorIconActive
                        : Colors.red),
          ],
        ),
      );
    } else if (entity.rgbColor.length > 2) {
      iconWidget = FittedBox(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(
              entity.mdiIcon,
              color: Color.fromRGBO(entity.rgbColor[0], entity.rgbColor[1],
                  entity.rgbColor[2], 1),
            ),
          ],
        ),
      );
    } else {
      iconWidget = FittedBox(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(
              entity.mdiIcon,
              color: entity.isStateOn ||
                      entity.entityId.contains("sensor.") &&
                          !entity.entityId.contains("binary_sensor.")
                  ? ThemeInfo.colorIconActive
                  : ThemeInfo.colorIconInActive,
            ),
          ],
        ),
      );
    }
    return AspectRatio(aspectRatio: 1, child: iconWidget);
  }
}
