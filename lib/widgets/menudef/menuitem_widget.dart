import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/display_conditions_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/style/frontend/has_text_form_field.dart';
import 'package:eliud_core/style/style_registry.dart';
import 'package:eliud_core/tools/icon_formfield.dart';
import 'package:eliud_pkg_create/widgets/condition/display_conditions_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MenuItemWidget extends StatefulWidget {
  final AppModel app;
  final MenuItemModel menuItemModel;

  const MenuItemWidget({Key? key, required this.app, required this.menuItemModel})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MenuItemWidgetState();
}

class _MenuItemWidgetState extends State<MenuItemWidget> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _descriptionController.addListener(_onDescriptionChanged);
  }

  void _onTextChanged() {
    widget.menuItemModel.text = _textController.text;
  }

  void _onDescriptionChanged() {
    widget.menuItemModel.description = _descriptionController.text;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.menuItemModel.action != null) {
      widget.menuItemModel.action!.conditions = DisplayConditionsModel(
        privilegeLevelRequired: PrivilegeLevelRequired.NoPrivilegeRequired,
      );
    }
    _textController.text =
        widget.menuItemModel.text != null ? widget.menuItemModel.text! : '';
    _descriptionController.text = widget.menuItemModel.description != null
        ? widget.menuItemModel.description!
        : '';

    return ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
      topicContainer(widget.app, context,
          title: 'General',
          collapsible: true,
          collapsed: true,
          children: [
            textFormField(widget.app, context,
                readOnly: false,
                labelText: 'text',
                icon: Icons.text_format,
                textEditingController: _textController,
                keyboardType: TextInputType.text, validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter text';
              }
              return null;
            }, hintText: ''),
            textFormField(widget.app, context,
                readOnly: false,
                labelText: 'description',
                icon: Icons.text_format,
                textEditingController: _descriptionController,
                keyboardType: TextInputType.text, validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter description';
              }
              return null;
            }, hintText: '')
          ]),
      topicContainer(widget.app, context,
          title: 'Icon',
          collapsible: true,
          collapsed: true,
          children: [IconField(widget.app, widget.menuItemModel.icon, _onIconChanged)]),
      if (widget.menuItemModel.action != null)
        topicContainer(widget.app, context,
            title: 'Action',
            collapsible: true,
            collapsed: true,
            children: [
              _actionDescription(context),
            ]),
      if (widget.menuItemModel.action != null)
        DisplayConditionsWidget(app: widget.app,
            value: widget.menuItemModel.action!.conditions!),
    ]);
  }

  Widget _actionDescription(BuildContext context) {
    if (widget.menuItemModel.action == null) return text(widget.app, context, 'No action');
    return text(widget.app, context, widget.menuItemModel.action!.describe());
  }

  void _onIconChanged(value) {
    widget.menuItemModel.icon = value;
  }
}
