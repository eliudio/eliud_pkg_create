import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum JsonDestination { clipboard, memberMedium, url }

JsonDestination toJsonDestination(int? index) {
  if (index == 0) return JsonDestination.clipboard;
  if (index == 1) return JsonDestination.memberMedium;
  return JsonDestination.url;
}

typedef JsonDestinationCallback = Function(JsonDestination jsonDestination);

class JsonDestinationWidget extends StatefulWidget {
  final JsonDestinationCallback jsonDestinationCallback;
  final JsonDestination jsonDestination;
  final AppModel app;
  JsonDestinationWidget(
      {super.key,
      required this.app,
      required this.jsonDestinationCallback,
      required this.jsonDestination});

  @override
  State<StatefulWidget> createState() {
    return _JsonDestinationWidgetState();
  }
}

class _JsonDestinationWidgetState extends State<JsonDestinationWidget> {
  int? _heightTypeSelectedRadioTile;

  @override
  void initState() {
    super.initState();
    _heightTypeSelectedRadioTile = widget.jsonDestination.index;
  }

  String heighttTypeLandscapeStringValue(JsonDestination? jsonDestination) {
    switch (jsonDestination) {
      case JsonDestination.clipboard:
        return 'Clipboard';
      case JsonDestination.memberMedium:
        return 'Member Medium';
      case JsonDestination.url:
        return 'URL';
      case null:
        break;
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
      getPrivilegeOption(JsonDestination.memberMedium),
      getPrivilegeOption(JsonDestination.url),
      getPrivilegeOption(JsonDestination.clipboard)
    ], shrinkWrap: true, physics: ScrollPhysics());
  }
}
