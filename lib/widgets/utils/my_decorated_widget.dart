import 'package:eliud_core/decoration/decoration.dart' as deco;
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_pkg_etc/widgets/decorator/creator_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import '../../tools/constants.dart';

typedef StateCallBack = void Function();

abstract class Action {
  void doIt(BuildContext context, double x, double y);
}

class SingleAction extends Action {
  final StateCallBack doThis;

  SingleAction(this.doThis);

  void doIt(
      BuildContext context, double x, double y, ) async {
    doThis();
  }
}

class ActionWithLabel {
  final String label;
  final StateCallBack doThis;

  ActionWithLabel(this.label, this.doThis);
}

class MultipleActions extends Action {
  final List<ActionWithLabel> doThis;

  MultipleActions(this.doThis);

  void doIt(
      BuildContext context, double x, double y, ) async {
    var value = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(x, y, x, y),
      items: doThis
          .map((value) => PopupMenuItem<String>(
              child: text(context, value.label), value: value.label))
          .toList(),
      elevation: 8.0,
    );
    for (var item in doThis) {
      if (item.label == value) {
        item.doThis();
      }
    }
  }
}

class MyDecoratedWidget<T> extends StatefulWidget {
  final ValueNotifier<bool> isCreationMode;
  final deco.CreateWidget createOriginalWidget;
  T model;
  final Key? originalWidgetKey;
  final bool ensureHeight;
  final InitialPosition initialPosition;
  final String label;
  final Action action;

  MyDecoratedWidget({
    Key? key,
    required this.isCreationMode,
    required this.originalWidgetKey,
    required this.model,
    required this.createOriginalWidget,
    required this.ensureHeight,
    required this.initialPosition,
    required this.label,
    required this.action,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MyDecoratedDialogWidgetState();
  }
}

class _MyDecoratedDialogWidgetState extends State<MyDecoratedWidget> {
  Offset? onTapPosition = null;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.isCreationMode,
        builder: (context, value, child) {
          if ((value != null) && (value as bool)) {
//            return widget.createOriginalWidget();
            return CreatorButton(
                backgroundColor: Constants.BACKGROUND_COLOR,
                textColor: Constants.TEXT_COLOR,
                icon: Icon(
                  Icons.edit,
                  color: Constants.ICON_COLOR,
                  size: 15,
                ),
                borderColor: Constants.BORDER_COLOR,
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
