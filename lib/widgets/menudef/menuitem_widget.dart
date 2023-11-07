import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/display_conditions_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_dialog_field.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/icon_formfield.dart';
import 'package:eliud_pkg_create/widgets/condition/display_conditions_widget.dart';
import 'package:flutter/material.dart';

class MenuItemWidget extends StatefulWidget {
  final AppModel app;
  final MenuItemModel menuItemModel;

  const MenuItemWidget(
      {super.key, required this.app, required this.menuItemModel});

  @override
  State<StatefulWidget> createState() => _MenuItemWidgetState();
}

class _MenuItemWidgetState extends State<MenuItemWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.menuItemModel.action != null) &&
        (widget.menuItemModel.action!.conditions == null)) {
      widget.menuItemModel.action!.conditions = DisplayConditionsModel(
        privilegeLevelRequired: PrivilegeLevelRequired.noPrivilegeRequired,
      );
    }

    return ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
      topicContainer(widget.app, context,
          title: 'General',
          collapsible: true,
          collapsed: true,
          children: [
            dialogField(widget.app, context,
                initialValue: widget.menuItemModel.text, valueChanged: (value) {
              widget.menuItemModel.text = value;
            },
                maxLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Text',
                  labelText: 'Text',
                )),
            dialogField(widget.app, context,
                initialValue: widget.menuItemModel.description,
                valueChanged: (value) {
              widget.menuItemModel.description = value;
            },
                maxLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Description',
                  labelText: 'Description',
                )),
          ]),
      topicContainer(widget.app, context,
          title: 'Icon',
          collapsible: true,
          collapsed: true,
          children: [
            IconField(widget.app, widget.menuItemModel.icon, _onIconChanged)
          ]),
      if (widget.menuItemModel.action != null)
        topicContainer(widget.app, context,
            title: 'Action',
            collapsible: true,
            collapsed: true,
            children: [
              _actionDescription(context),
            ]),
      if (widget.menuItemModel.action != null)
        DisplayConditionsWidget(
            app: widget.app, value: widget.menuItemModel.action!.conditions!),
    ]);
  }

  Widget _actionDescription(BuildContext context) {
    if (widget.menuItemModel.action == null) {
      return text(widget.app, context, 'No action');
    }
    return text(widget.app, context, widget.menuItemModel.action!.describe());
  }

  void _onIconChanged(value) {
    widget.menuItemModel.icon = value;
  }
}
