import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:flutter/material.dart';

class PopupMenuItemChoices extends StatefulWidget {
  final AppModel app;
  final bool isFirst;
  final bool isLast;
  final VoidCallback actionUp;
  final VoidCallback actionDown;
  final VoidCallback actionDetails;
  final VoidCallback actionDelete;

  PopupMenuItemChoices({
    Key? key, required this.app, required this.isFirst, required this.isLast, required this.actionUp, required this.actionDown, required this.actionDetails, required this.actionDelete,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PopupMenuItemChoicesState();
  }
}

class _PopupMenuItemChoicesState extends State<PopupMenuItemChoices> {
  @override
  Widget build(BuildContext context) {
    var menuItems = [
      if (widget.isFirst)
        popupMenuItem(
          widget.app, context,
          value: 1,
          label: 'Move up'
        ),
      if (widget.isLast)
        popupMenuItem(
          widget.app, context,
          value: 2,
          label: 'Move down'
        ),
      popupMenuItem(
        widget.app, context,
        value: 3,
        label: 'Details'
      ),
      popupMenuItem(
        widget.app, context,
        value: 4,
        label: 'Delete'
      ),
    ];
    return popupMenuButton<int>(
        widget.app, context,
        child: Icon(Icons.more_vert),
        itemBuilder: (context) => menuItems,
        onSelected: (value) {
          if (value == 1) {
            widget.actionUp();
          } else
          if (value == 2) {
            widget.actionDown();
          } else if (value == 3) {
            widget.actionDetails();
          } else if (value == 4) {
            widget.actionDelete();
          }
        });
  }
}