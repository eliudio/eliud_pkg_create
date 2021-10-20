import 'package:bloc/bloc.dart';
import 'package:eliud_core/core/access/bloc/access_bloc.dart';
import 'package:eliud_core/core/access/bloc/access_state.dart';
import 'package:eliud_core/core/navigate/navigate_bloc.dart';
import 'package:eliud_core/core/navigate/router.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/icon_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/page_repository.dart';
import 'package:eliud_core/tools/action/action_model.dart';
import 'package:eliud_core/tools/etc.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_pkg_etc/widgets/decorator/can_refresh.dart';
import 'package:flutter/material.dart';
import 'menudef_create_event.dart';
import 'menudef_create_state.dart';
import 'package:eliud_core/tools/helpers/list_swap.dart';
import 'package:eliud_core/tools/helpers/list_replace.dart';

class MenuDefCreateBloc extends Bloc<MenuDefCreateEvent, MenuDefCreateState> {
  final AppModel app;
  final MenuDefModel menu;

  MenuDefCreateBloc(this.app, this.menu, )
      : super(MenuDefCreateUninitialised());

  @override
  Stream<MenuDefCreateState> mapEventToState(MenuDefCreateEvent event) async* {
    if (event is MenuDefCreateInitialiseEvent) {
      var appId = app.documentID;
      var pages = await pageRepository(appId: appId)!.valuesList();
      var dialogs = await dialogRepository(appId: appId)!.valuesList();
      yield MenuDefCreateInitialised(
          menuDefModel: event.menuDefModel, pages: pages, dialogs: dialogs);
    } else if (state is MenuDefCreateInitialised) {
      var appId = app.documentID;
      if (event is MenuDefRefreshPages) {
        MenuDefCreateInitialised theState = state as MenuDefCreateInitialised;
        var pages = await pageRepository(appId: app.documentID)!
            .valuesList();
        yield theState.copyWith(pages: pages);
      } else if (event is MenuDefRefreshDialogs) {
        MenuDefCreateInitialised theState = state as MenuDefCreateInitialised;
        var dialogs = await dialogRepository(appId: app.documentID)!
            .valuesList();
        yield theState.copyWith(dialogs: dialogs);
      } else if (event is MenuDefCreateDeleteMenuItem) {
        yield _newStateDeleteItem(event.menuItemModel);
        apply();
      } else if (event is MenuDefCreateAddLogin) {
        yield _newStateWithNewItem(
          MenuItemModel(
              documentID: newRandomKey(),
              text: 'Sign in',
              description: 'Sign in',
              action: InternalAction(appId!,
                  internalActionEnum: InternalActionEnum.Login)),
        );
        apply();
      } else if (event is MenuDefCreateAddLogout) {
        yield _newStateWithNewItem(
          MenuItemModel(
              documentID: newRandomKey(),
              text: 'Sign out',
              description: 'Sign out',
              action: InternalAction(appId!,
                  internalActionEnum: InternalActionEnum.Logout)),
        );
        apply();
      } else if (event is MenuDefCreateAddOtherApps) {
        yield _newStateWithNewItem(
          MenuItemModel(
              documentID: newRandomKey(),
              text: 'Other apps',
              description: 'Other apps',
              action: InternalAction(appId!,
                  internalActionEnum: InternalActionEnum.OtherApps)),
        );
        apply();
      } else if (event is MenuDefCreateAddMenuItemForPage) {
        yield _newStateWithNewItem(
          MenuItemModel(
              documentID: newRandomKey(),
              text: 'New Page',
              description: 'New Page',
              icon: IconModel(
                  codePoint: Icons.favorite_border.codePoint,
                  fontFamily: Icons.settings.fontFamily),
              action: GotoPage(appId!, pageID: event.pageModel.documentID!)),
        );
        apply();
      } else if (event is MenuDefCreateAddMenuItemForDialog) {
        yield _newStateWithNewItem(
          MenuItemModel(
              documentID: newRandomKey(),
              text: 'New Dialog',
              description: 'New Dialog',
              icon: IconModel(
                  codePoint: Icons.favorite_border.codePoint,
                  fontFamily: Icons.settings.fontFamily),
              action: OpenDialog(appId!, dialogID: event.dialogModel.documentID!)),
        );
        apply();
      } else if (event is MenuDefMoveMenuItem) {
        MenuDefCreateInitialised theState = state as MenuDefCreateInitialised;
        List<MenuItemModel> menuItems = List.of(theState.menuDefModel.menuItems!);
        int positionToMove = menuItems.indexOf(event.menuItemModel);
        if (event.moveMenuItemDirection == MoveMenuItemDirection.Up) {
          if (positionToMove > 0) {
            menuItems.swap(positionToMove - 1, positionToMove);
          }
        } else if (event.moveMenuItemDirection == MoveMenuItemDirection.Down) {
          if (positionToMove < menuItems.length - 1) {
            menuItems.swap(positionToMove + 1, positionToMove);
          }
        }
        yield _newStateWithItems(menuItems, currentlySelected: event.menuItemModel);
        apply();
      } else if (event is MenuDefUpdateMenuItem) {
        MenuDefCreateInitialised theState = state as MenuDefCreateInitialised;
        List<MenuItemModel> menuItems = List.of(theState.menuDefModel.menuItems!);
        int positionToReplace = menuItems.indexOf(event.beforeMenuItemModel);
        menuItems.replace(positionToReplace, event.afterMenuItemModel);
        yield _newStateWithItems(menuItems, currentlySelected: event.afterMenuItemModel);
        apply();
      }
    }
  }

  void apply() {
    MenuDefCreateInitialised theState = state as MenuDefCreateInitialised;
    menu.menuItems = theState.menuDefModel.menuItems;
  }

  MenuDefCreateInitialised _newStateWithItems(List<MenuItemModel> menuItems,
      {MenuItemModel? currentlySelected}) {
    var theState = state as MenuDefCreateInitialised;
    var newMenuDefModel = theState.menuDefModel.copyWith(menuItems: menuItems);
    var newState = theState.copyWith(
        menuDefModel: newMenuDefModel, currentlySelected: currentlySelected);
    return newState;
  }

  MenuDefCreateInitialised _newStateWithNewItem(MenuItemModel newItem) {
    var theState = state as MenuDefCreateInitialised;
    List<MenuItemModel> menuItems = List.of(theState.menuDefModel.menuItems!);
    menuItems.add(newItem);
    return _newStateWithItems(menuItems, currentlySelected: newItem);
  }

  MenuDefCreateInitialised _newStateDeleteItemFromIndex(int index) {
    var theState = state as MenuDefCreateInitialised;
    List<MenuItemModel> menuItems = List.of(theState.menuDefModel.menuItems!);
    menuItems.removeAt(index);
    return _newStateWithItems(menuItems);
  }

  MenuDefCreateInitialised _newStateDeleteItem(MenuItemModel menuItemModel) {
    var theState = state as MenuDefCreateInitialised;
    List<MenuItemModel> menuItems = List.of(theState.menuDefModel.menuItems!);
    menuItems.remove(menuItemModel);
    return _newStateWithItems(menuItems);
  }
}
