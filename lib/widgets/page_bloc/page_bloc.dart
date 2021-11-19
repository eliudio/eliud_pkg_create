import 'package:bloc/bloc.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/background_model.dart';
import 'package:eliud_core/model/conditions_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:flutter/material.dart';
import 'page_event.dart';
import 'page_state.dart';

class PageCreateBloc extends Bloc<PageCreateEvent, PageCreateState> {
  final String appId;
  final VoidCallback? callOnAction;

  PageCreateBloc(this.appId, PageModel initialiseWithPage, this.callOnAction)
      : super(PageCreateUninitialised());

  @override
  Stream<PageCreateState> mapEventToState(PageCreateEvent event) async* {
    if (event is PageCreateEventValidateEvent) {
      // convention is that the ID of the appBar, drawers and home menu are the same ID as that of the app
      var _homeMenuId = homeMenuID(appId);
      if (event.pageModel.homeMenu == null) {
        // if no home menu specified, then get one and assign
        event.pageModel.homeMenu = await homeMenu(appId);
      } else {
        // if home menu is specified, make sure the ID is in line with the convention (of the ID)
        if (event.pageModel.homeMenu!.documentID != _homeMenuId) {
          event.pageModel.homeMenu =
              event.pageModel.homeMenu!.copyWith(documentID: _homeMenuId);
        }
      }

      var _appBarId = appBarID(appId);
      if (event.pageModel.appBar == null) {
        event.pageModel.appBar = await appBar(appId);
      } else {
        // if appBar is specified, make sure the ID is in line with the convention (of the ID)
        if (event.pageModel.appBar!.documentID != _appBarId) {
          event.pageModel.appBar =
              event.pageModel.appBar!.copyWith(documentID: _appBarId);
        }
      }

      var _leftDrawerId = drawerID(appId, DrawerType.Left);
      if (event.pageModel.drawer == null) {
        event.pageModel.drawer =
            await getDrawer(appId, DrawerType.Left);
      } else {
        // if left drawer is specified, make sure the ID is in line with the convention (of the ID)
        if (event.pageModel.drawer!.documentID != _leftDrawerId) {
          event.pageModel.drawer =
              event.pageModel.drawer!.copyWith(documentID: _leftDrawerId);
        }
      }

      var _rightDrawerId = drawerID(appId, DrawerType.Right);
      if (event.pageModel.endDrawer == null) {
        event.pageModel.endDrawer =
            await getDrawer(appId, DrawerType.Right);
      } else {
        // if right drawer is specified, make sure the ID is in line with the convention (of the ID)
        if (event.pageModel.endDrawer!.documentID != _rightDrawerId) {
          event.pageModel.endDrawer =
              event.pageModel.endDrawer!.copyWith(documentID: _rightDrawerId);
        }
      }

      event.pageModel.conditions ??= ConditionsModel(
            privilegeLevelRequired: PrivilegeLevelRequired.NoPrivilegeRequired,
            packageCondition: '',
            conditionOverride: null);
      // the updates happen on a (deep) copy
      yield PageCreateValidated(deepCopy(event.pageModel));
    } else if (state is PageCreateInitialised) {
      var theState = state as PageCreateInitialised;
      if (event is PageCreateEventApplyChanges) {
        if (event.save) {
          var homeMenu =
              await homeMenuRepository(appId: theState.pageModel.appId)!
                  .get(theState.pageModel.homeMenu!.documentID);
          if (homeMenu == null) {
            await homeMenuRepository(appId: theState.pageModel.appId)!
                .add(theState.pageModel.homeMenu!);
          } else {
            await homeMenuRepository(appId: theState.pageModel.appId)!
                .update(theState.pageModel.homeMenu!);
          }

          var appBar = await appBarRepository(appId: theState.pageModel.appId)!
              .get(theState.pageModel.appBar!.documentID);
          if (appBar == null) {
            await appBarRepository(appId: theState.pageModel.appId)!
                .add(theState.pageModel.appBar!);
          } else {
            await appBarRepository(appId: theState.pageModel.appId)!
                .update(theState.pageModel.appBar!);
          }
        }

        var drawer = await appBarRepository(appId: theState.pageModel.appId)!
            .get(theState.pageModel.drawer!.documentID);
        if (drawer == null) {
          await drawerRepository(appId: theState.pageModel.appId)!
              .add(theState.pageModel.drawer!);
        } else {
          await drawerRepository(appId: theState.pageModel.appId)!
              .update(theState.pageModel.drawer!);
        }

        var endDrawer = await appBarRepository(appId: theState.pageModel.appId)!
            .get(theState.pageModel.endDrawer!.documentID);
        if (endDrawer == null) {
          await drawerRepository(appId: theState.pageModel.appId)!
              .add(theState.pageModel.endDrawer!);
        } else {
          await drawerRepository(appId: theState.pageModel.appId)!
              .update(theState.pageModel.endDrawer!);
        }

        var page = await pageRepository(appId: theState.pageModel.appId)!
            .get(theState.pageModel.documentID);
        if (page == null) {
          await pageRepository(appId: theState.pageModel.appId)!
              .add(theState.pageModel);
        } else {
          await pageRepository(appId: theState.pageModel.appId)!
              .update(theState.pageModel);
        }

        if (callOnAction != null) {
          callOnAction!();
        }
      }
    }
  }

  static PageModel deepCopy(PageModel from) {
    var copyOfPageModel = from.copyWith();
    return copyOfPageModel;
  }
}
