import 'package:eliud_core/core_package.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/display_conditions_model.dart';
import 'package:eliud_core/model/icon_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/tools/action/action_model.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_pkg_membership/membership_package.dart';
import 'package:eliud_pkg_workflow/model/workflow_model.dart';
import 'package:eliud_pkg_workflow/tools/action/workflow_action_model.dart';
import 'package:flutter/material.dart';

menuItemSignOut(AppModel app, ) => MenuItemModel(
    documentID: newRandomKey(),
    text: "Sign out",
    description: "Sign out",
    icon: IconModel(
        codePoint: Icons.power_settings_new.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action:
        InternalAction(app, internalActionEnum: InternalActionEnum.Logout));

menuItemSignIn(AppModel app, ) => MenuItemModel(
    documentID: newRandomKey(),
    text: "Sign in",
    description: "Sign in",
    action:
    InternalAction(app, internalActionEnum: InternalActionEnum.Login));

menuItemHome(AppModel app, pageID) => MenuItemModel(
    documentID: pageID,
    text: "Home",
    description: "Home",
    icon: IconModel(
        codePoint: Icons.home.codePoint, fontFamily: Icons.settings.fontFamily),
    action: GotoPage(app, pageID: pageID));

menuItemAbout(AppModel app, pageID, text) => MenuItemModel(
    documentID: pageID,
    text: text,
    description: text,
    icon: IconModel(
        codePoint: Icons.info.codePoint, fontFamily: Icons.settings.fontFamily),
    action: GotoPage(app, pageID: pageID));

menuItemShop(AppModel app, pageID, text) => MenuItemModel(
    documentID: pageID,
    text: text,
    description: text,
    icon: IconModel(
        codePoint: Icons.shop.codePoint, fontFamily: Icons.settings.fontFamily),
    action: GotoPage(app, pageID: pageID));

menuItemShoppingBag(AppModel app, pageID, text) => MenuItemModel(
    documentID: pageID,
    text: text,
    description: text,
    icon: IconModel(
        codePoint: Icons.shopping_basket.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: GotoPage(app, pageID: pageID));

menuItemShoppingCart(AppModel app, pageID, text) => MenuItemModel(
    documentID: pageID,
    text: text,
    description: text,
    icon: IconModel(
        codePoint: Icons.shopping_cart.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: GotoPage(app, pageID: pageID));

menuItemFollowRequests(AppModel app, dialogID) => MenuItemModel(
    documentID: dialogID,
    text: 'Follow requests',
    description: 'Follow requests',
    icon: IconModel(
        codePoint: Icons.favorite_border.codePoint,
        fontFamily: Icons.notifications.fontFamily),
    action: OpenDialog(
      app,
      dialogID: dialogID,
    ));

menuItemAppMembers(AppModel app, dialogID, privilegeLevelRequired) => MenuItemModel(
    documentID: dialogID,
    text: 'App Members',
    description: 'Members of the app',
    icon: IconModel(
        codePoint: Icons.people.codePoint,
        fontFamily: Icons.notifications.fontFamily),
    action: OpenDialog(
      app,
      conditions: DisplayConditionsModel(
          privilegeLevelRequired: privilegeLevelRequired,
          packageCondition: CorePackage.MUST_BE_LOGGED_ON),
      dialogID: dialogID,
    ));

menuItemJoin(AppModel app, WorkflowModel workflowModel) => MenuItemModel(
    documentID: "join",
    text: "JOIN",
    description: "Request membership",
    icon: null,
    action: WorkflowActionModel(app,
        conditions: DisplayConditionsModel(
          privilegeLevelRequired: PrivilegeLevelRequired.NoPrivilegeRequired,
          packageCondition: MembershipPackage.MEMBER_HAS_NO_MEMBERSHIP_YET,
        ),
        workflow: workflowModel));
