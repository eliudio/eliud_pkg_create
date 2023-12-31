import 'package:eliud_core/decoration/decoration.dart' as deco;
import 'package:eliud_core_main/model/app_model.dart';
import 'package:eliud_core_main/apis/style/frontend/types.dart';
import 'package:eliud_core_main/apis/style/style_registry.dart';
import 'package:eliud_core_helpers/etc/screen_size.dart';
import 'package:flutter/material.dart';
import '../../tools/constants.dart';
import 'creator_button.dart';

typedef StateCallBack = void Function();

abstract class Action {
  void doIt(BuildContext context, double x, double y);
}

class SingleAction extends Action {
  final StateCallBack doThis;

  SingleAction(this.doThis);

  @override
  void doIt(
    BuildContext context,
    double x,
    double y,
  ) async {
    doThis();
  }
}

class ActionWithLabel {
  final String label;
  final StateCallBack doThis;

  ActionWithLabel(this.label, this.doThis);
}

class MultipleActions extends Action {
  final AppModel app;
  final List<ActionWithLabel> doThis;

  MultipleActions(this.app, this.doThis);

  @override
  void doIt(
    BuildContext context,
    double x,
    double y,
  ) async {
    var items = doThis
        .map((value) => MenuItemAttributes(
            label: value.label, isActive: true, onTap: () => value.doThis()))
        .toList();

    StyleRegistry.registry()
        .styleWithApp(app)
        .frontEndStyle()
        .menuStyle()
        .openMenu(
          app,
          context,
          position: RelativeRect.fromLTRB(x, y, x, y),
          menuItems: items,
        );

/*
    var value = await showMenu(
      context: context,
      color: Colors.red,
      position: RelativeRect.fromLTRB(x, y, x, y),
      items: doThis
          .map((value) => popupMenuItem<String>(
          app, context,
              label: value.label, value: value.label))
          .toList(),
      elevation: 8.0,
    );
    for (var item in doThis) {
      if (item.label == value) {
        item.doThis();
      }
    }
*/
  }
}

class MyDecoratedWidget extends StatefulWidget {
  final ValueNotifier<bool> isCreationMode;
  final deco.CreateWidget createOriginalWidget;
//  T model;
  final Key? originalWidgetKey;
  final bool ensureHeight;
  final InitialPosition initialPosition;
  final String? label;
  final Widget? icon;
  final Action action;

  MyDecoratedWidget({
    super.key,
    required this.isCreationMode,
    required this.originalWidgetKey,
//    required this.model,
    required this.createOriginalWidget,
    required this.ensureHeight,
    required this.initialPosition,
    this.label,
    this.icon,
    required this.action,
  });

  @override
  State<StatefulWidget> createState() {
    return _MyDecoratedDialogWidgetState();
  }
}

class _MyDecoratedDialogWidgetState extends State<MyDecoratedWidget> {
  Offset? onTapPosition;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.isCreationMode,
        builder: (context, value, child) {
          if ((value != null) && (value as bool)) {
//            return widget.createOriginalWidget();
            return CreatorButton(
                backgroundColor: Constants.backgroundColor,
                textColor: Constants.textColor,
                icon: widget.icon ??
                    Icon(
                      Icons.edit,
                      color: Constants.iconColor,
                      size: CreatorButton.buttonClient * .7,
                    ),
                borderColor: Constants.borderColor,
                ensureHeight: widget.ensureHeight,
                initialPosition: widget.initialPosition,
                toDecorateKey: widget.originalWidgetKey,
                toDecorate: widget.createOriginalWidget(),
                label: widget.label,
                onTap: () => widget.action.doIt(
                      context,
                      onTapPosition == null
                          ? fullScreenWidth(context) / 2
                          : onTapPosition!.dx,
                      onTapPosition == null
                          ? fullScreenHeight(context) / 2
                          : onTapPosition!.dy,
                    ),
                onTapDown: (TapDownDetails details) =>
                    onTapPosition = details.globalPosition);
          } else {
            return widget.createOriginalWidget();
          }
        });
  }
}
