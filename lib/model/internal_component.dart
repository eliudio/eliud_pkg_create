/*
       _ _           _ 
      | (_)         | |
   ___| |_ _   _  __| |
  / _ \ | | | | |/ _` |
 |  __/ | | |_| | (_| |
  \___|_|_|\__,_|\__,_|
                       
 
 model/internal_component.dart
                       
 This code is generated. This is read only. Don't touch!

*/


import 'package:eliud_core/tools/component/component_constructor.dart';
import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:eliud_core/tools/has_fab.dart';


import 'package:eliud_pkg_create/model/play_store_list_bloc.dart';
import 'package:eliud_pkg_create/model/play_store_list.dart';
import 'package:eliud_pkg_create/model/play_store_dropdown_button.dart';
import 'package:eliud_pkg_create/model/play_store_list_event.dart';

import 'package:eliud_core/model/repository_export.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import 'package:eliud_pkg_create/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_create/model/repository_export.dart';
import 'package:eliud_core/model/model_export.dart';
import '../tools/bespoke_models.dart';
import 'package:eliud_pkg_create/model/model_export.dart';
import 'package:eliud_core/model/entity_export.dart';
import '../tools/bespoke_entities.dart';
import 'package:eliud_pkg_create/model/entity_export.dart';

class ListComponentFactory implements ComponentConstructor {
  Widget? createNew({Key? key, required String id, Map<String, dynamic>? parameters}) {
    return ListComponent(componentId: id);
  }

  @override
  dynamic getModel({required String appId, required String id}) {
    return null;
  }
}


typedef DropdownButtonChanged(String? value);

class DropdownButtonComponentFactory implements ComponentDropDown {
  @override
  dynamic getModel({required String appId, required String id}) {
    return null;
  }


  bool supports(String id) {

    if (id == "playStores") return true;
    return false;
  }

  Widget createNew({Key? key, required String id, Map<String, dynamic>? parameters, String? value, DropdownButtonChanged? trigger, bool? optional}) {

    if (id == "playStores")
      return DropdownButtonComponent(componentId: id, value: value, trigger: trigger, optional: optional);

    return Text("Id $id not found");
  }
}


class ListComponent extends StatelessWidget with HasFab {
  final String? componentId;
  Widget? widget;

  @override
  Widget? fab(BuildContext context){
    if ((widget != null) && (widget is HasFab)) {
      HasFab hasFab = widget as HasFab;
      return hasFab.fab(context);
    }
    return null;
  }

  ListComponent({this.componentId}) {
    initWidget();
  }

  @override
  Widget build(BuildContext context) {

    if (componentId == 'playStores') return _playStoreBuild(context);
    return Text('Component with componentId == $componentId not found');
  }

  void initWidget() {
    if (componentId == 'playStores') widget = PlayStoreListWidget();
  }

  Widget _playStoreBuild(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PlayStoreListBloc>(
          create: (context) => PlayStoreListBloc(
            playStoreRepository: playStoreRepository(appId: AccessBloc.currentAppId(context))!,
          )..add(LoadPlayStoreList()),
        )
      ],
      child: widget!,
    );
  }

}


typedef Changed(String? value);

class DropdownButtonComponent extends StatelessWidget {
  final String? componentId;
  final String? value;
  final Changed? trigger;
  final bool? optional;

  DropdownButtonComponent({this.componentId, this.value, this.trigger, this.optional});

  @override
  Widget build(BuildContext context) {

    if (componentId == 'playStores') return _playStoreBuild(context);
    return Text('Component with componentId == $componentId not found');
  }


  Widget _playStoreBuild(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PlayStoreListBloc>(
          create: (context) => PlayStoreListBloc(
            playStoreRepository: playStoreRepository(appId: AccessBloc.currentAppId(context))!,
          )..add(LoadPlayStoreList()),
        )
      ],
      child: PlayStoreDropdownButtonWidget(value: value, trigger: trigger, optional: optional),
    );
  }

}


