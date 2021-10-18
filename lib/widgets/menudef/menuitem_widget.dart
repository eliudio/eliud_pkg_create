import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/style/frontend/has_text_form_field.dart';
import 'package:eliud_core/style/style_registry.dart';
import 'package:eliud_core/tools/icon_formfield.dart';
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
    _textController.text = widget.menuItemModel.text != null ? widget.menuItemModel.text! : '';
    _descriptionController.text = widget.menuItemModel.description != null ? widget.menuItemModel.description! : '';

    List<Widget> children = [];
    children.add(Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: h1(context, 'General')));

    children.add(textFormField(context,
            readOnly: false,
            labelText: 'text',
            icon: Icons.text_format,
            textEditingController: _textController,
            keyboardType: TextInputType.text, validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter text';
      }
      return null;
    }, hintText: ''));

    children.add(textFormField(context,
        readOnly: false,
        labelText: 'description',
        icon: Icons.text_format,
        textEditingController: _descriptionController,
        keyboardType: TextInputType.text, validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter description';
          }
          return null;
        }, hintText: ''));

    children.add(Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: h1(context, 'Icon')));

    children.add(IconField(widget.menuItemModel.icon, _onIconChanged));

    children.add(Container(height: 20.0));
    children.add(divider(context));
    return simpleTopicContainer(
            context,
            children: children as List<Widget>);
  }

  void _onIconChanged(value) {
  }
}
