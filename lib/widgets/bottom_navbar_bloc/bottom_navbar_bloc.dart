import 'package:bloc/bloc.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';

import 'bottom_navbar_event.dart';
import 'bottom_navbar_state.dart';

class BottomNavBarCreateBloc
    extends Bloc<BottomNavBarCreateEvent, BottomNavBarCreateState> {
  final HomeMenuModel bottomNavModel;
  final String appId;

  BottomNavBarCreateBloc(
    this.appId,
    HomeMenuModel initialiseWithBottomNav,
  )   : bottomNavModel = deepCopy(appId, initialiseWithBottomNav),
        super(BottomNavBarCreateUninitialised()) {
    on<BottomNavBarCreateEventValidateEvent>((event, emit) {
      // the updates happen on a (deep) copy
      emit(BottomNavBarCreateValidated(deepCopy(appId, event.homeMenuModel)));
    });

    on<BottomNavBarCreateEventApplyChanges>((event, emit) async {
      var theState = state as BottomNavBarCreateInitialised;
      bottomNavModel.menu = theState.homeMenuModel.menu;
      if (event.save) {
        var homeMenu = await homeMenuRepository(appId: bottomNavModel.appId)!
            .get(theState.homeMenuModel.documentID);
        if (homeMenu == null) {
          await homeMenuRepository(appId: bottomNavModel.appId)!
              .add(theState.homeMenuModel);
        } else {
          await homeMenuRepository(appId: bottomNavModel.appId)!
              .update(theState.homeMenuModel);
        }

        var menuDef = await menuDefRepository(appId: bottomNavModel.appId)!
            .get(theState.homeMenuModel.menu!.documentID);
        if (menuDef == null) {
          await menuDefRepository(appId: bottomNavModel.appId)!
              .add(theState.homeMenuModel.menu!);
        } else {
          await menuDefRepository(appId: bottomNavModel.appId)!
              .update(theState.homeMenuModel.menu!);
        }
      }
    });
  }

  static HomeMenuModel deepCopy(String appID, HomeMenuModel from) {
    var documentID = homeMenuID(appID);
    var iconMenu = copyOrDefault(appID, documentID, from.menu);
    var copyOfBottomNavBarModel =
        from.copyWith(documentID: documentID, menu: iconMenu);
    return copyOfBottomNavBarModel;
  }
}
