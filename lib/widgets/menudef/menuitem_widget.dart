import 'package:eliud_core/model/conditions_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/style/frontend/has_text_form_field.dart';
import 'package:eliud_core/style/style_registry.dart';
import 'package:eliud_core/tools/icon_formfield.dart';
import 'package:eliud_pkg_create/widgets/condition/conditions_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MenuItemWidget extends StatefulWidget {
  final MenuItemModel menuItemModel;

  const MenuItemWidget({Key? key, required this.menuItemModel})
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
      widget.menuItemModel.action!.conditions = ConditionsModel(
        privilegeLevelRequired: PrivilegeLevelRequired.NoPrivilegeRequired,
      );
    }
    _textController.text =
        widget.menuItemModel.text != null ? widget.menuItemModel.text! : '';
    _descriptionController.text = widget.menuItemModel.description != null
        ? widget.menuItemModel.description!
        : '';

    return ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
      topicContainer(context,
          title: 'General',
          collapsible: true,
          collapsed: true,
          children: [
            textFormField(context,
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
            textFormField(context,
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
      topicContainer(context,
          title: 'Icon',
          collapsible: true,
          collapsed: true,
          children: [IconField(widget.menuItemModel.icon, _onIconChanged)]),
      if (widget.menuItemModel.action != null)
        topicContainer(context,
            title: 'Action',
            collapsible: true,
            collapsed: true,
            children: [
              _actionDescription(context),
            ]),
      if (widget.menuItemModel.action != null)
        ConditionsWidget(
            value: widget.menuItemModel.action!.conditions!,
            ownerType: 'menu item',
        comment: menuItemComment),
    ]);
  }

  Widget _actionDescription(BuildContext context) {
    if (widget.menuItemModel.action == null) return text(context, 'No action');
    return text(context, widget.menuItemModel.action!.describe());
  }

  void _onIconChanged(value) {
    widget.menuItemModel.icon = value;
  }
}
