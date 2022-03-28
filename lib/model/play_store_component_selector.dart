/*
       _ _           _ 
      | (_)         | |
   ___| |_ _   _  __| |
  / _ \ | | | | |/ _` |
 |  __/ | | |_| | (_| |
  \___|_|_|\__,_|\__,_|
                       
 
 play_store_list.dart
                       
 This code is generated. This is read only. Don't touch!

*/

import 'dart:math';
import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_tabs.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/component/component_spec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/style/style_registry.dart';
import 'package:eliud_core/tools/query/query_tools.dart';
import 'package:eliud_core/tools/query/query_tools.dart';

import 'abstract_repository_singleton.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import 'play_store_list_bloc.dart';
import 'play_store_list_event.dart';
import 'play_store_list_state.dart';
import 'play_store_model.dart';

class PlayStoreComponentSelector extends ComponentSelector {
  @override
  Widget createSelectWidget(BuildContext context, AppModel app, int privilegeLevel, double height,
      SelectComponent selected, editorConstructor) {
    var appId = app.documentID!;
    return BlocProvider<PlayStoreListBloc>(
          create: (context) => PlayStoreListBloc(
          eliudQuery: getComponentSelectorQuery(0, app.documentID!),
          playStoreRepository:
              playStoreRepository(appId: appId)!,
          )..add(LoadPlayStoreList()),
      child: SelectPlayStoreWidget(app: app,
          height: height,
          containerPrivilege: privilegeLevel,
          selected: selected,
          editorConstructor: editorConstructor),
    );
  }
}

class SelectPlayStoreWidget extends StatefulWidget {
  final AppModel app;
  final double height;
  final SelectComponent selected;
  final int containerPrivilege;
  final ComponentEditorConstructor editorConstructor;

  const SelectPlayStoreWidget(
      {Key? key,
      required this.app,
      required this.containerPrivilege,
      required this.height,
      required this.selected,
      required this.editorConstructor})
      : super(key: key);

  @override
  _SelectPlayStoreWidgetState createState() {
    return _SelectPlayStoreWidgetState();
  }
}

class _SelectPlayStoreWidgetState extends State<SelectPlayStoreWidget> with TickerProviderStateMixin {
  TabController? _privilegeTabController;
  final List<String> _privilegeItems = ['No', 'L1', 'L2', 'Owner'];
  final int _initialPrivilege = 0;
  int _currentPrivilege = 0;

  @override
  void initState() {
    var _privilegeASize = _privilegeItems.length;
    _privilegeTabController =
        TabController(vsync: this, length: _privilegeASize);
    _privilegeTabController!.addListener(_handlePrivilegeTabSelection);
    _privilegeTabController!.index = _initialPrivilege;

    super.initState();
  }

  @override
  void dispose() {
    if (_privilegeTabController != null) {
      _privilegeTabController!.dispose();
    }
    super.dispose();
  }

  void _handlePrivilegeTabSelection() {
    if ((_privilegeTabController != null) &&
        (_privilegeTabController!.indexIsChanging)) {
        _currentPrivilege = _privilegeTabController!.index;
        BlocProvider.of<PlayStoreListBloc>(context).add(
            PlayStoreChangeQuery(newQuery: getComponentSelectorQuery(_currentPrivilege, widget.app.documentID!)));
    }
  }

  Widget theList(BuildContext context, List<PlayStoreModel?> values) {
    var app = widget.app; 
    return ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: values.length,
        itemBuilder: (context, index) {
          final value = values[index];
          if (value != null) {
            return getListTile(
              context,
              widget.app,
              trailing: PopupMenuButton<int>(
                  child: Icon(Icons.more_vert),
                  elevation: 10,
                  itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 1,
                          child: text(widget.app, context, 'Add to page'),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: text(widget.app, context, 'Update'),
                        ),
                      ],
                  onSelected: (selectedValue) {
                    if (selectedValue == 1) {
                      widget.selected(value.documentID!);
                    } else if (selectedValue == 2) {
                      widget.editorConstructor.updateComponent(widget.app, context, value, (_) {});
                    }
                  }),
              title: value.documentID != null ? Center(child: StyleRegistry.registry().styleWithApp(app).frontEndStyle().textStyle().text(app, context, value.documentID!)) : Container(),
              subtitle: value.description != null ? Center(child: StyleRegistry.registry().styleWithApp(app).frontEndStyle().textStyle().text(app, context, value.description!)) : Container(),
            );
          } else {
            return Container();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayStoreListBloc, PlayStoreListState>(
        builder: (context, state) {
      var children = <Widget>[];
      var newPrivilegeItems = <Widget>[];
      int i = 0;
      for (var privilegeItem in _privilegeItems) {
        newPrivilegeItems.add(Wrap(children: [(i <= widget.containerPrivilege) ? Icon(Icons.check) : Icon(Icons.close), Container(width: 2), text(widget.app, context, privilegeItem)]));
        i++;
      }
      children.add(tabBar2(widget.app, context,
          items: newPrivilegeItems, tabController: _privilegeTabController!));
      if ((state is PlayStoreListLoaded) && (state.values != null)) {
        children.add(Container(
            height: max(30, widget.height - 101),
            child: theList(
              context,
              state.values!,
            )));
      } else {
        children.add(Container(
            height: max(30, widget.height - 101),
            ));
      }
      children.add(Column(children: [
        divider(widget.app, context),
        Center(
            child: iconButton(widget.app, 
          context,
          onPressed: () {
            widget.editorConstructor.createNewComponent(widget.app, context, (_) {});
          },
          icon: Icon(Icons.add),
        ))
      ]));
      return ListView(
          physics: ScrollPhysics(), shrinkWrap: true, children: children);
    });
  }
}



