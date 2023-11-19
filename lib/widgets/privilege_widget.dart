import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/blocs/access/access_event.dart';
import 'package:eliud_core/core/blocs/access/state/access_state.dart';
import 'package:eliud_core/core/blocs/access/state/logged_in.dart';
import 'package:eliud_core/model/access_model.dart';
import 'package:eliud_core_model/model/app_model.dart';
import 'package:eliud_core_model/style/frontend/has_button.dart';
import 'package:eliud_core_model/style/frontend/has_container.dart';
import 'package:eliud_core_model/style/frontend/has_list_tile.dart';
import 'package:eliud_core_model/style/frontend/has_text.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/*
 * Allows to change the privilege
 */
class PrivilegeWidget extends StatefulWidget {
  final AccessState currentAccess;
  final AppModel app;
  PrivilegeWidget({super.key, required this.app, required this.currentAccess});

  @override
  State<StatefulWidget> createState() {
    return _PrivilegeWidgetState();
  }
}

class _PrivilegeWidgetState extends State<PrivilegeWidget> {
  var isBlocked = false;
  PrivilegeLevel? currentLevel;
  int? _privSelectedRadioTile;
  late String appLevel;
  late String appBlocked;

  @override
  void initState() {
    super.initState();
    if (widget.currentAccess is LoggedIn) {
      var theAccess = widget.currentAccess as LoggedIn;
      isBlocked = theAccess.isBlocked(widget.app.documentID);
      currentLevel = theAccess.getPrivilegeLevel(widget.app.documentID);
      appLevel = 'Current level: ${privStringValue(currentLevel)}';
      appBlocked = 'Blocked: ${isBlocked ? 'yes' : 'no'}';
    } else {
      appLevel = '?';
      currentLevel = PrivilegeLevel.unknown;
    }
    _privSelectedRadioTile = currentLevel != null ? currentLevel!.index : 0;
  }

  String privStringValue(PrivilegeLevel? privilegeLevel) {
    switch (privilegeLevel) {
      case PrivilegeLevel.noPrivilege:
        return 'Public or member with no privilege';
      case PrivilegeLevel.level1Privilege:
        return 'Privilege level 1';
      case PrivilegeLevel.level2Privilege:
        return 'Privilege level 2';
      case PrivilegeLevel.ownerPrivilege:
        return 'Owner';
      case PrivilegeLevel.unknown:
        break;
      case null:
        break;
    }
    return '?';
  }

  void setSelectionPriv(int? val) {
    setState(() {
      _privSelectedRadioTile = val;
    });
  }

  Widget getPrivilegeOption(PrivilegeLevel? privilegeLevel) {
    if (privilegeLevel == null) return Text("?");
    var stringValue = privStringValue(privilegeLevel);
    return Center(
        child: radioListTile(
            widget.app,
            context,
            privilegeLevel.index,
            _privSelectedRadioTile,
            stringValue,
            null,
            (dynamic val) => setSelectionPriv(val)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      HeaderWidget(
        app: widget.app,
        cancelAction: () async {
          return true;
        },
        title: 'Simulate member privilege',
      ),
      topicContainer(widget.app, context,
          title: 'Current or simulated privilege',
          collapsible: true,
          collapsed: true,
          children: [
            text(widget.app, context, appLevel),
            text(widget.app, context, appBlocked),
          ]),
      topicContainer(widget.app, context,
          title: 'Simulate privilege',
          collapsible: true,
          collapsed: true,
          children: [
            checkboxListTile(widget.app, context, 'Blocked', isBlocked,
                (value) {
              setState(() {
                if (value != null) {
                  isBlocked = value;
                } else {
                  isBlocked = false;
                }
              });
            }),
            getPrivilegeOption(PrivilegeLevel.noPrivilege),
            getPrivilegeOption(PrivilegeLevel.level1Privilege),
            getPrivilegeOption(PrivilegeLevel.level2Privilege),
            getPrivilegeOption(PrivilegeLevel.ownerPrivilege),
            Center(
                child: button(widget.app, context, label: 'Simulate',
                    onPressed: () {
              BlocProvider.of<AccessBloc>(context).add(PrivilegeChangedEvent(
                  widget.app,
                  toPrivilegeLevel(_privSelectedRadioTile),
                  isBlocked));
            }))
          ]),
    ], shrinkWrap: true, physics: ScrollPhysics());
  }
}
