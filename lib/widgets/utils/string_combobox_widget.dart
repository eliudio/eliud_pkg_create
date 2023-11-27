import 'package:eliud_core_main/model/app_model.dart';
import 'package:eliud_core_main/apis/style/frontend/has_button.dart';
import 'package:eliud_core_main/apis/style/frontend/has_text.dart';
import 'package:flutter/material.dart';

typedef Feedback = Function(int value);

class StringComboboxWidget extends StatefulWidget {
  final AppModel app;
  final String initialValue;
  final Feedback feedback;
  final List<String> options;
  final List<String>? descriptions;
  final String title;

  StringComboboxWidget({
    super.key,
    required this.app,
    required this.initialValue,
    required this.feedback,
    required this.options,
    this.descriptions,
    required this.title,
  });

  @override
  State<StatefulWidget> createState() {
    return _StringComboboxWidgetState();
  }
}

class _StringComboboxWidgetState extends State<StringComboboxWidget> {
  late int selected;
  late List<DropdownMenuItem<int>> dropdownMenuItems;

  void _onChange(int? newValue) {
    if (newValue != null) {
      setState(() {
        selected = newValue;
        widget.feedback(newValue);
      });
    }
  }

  @override
  void initState() {
    selected = widget.options.indexOf(widget.initialValue);
    dropdownMenuItems = [];
    for (int i = 0; i < widget.options.length; i++) {
      dropdownMenuItems.add(
        DropdownMenuItem<int>(
            value: i, child: text(widget.app, context, widget.options[i])),
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: inputDecorationLabel(widget.app, context, widget.title,
                maxLines: 5)),
        Align(
            alignment: Alignment.centerLeft,
            child: dropdownButton<int>(
              widget.app,
              context,
              isDense: false,
              isExpanded: false,
              items: dropdownMenuItems,
              value: selected,
              hint: text(widget.app, context, widget.title),
              onChanged: (value) => _onChange(value),
            )),
        if (widget.descriptions != null) Container(width: 30),
        if (widget.descriptions != null)
          Align(
              alignment: Alignment.centerLeft,
              child: text(widget.app, context, widget.descriptions![selected],
                  maxLines: 5))
      ],
    );
  }
}
