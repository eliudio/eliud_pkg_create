import 'package:eliud_core/core/blocs/access/access_event.dart';
import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_pkg_create/widgets/page_bloc/page_event.dart';
import 'package:eliud_pkg_create/widgets/page_bloc/page_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/storage_conditions_model.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';

class PageCreateBloc extends Bloc<PageCreateEvent, PageCreateState> {
  final AppModel app;
  final AccessBloc accessBloc;

  PageCreateBloc(this.app, this.accessBloc) : super(PageCreateUninitialised()) {
    on<PageCreateEventValidateEvent>((event, emit) async {
      var appId = app.documentID;
      // convention is that the ID of the appBar, drawers and home menu are the same ID as that of the app
      var homeMenuId = homeMenuID(appId);
      if (event.pageModel.homeMenu == null) {
        // if no home menu specified, then get one and assign
        event.pageModel.homeMenu = await homeMenu(appId);
      } else {
        // if home menu is specified, make sure the ID is in line with the convention (of the ID)
        if (event.pageModel.homeMenu!.documentID != homeMenuId) {
          event.pageModel.homeMenu =
              event.pageModel.homeMenu!.copyWith(documentID: homeMenuId);
        }
      }

      var appBarId = appBarID(appId);
      if (event.pageModel.appBar == null) {
        event.pageModel.appBar = await appBar(appId);
      } else {
        // if appBar is specified, make sure the ID is in line with the convention (of the ID)
        if (event.pageModel.appBar!.documentID != appBarId) {
          event.pageModel.appBar =
              event.pageModel.appBar!.copyWith(documentID: appBarId);
        }
      }

      var leftDrawerId = drawerID(appId, DrawerType.left);
      if (event.pageModel.drawer == null) {
        event.pageModel.drawer = await getDrawer(appId, DrawerType.left);
      } else {
        // if left drawer is specified, make sure the ID is in line with the convention (of the ID)
        if (event.pageModel.drawer!.documentID != leftDrawerId) {
          event.pageModel.drawer =
              event.pageModel.drawer!.copyWith(documentID: leftDrawerId);
        }
      }

      var rightDrawerId = drawerID(appId, DrawerType.right);
      if (event.pageModel.endDrawer == null) {
        event.pageModel.endDrawer = await getDrawer(appId, DrawerType.right);
      } else {
        // if right drawer is specified, make sure the ID is in line with the convention (of the ID)
        if (event.pageModel.endDrawer!.documentID != rightDrawerId) {
          event.pageModel.endDrawer =
              event.pageModel.endDrawer!.copyWith(documentID: rightDrawerId);
        }
      }

      event.pageModel.conditions ??= StorageConditionsModel(
        privilegeLevelRequired:
            PrivilegeLevelRequiredSimple.noPrivilegeRequiredSimple,
      );
      // the updates happen on a (deep) copy
      emit(PageCreateValidated(deepCopy(event.pageModel)));
    });

    on<PageCreateEventApplyChanges>((event, emit) async {
      var theState = state as PageCreateInitialised;
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
        accessBloc.add(GotoPageEvent(
          app,
          theState.pageModel.documentID,
        ));
      } else {
        await pageRepository(appId: theState.pageModel.appId)!
            .update(theState.pageModel);
      }
    });
  }

  static PageModel deepCopy(PageModel from) {
    var copyOfPageModel = from.copyWith();
    return copyOfPageModel;
  }
}
