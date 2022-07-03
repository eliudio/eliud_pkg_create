import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum JsonDestination { Clipboard, MemberMedium}

JsonDestination toJsonDestination(int? index) {
  if (index == 0) {
    return JsonDestination.Clipboard;
  } else {
    return JsonDestination.MemberMedium;
  }
}



typedef JsonDestinationCallback = Function(
    JsonDestination jsonDestination);

class JsonDestinationWidget extends StatefulWidget {
  JsonDestinationCallback jsonDestinationCallback;
  final JsonDestination jsonDestination;
  final AppModel app;
  JsonDestinationWidget(
      {Key? key,
        required this.app,
        required this.jsonDestinationCallback,
        required this.jsonDestination})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _JsonDestinationWidgetState();
  }
}

class _JsonDestinationWidgetState extends State<JsonDestinationWidget> {
  int? _heightTypeSelectedRadioTile;

  void initState() {
    super.initState();
    _heightTypeSelectedRadioTile = widget.jsonDestination.index;
  }

  String heighttTypeLandscapeStringValue(JsonDestination? jsonDestination) {
    switch (jsonDestination) {
      case JsonDestination.Clipboard:
        return 'Clipboard';
      case JsonDestination.MemberMedium:
        return 'Member Medium';
    }
    return '?';
  }

  void setSelection(int? val) {
    setState(() {
      _heightTypeSelectedRadioTile = val;
      widget.jsonDestinationCallback(toJsonDestination(val));
    });
  }

  Widget getPrivilegeOption(JsonDestination? jsonDestination) {
    if (jsonDestination == null) return Text("?");
    var stringValue = heighttTypeLandscapeStringValue(jsonDestination);
    return Center(
        child: radioListTile(
            widget.app,
            context,
            jsonDestination.index,
            _heightTypeSelectedRadioTile,
            stringValue,
            null,
                (dynamic val) => setSelection(val)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      getPrivilegeOption(JsonDestination.MemberMedium),
      getPrivilegeOption(JsonDestination.Clipboard)
    ], shrinkWrap: true, physics: ScrollPhysics());
  }
}
