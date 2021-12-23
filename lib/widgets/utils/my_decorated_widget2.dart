import 'package:eliud_core/decoration/decoration.dart' as deco;
import 'package:eliud_pkg_create/tools/constants.dart';
import 'package:eliud_pkg_etc/widgets/decorator/creator_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

typedef StateCallBack = void Function(_MyDecoratedDialogWidgetState2 state);

class MyDecoratedWidget2<T> extends StatefulWidget {
  final deco.CreateWidget createOriginalWidget;
  T model;
  final Key? originalWidgetKey;
  final bool ensureHeight;
  final InitialPosition initialPosition;
  final String? label;
  final StateCallBack action;

  MyDecoratedWidget2({
    Key? key,
    required this.originalWidgetKey,
    required this.model,
    required this.createOriginalWidget,
    required this.ensureHeight,
    required this.initialPosition,
    this.label,
    required this.action,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MyDecoratedDialogWidgetState2();
  }
}

class _MyDecoratedDialogWidgetState2
    extends State<MyDecoratedWidget2> {

  void setTheState(VoidCallback fn) => super.setState(fn);

  @override
  Widget build(BuildContext context) {
    return CreatorButton(
                backgroundColor: Constants.BACKGROUND_COLOR,
                textColor: Constants.TEXT_COLOR,
                icon: Icon(
                  Icons.palette_outlined,
                  color: Constants.ICON_COLOR,
                  size: CreatorButton.BUTTON_HEIGHT * .7,
                ),
                borderColor: Constants.BORDER_COLOR,
                ensureHeight: widget.ensureHeight,
                initialPosition: widget.initialPosition,
                toDecorateKey: widget.originalWidgetKey,
                toDecorate: widget.createOriginalWidget(),
                label: widget.label,
                onTap: () => widget.action(this));
  }
}
