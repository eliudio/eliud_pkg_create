import 'package:bloc/bloc.dart';
import 'package:eliud_core/core/components/page_constructors/eliud_drawer.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/background_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'drawer_event.dart';
import 'drawer_state.dart';

class DrawerCreateBloc extends Bloc<DrawerCreateEvent, DrawerCreateState> {
  final DrawerModel drawerModel;
  final String appId;
  final DrawerType drawerType;

  DrawerCreateBloc(
    this.appId,
    this.drawerType,
    DrawerModel initialiseWithDrawerModel,
  )   : drawerModel = deepCopy(appId, drawerType, initialiseWithDrawerModel),
        super(DrawerCreateUninitialised()) {
    on<DrawerCreateEventValidateEvent>((event, emit) {
      // the updates happen on a (deep) copy
      emit(DrawerCreateValidated(
          deepCopy(appId, drawerType, event.drawerModel)));
    });

    on<DrawerCreateEventApplyChanges>((event, emit) async {
      var theState = state as DrawerCreateInitialised;
      drawerModel.menu = theState.drawerModel.menu;
      drawerModel.headerText = theState.drawerModel.headerText;
      drawerModel.headerBackgroundOverride =
          theState.drawerModel.headerBackgroundOverride;
      drawerModel.secondHeaderText = theState.drawerModel.secondHeaderText;
      if (event.save) {
        var drawer = await drawerRepository(appId: drawerModel.appId)!
            .get(theState.drawerModel.documentID);
        if (drawer == null) {
          await drawerRepository(appId: drawerModel.appId)!
              .add(theState.drawerModel);
        } else {
          await drawerRepository(appId: drawerModel.appId)!
              .update(theState.drawerModel);
        }

        var menuDef = await menuDefRepository(appId: drawerModel.appId)!
            .get(theState.drawerModel.menu!.documentID);
        if (menuDef == null) {
          await menuDefRepository(appId: drawerModel.appId)!
              .add(theState.drawerModel.menu!);
        } else {
          await menuDefRepository(appId: drawerModel.appId)!
              .update(theState.drawerModel.menu!);
        }
      }
    });
  }

  static DrawerModel deepCopy(
      String appID, DrawerType drawerType, DrawerModel from) {
    var documentID = drawerID(appID, drawerType);
    var iconMenu = copyOrDefault(appID, documentID, from.menu);
    var copyOfDrawerModel = from.copyWith(
        documentID: documentID, menu: iconMenu, headerText: from.headerText);
    return copyOfDrawerModel;
  }
}
