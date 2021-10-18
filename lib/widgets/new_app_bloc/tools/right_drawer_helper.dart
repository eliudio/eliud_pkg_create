
import 'package:eliud_core/core_package.dart';
import 'package:eliud_core/extensions/member_dashboard_component.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/background_model.dart';
import 'package:eliud_core/model/conditions_model.dart';
import 'package:eliud_core/model/decoration_color_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/icon_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/platform_medium_model.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_core/style/tools/colors.dart';
import 'package:eliud_core/tools/action/action_model.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:flutter/material.dart';

class RightDrawerHelper {
  final String appId;
  final String drawerId;
  final DialogModel? memberDashboard;

  RightDrawerHelper(this.appId, {this.memberDashboard}): drawerId = drawerID(appId, DrawerType.Right);

  Future<DrawerModel> create() async {
    var drawerModel = DrawerModel(
        documentID: drawerId,
        appId: appId,
        name: 'Profile Drawer',
        headerText: '',
        secondHeaderText: 'name: \${userName}\ngroup: \${userGroup}',
        headerHeight: 0,
        popupMenuBackgroundColor: EliudColors.red,
        menu: await _drawerMenuDef());

    await drawerRepository(appId: appId)!.add(drawerModel);
    return drawerModel;
  }

  Future<MenuDefModel> _drawerMenuDef() async {
    List<MenuItemModel> menuItems = [];
    menuItems.add(menuItemSignOut(appId, "sign_out"));
    menuItems.add(menuItemFlushCache(appId, "flush_cash"));
    if (memberDashboard != null) {
      menuItems
          .add(menuItemManageAccount(appId, "4", memberDashboard!.documentID!));
    }

    MenuDefModel menu = MenuDefModel(
        documentID: "drawer_profile_menu",
        appId: appId,
        name: "Drawer Profile Menu",
        menuItems: menuItems);
    return menu;
  }
}

menuItemSignOut(appID, documentID) => MenuItemModel(
    documentID: documentID,
    text: "Sign out",
    description: "Sign out",
    icon: IconModel(
        codePoint: Icons.power_settings_new.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action:
    InternalAction(appID, internalActionEnum: InternalActionEnum.Logout));

menuItemFlushCache(appID, documentID) => MenuItemModel(
    documentID: documentID,
    text: "Flush cache",
    description: "Flush cache",
    icon: IconModel(
        codePoint: Icons.power_settings_new.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action:
    InternalAction(appID, internalActionEnum: InternalActionEnum.Flush));

menuItemManageAccount(String appID, String documentID, String dialogID) => MenuItemModel(
    documentID: documentID,
    text: 'Manage your account',
    description: 'Manage your account',
    icon: IconModel(
        codePoint: Icons.account_box.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: OpenDialog(appID,
        dialogID: dialogID,
        conditions: ConditionsModel(
            privilegeLevelRequired: PrivilegeLevelRequired.NoPrivilegeRequired,
            packageCondition: CorePackage.MUST_BE_LOGGED_ON)));
