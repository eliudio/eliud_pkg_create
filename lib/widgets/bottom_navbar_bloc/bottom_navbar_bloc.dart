import 'package:bloc/bloc.dart';
import 'package:eliud_core/core/components/page_constructors/eliud_appbar.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:eliud_pkg_etc/widgets/decorator/can_refresh.dart';

import 'bottom_navbar_event.dart';
import 'bottom_navbar_state.dart';

class BottomNavBarCreateBloc extends Bloc<BottomNavBarCreateEvent, BottomNavBarCreateState> {
  final HomeMenuModel originalBottomNavBarModel;
  final HomeMenuModel bottomNavModelCurrentApp;
  final String appId;
  final CanRefresh? canRefresh;

  BottomNavBarCreateBloc(this.appId, this.bottomNavModelCurrentApp, this.canRefresh)
      : originalBottomNavBarModel = deepCopy(appId, bottomNavModelCurrentApp), super(BottomNavBarCreateUninitialised());

  @override
  Stream<BottomNavBarCreateState> mapEventToState(BottomNavBarCreateEvent event) async* {
    if (event is BottomNavBarCreateEventValidateEvent) {
      // the updates happen on a (deep) copy
      yield BottomNavBarCreateValidated(deepCopy(appId, event.homeMenuModel));
    } else if (state is BottomNavBarCreateInitialised) {
      var theState = state as BottomNavBarCreateInitialised;
      if (event is BottomNavBarCreateEventApplyChanges) {
        bottomNavModelCurrentApp.menu = theState.homeMenuModel.menu;
        if (event.save) {
          var homeMenu = await homeMenuRepository(appId: bottomNavModelCurrentApp.appId)!
              .get(theState.homeMenuModel.documentID);
          if (homeMenu == null) {
            await homeMenuRepository(appId: bottomNavModelCurrentApp.appId)!
                .add(theState.homeMenuModel);
          } else {
            await homeMenuRepository(appId: bottomNavModelCurrentApp.appId)!
                .update(theState.homeMenuModel);
          }

          var menuDef = await menuDefRepository(appId: bottomNavModelCurrentApp.appId)!
              .get(theState.homeMenuModel.menu!.documentID);
          if (menuDef == null) {
            await menuDefRepository(appId: bottomNavModelCurrentApp.appId)!
                .add(theState.homeMenuModel.menu!);
          } else {
            await menuDefRepository(appId: bottomNavModelCurrentApp.appId)!
                .update(theState.homeMenuModel.menu!);
          }
        }
        if (canRefresh != null) {
          canRefresh!.refresh();
        }
      } else if (event is BottomNavBarCreateEventRevertChanges) {
        // we could just refresh the app, give we haven't saved anything. However, more efficient is :
        bottomNavModelCurrentApp.menu = originalBottomNavBarModel.menu;
        if (canRefresh != null) {
          canRefresh!.refresh();
        }
      }
    }
  }
  
  static HomeMenuModel deepCopy(String appID, HomeMenuModel from) {
    var documentID = homeMenuID(appID);
    var iconMenu = copyOrDefault(documentID, from.menu);
    var copyOfBottomNavBarModel = from.copyWith(documentID: documentID, menu: iconMenu);
    return copyOfBottomNavBarModel;
  }
}
