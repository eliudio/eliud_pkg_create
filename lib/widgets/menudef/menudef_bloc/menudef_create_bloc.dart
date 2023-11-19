import 'package:bloc/bloc.dart';
import 'package:eliud_core_model/model/app_model.dart';
import 'package:eliud_core/model/icon_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/tools/action/action_model.dart';
import 'package:eliud_core_model/tools/etc/random.dart';
import 'package:eliud_pkg_workflow/tools/action/workflow_action_model.dart';
import 'package:flutter/material.dart';
import 'menudef_create_event.dart';
import 'menudef_create_state.dart';
import 'package:eliud_core/tools/helpers/list_swap.dart';
import 'package:eliud_core/tools/helpers/list_replace.dart';

class MenuDefCreateBloc extends Bloc<MenuDefCreateEvent, MenuDefCreateState> {
  final AppModel app;
  final MenuDefModel menu;

  MenuDefCreateBloc(
    this.app,
    this.menu,
  ) : super(MenuDefCreateUninitialised()) {
    on<MenuDefCreateInitialiseEvent>((event, emit) {
      //var appId = app.documentID;
      emit(MenuDefCreateInitialised(
        menuDefModel: event.menuDefModel,
      ));
    });

    on<MenuDefCreateDeleteMenuItem>((event, emit) {
      emit(_newStateDeleteItem(event.menuItemModel));
      apply();
    });

    on<MenuDefCreateAddLogin>((event, emit) {
      emit(_newStateWithNewItem(
        MenuItemModel(
            documentID: newRandomKey(),
            text: 'Sign in',
            description: 'Sign in',
            action: InternalAction(app,
                internalActionEnum: InternalActionEnum.login)),
      ));
      apply();
    });

    on<MenuDefCreateAddLogout>((event, emit) {
      emit(_newStateWithNewItem(
        MenuItemModel(
            documentID: newRandomKey(),
            text: 'Sign out',
            description: 'Sign out',
            action: InternalAction(app,
                internalActionEnum: InternalActionEnum.logout)),
      ));
      apply();
    });

    on<MenuDefCreateAddGoHome>((event, emit) {
      emit(_newStateWithNewItem(
        MenuItemModel(
            documentID: newRandomKey(),
            text: 'Go home',
            icon: IconModel(
                codePoint: Icons.home.codePoint,
                fontFamily: Icons.settings.fontFamily),
            description: 'Go home',
            action: InternalAction(app,
                internalActionEnum: InternalActionEnum.goHome)),
      ));
      apply();
    });

    on<MenuDefCreateAddOtherApps>((event, emit) {
      emit(_newStateWithNewItem(
        MenuItemModel(
            documentID: newRandomKey(),
            text: 'Other apps',
            description: 'Other apps',
            action: InternalAction(app,
                internalActionEnum: InternalActionEnum.otherApps)),
      ));
      apply();
    });

    on<MenuDefCreateAddMenuItemForPage>((event, emit) {
      emit(_newStateWithNewItem(
        MenuItemModel(
            documentID: newRandomKey(),
            text: 'New Page',
            description: 'New Page',
            icon: IconModel(
                codePoint: Icons.favorite_border.codePoint,
                fontFamily: Icons.settings.fontFamily),
            action: GotoPage(app, pageID: event.pageModel.documentID)),
      ));
      apply();
    });

    on<MenuDefCreateAddMenuItemForDialog>((event, emit) {
      emit(_newStateWithNewItem(
        MenuItemModel(
            documentID: newRandomKey(),
            text: 'New Dialog',
            description: 'New Dialog',
            icon: IconModel(
                codePoint: Icons.favorite_border.codePoint,
                fontFamily: Icons.settings.fontFamily),
            action: OpenDialog(app, dialogID: event.dialogModel.documentID)),
      ));
      apply();
    });

    on<MenuDefCreateAddMenuItemForWorkflow>((event, emit) {
      emit(_newStateWithNewItem(
        MenuItemModel(
            documentID: newRandomKey(),
            text: 'New Workflow',
            description: 'New Workflow',
            icon: IconModel(
                codePoint: Icons.favorite_border.codePoint,
                fontFamily: Icons.settings.fontFamily),
            action: WorkflowActionModel(app, workflow: event.workflowModel)),
      ));
      apply();
    });

    on<MenuDefMoveMenuItem>((event, emit) {
      MenuDefCreateInitialised theState = state as MenuDefCreateInitialised;
      List<MenuItemModel> menuItems = List.of(theState.menuDefModel.menuItems!);
      int positionToMove = menuItems.indexOf(event.menuItemModel);
      if (event.moveMenuItemDirection == MoveMenuItemDirection.up) {
        if (positionToMove > 0) {
          menuItems.swap(positionToMove - 1, positionToMove);
        }
      } else if (event.moveMenuItemDirection == MoveMenuItemDirection.down) {
        if (positionToMove < menuItems.length - 1) {
          menuItems.swap(positionToMove + 1, positionToMove);
        }
      }
      emit(_newStateWithItems(menuItems,
          currentlySelected: event.menuItemModel));
      apply();
    });

    on<MenuDefUpdateMenuItem>((event, emit) {
      MenuDefCreateInitialised theState = state as MenuDefCreateInitialised;
      List<MenuItemModel> menuItems = List.of(theState.menuDefModel.menuItems!);
      int positionToReplace = menuItems.indexOf(event.beforeMenuItemModel);
      menuItems.replace(positionToReplace, event.afterMenuItemModel);
      emit(_newStateWithItems(menuItems,
          currentlySelected: event.afterMenuItemModel));
      apply();
    });
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

/*
  MenuDefCreateInitialised _newStateDeleteItemFromIndex(int index) {
    var theState = state as MenuDefCreateInitialised;
    List<MenuItemModel> menuItems = List.of(theState.menuDefModel.menuItems!);
    menuItems.removeAt(index);
    return _newStateWithItems(menuItems);
  }

*/
  MenuDefCreateInitialised _newStateDeleteItem(MenuItemModel menuItemModel) {
    var theState = state as MenuDefCreateInitialised;
    List<MenuItemModel> menuItems = List.of(theState.menuDefModel.menuItems!);
    menuItems.remove(menuItemModel);
    return _newStateWithItems(menuItems);
  }
}
