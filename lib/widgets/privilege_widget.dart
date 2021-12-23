import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/blocs/access/access_event.dart';
import 'package:eliud_core/core/blocs/access/state/access_state.dart';
import 'package:eliud_core/core/blocs/access/state/logged_in.dart';
import 'package:eliud_core/model/access_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/style/style_registry.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/*
 * Allows to change the privilege
 */
class PrivilegeWidget extends StatefulWidget {
  final AccessState currentAccess;
  final AppModel app;
  PrivilegeWidget({Key? key, required this.app, required this.currentAccess})
      : super(key: key);

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

  void initState() {
    super.initState();
    if (widget.currentAccess is LoggedIn) {
      var theAccess = widget.currentAccess as LoggedIn;
      isBlocked = theAccess.isBlocked(widget.app.documentID!);
      currentLevel = theAccess.getPrivilegeLevel(widget.app.documentID!);
      appLevel = 'Current level: ' + privStringValue(currentLevel);
      appBlocked = 'Blocked: ' + (isBlocked ? 'yes' : 'no');
    } else {
      appLevel = '?';
      currentLevel = PrivilegeLevel.Unknown;
    }
    _privSelectedRadioTile = currentLevel != null ? currentLevel!.index : 0;
  }

  String privStringValue(PrivilegeLevel? privilegeLevel) {
    switch (privilegeLevel) {
      case PrivilegeLevel.NoPrivilege:
        return 'Public or member with no privilege';
      case PrivilegeLevel.Level1Privilege:
        return 'Privilege level 1';
      case PrivilegeLevel.Level2Privilege:
        return 'Privilege level 2';
      case PrivilegeLevel.OwnerPrivilege:
        return 'Owner';
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
        cancelAction: () async {
          return true;
        },
        title: 'Simulate member privilege',
      ),
      topicContainer(context,
          title: 'Current or simulated privilege',
          collapsible: true,
          collapsed: true,
          children: [
            text(context, appLevel),
            text(context, appBlocked),
          ]),
      topicContainer(context,
          title: 'Simulate privilege',
          collapsible: true,
          collapsed: true,
          children: [
            checkboxListTile(context, 'Blocked', isBlocked, (value) {
              setState(() {
                if (value != null) {
                  isBlocked = value;
                } else {
                  isBlocked = false;
                }
              });
            }),
            getPrivilegeOption(PrivilegeLevel.NoPrivilege),
            getPrivilegeOption(PrivilegeLevel.Level1Privilege),
            getPrivilegeOption(PrivilegeLevel.Level2Privilege),
            getPrivilegeOption(PrivilegeLevel.OwnerPrivilege),
            Center(
                child: button(context, label: 'Simulate', onPressed: () {
              BlocProvider.of<AccessBloc>(context).add(PrivilegeChangedEvent(
                  widget.app,
                  toPrivilegeLevel(_privSelectedRadioTile),
                  isBlocked));
            }))
          ]),
    ], shrinkWrap: true, physics: ScrollPhysics());
  }
}
