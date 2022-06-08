import 'package:eliud_core/core/base/model_base.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';

class JsonWidget<T extends ModelBase> extends StatefulWidget {
  final AppModel app;
  final T model;

  JsonWidget({
    Key? key,
    required this.app,
    required this.model,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _JsonWidgetState();
  }
}

class _JsonWidgetState extends State<JsonWidget> {
  late int selected;
  late List<DropdownMenuItem<int>> dropdownMenuItems;
  String? jsonString;

  @override
  Widget build(BuildContext context) {
    return topicContainer(widget.app, context,
          title: 'Json representation',
          collapsible: true,
          collapsed: true,
          children: [
            iconButton(widget.app, context, icon: Icon(Icons.copy),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(
                      text: getJsonString()));
                }),
            text(
                widget.app,
                context,
                getJsonString()),
          ]);
  }

  String getJsonString() {
    if (jsonString == null) {
      jsonString = widget.model.toJsonString(appId: widget.app.documentID);
    }
    return jsonString!;
  }
}
