import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PopupMenuItemChoices extends StatefulWidget {
  final bool isFirst;
  final bool isLast;
  final VoidCallback actionUp;
  final VoidCallback actionDown;
  final VoidCallback actionDetails;
  final VoidCallback actionDelete;

  PopupMenuItemChoices({
    Key? key, required this.isFirst, required this.isLast, required this.actionUp, required this.actionDown, required this.actionDetails, required this.actionDelete,
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
        PopupMenuItem(
          value: 1,
          child: text(context, 'Move up'),
        ),
      if (widget.isLast)
        PopupMenuItem(
          value: 2,
          child: text(context, 'Move down'),
        ),
      PopupMenuItem(
        value: 3,
        child: text(context, 'Details'),
      ),
      PopupMenuItem(
        value: 4,
        child: text(context, 'Delete'),
      ),
    ];
    return PopupMenuButton<int>(
        child: Icon(Icons.more_vert),
        elevation: 10,
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