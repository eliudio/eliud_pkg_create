import 'package:eliud_core/core_package.dart';
import 'package:eliud_core/model/display_conditions_model.dart';
import 'package:eliud_core/model/icon_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/tools/action/action_model.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_pkg_follow/follow_package.dart';
import 'package:eliud_pkg_membership/membership_package.dart';
import 'package:eliud_pkg_workflow/model/workflow_model.dart';
import 'package:eliud_pkg_workflow/tools/action/workflow_action_model.dart';
import 'package:flutter/material.dart';

menuItem(appID, pageID, text, IconData iconData) => MenuItemModel(
    documentID: pageID,
    text: text,
    description: text,
    icon: IconModel(
        codePoint: iconData.codePoint, fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID, pageID: pageID));

menuItemSignOut(appID) => MenuItemModel(
    documentID: newRandomKey(),
    text: "Sign out",
    description: "Sign out",
    icon: IconModel(
        codePoint: Icons.power_settings_new.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action:
        InternalAction(appID, internalActionEnum: InternalActionEnum.Logout));

menuItemSignIn(appID) => MenuItemModel(
    documentID: newRandomKey(),
    text: "Sign in",
    description: "Sign in",
    action:
    InternalAction(appID, internalActionEnum: InternalActionEnum.Login));

menuItemManageAccount(appID, dialogID) => MenuItemModel(
    documentID: dialogID,
    text: 'Manage your account',
    description: 'Manage your account',
    icon: IconModel(
        codePoint: Icons.account_box.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: OpenDialog(appID,
        dialogID: dialogID,
        conditions: DisplayConditionsModel(
            privilegeLevelRequired: PrivilegeLevelRequired.NoPrivilegeRequired,
            packageCondition: CorePackage.MUST_BE_LOGGED_ON)));

menuItemHome(appID, pageID) => MenuItemModel(
    documentID: pageID,
    text: "Home",
    description: "Home",
    icon: IconModel(
        codePoint: Icons.home.codePoint, fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID, pageID: pageID));

menuItemAbout(appID, pageID, text) => MenuItemModel(
    documentID: pageID,
    text: text,
    description: text,
    icon: IconModel(
        codePoint: Icons.info.codePoint, fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID, pageID: pageID));

menuItemFeed(appID, pageID, text) => MenuItemModel(
    documentID: pageID,
    text: text,
    description: text,
    icon: IconModel(
        codePoint: Icons.group.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID, pageID: pageID));

menuItemWelcome(appID, pageID, text) => MenuItemModel(
    documentID: pageID,
    text: text,
    description: text,
    icon: IconModel(
        codePoint: Icons.emoji_people.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID, pageID: pageID));

menuItemShop(appID, pageID, text) => MenuItemModel(
    documentID: pageID,
    text: text,
    description: text,
    icon: IconModel(
        codePoint: Icons.shop.codePoint, fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID, pageID: pageID));

menuItemShoppingBag(appID, pageID, text) => MenuItemModel(
    documentID: pageID,
    text: text,
    description: text,
    icon: IconModel(
        codePoint: Icons.shopping_basket.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID, pageID: pageID));

menuItemShoppingCart(appID, pageID, text) => MenuItemModel(
    documentID: pageID,
    text: text,
    description: text,
    icon: IconModel(
        codePoint: Icons.shopping_cart.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID, pageID: pageID));

menuItemFollowRequests(appID, dialogID) => MenuItemModel(
    documentID: dialogID,
    text: 'Follow requests',
    description: 'Follow requests',
    icon: IconModel(
        codePoint: Icons.favorite_border.codePoint,
        fontFamily: Icons.notifications.fontFamily),
    action: OpenDialog(
      appID,
      dialogID: dialogID,
    ));

menuItemFollowRequestsPage(appID, pageID, privilegeLevelRequired) =>
    MenuItemModel(
        documentID: pageID,
        text: 'Follow Requests',
        description: 'Follow Requests',
        icon: IconModel(
            codePoint: Icons.person.codePoint,
            fontFamily: Icons.notifications.fontFamily),
        action: GotoPage(appID,
            pageID: pageID,
            conditions: DisplayConditionsModel(
                privilegeLevelRequired: privilegeLevelRequired,
                packageCondition:
                    FollowPackage.CONDITION_MEMBER_HAS_OPEN_REQUESTS)));

menuItemFollowers(appID, dialogID, privilegeLevelRequired) => MenuItemModel(
    documentID: dialogID,
    text: 'Followers',
    description: 'Followers',
    icon: IconModel(
        codePoint: Icons.favorite_sharp.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: OpenDialog(appID,
        dialogID: dialogID,
        conditions: DisplayConditionsModel(
            privilegeLevelRequired: privilegeLevelRequired,
            packageCondition: CorePackage.MUST_BE_LOGGED_ON)));

menuItemFollowersPage(appID, pageID, privilegeLevelRequired) => MenuItemModel(
    documentID: pageID,
    text: 'Followers',
    description: 'Followers',
    icon: IconModel(
        codePoint: Icons.favorite_sharp.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID,
        pageID: pageID,
        conditions: DisplayConditionsModel(
            privilegeLevelRequired: privilegeLevelRequired,
            packageCondition: CorePackage.MUST_BE_LOGGED_ON)));

menuItemFollowing(appID, dialogID, privilegeLevelRequired) => MenuItemModel(
    documentID: dialogID,
    text: 'Following',
    description: 'Following',
    icon: IconModel(
        codePoint: Icons.favorite_sharp.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: OpenDialog(appID,
        dialogID: dialogID,
        conditions: DisplayConditionsModel(
            privilegeLevelRequired: privilegeLevelRequired,
            packageCondition: CorePackage.MUST_BE_LOGGED_ON)));

menuItemFollowingPage(appID, pageID, privilegeLevelRequired) => MenuItemModel(
    documentID: pageID,
    text: 'Following',
    description: 'Following',
    icon: IconModel(
        codePoint: Icons.favorite_sharp.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID,
        pageID: pageID,
        conditions: DisplayConditionsModel(
            privilegeLevelRequired: privilegeLevelRequired,
            packageCondition: CorePackage.MUST_BE_LOGGED_ON)));

menuItemAppMembers(appID, dialogID, privilegeLevelRequired) => MenuItemModel(
    documentID: dialogID,
    text: 'App Members',
    description: 'Members of the app',
    icon: IconModel(
        codePoint: Icons.people.codePoint,
        fontFamily: Icons.notifications.fontFamily),
    action: OpenDialog(
      appID,
      conditions: DisplayConditionsModel(
          privilegeLevelRequired: privilegeLevelRequired,
          packageCondition: CorePackage.MUST_BE_LOGGED_ON),
      dialogID: dialogID,
    ));

menuItemAppMembersPage(appID, pageID, privilegeLevelRequired) => MenuItemModel(
    documentID: pageID,
    text: 'App Members',
    description: 'Members of the app',
    icon: IconModel(
        codePoint: Icons.people.codePoint,
        fontFamily: Icons.notifications.fontFamily),
    action: GotoPage(
      appID,
      conditions: DisplayConditionsModel(
          privilegeLevelRequired: privilegeLevelRequired,
          packageCondition: CorePackage.MUST_BE_LOGGED_ON),
      pageID: pageID,
    ));

menuItemFiendFriendsPage(appID, pageID, privilegeLevelRequired) =>
    MenuItemModel(
        documentID: pageID,
        text: 'Find friends',
        description: 'Fiend friends',
        icon: IconModel(
            codePoint: Icons.favorite_sharp.codePoint,
            fontFamily: Icons.settings.fontFamily),
        action: GotoPage(appID,
            pageID: pageID,
            conditions: DisplayConditionsModel(
                privilegeLevelRequired: privilegeLevelRequired,
                packageCondition: CorePackage.MUST_BE_LOGGED_ON)));

menuItemJoin(appID, WorkflowModel workflowModel) => MenuItemModel(
    documentID: "join",
    text: "JOIN",
    description: "Request membership",
    icon: null,
    action: WorkflowActionModel(appID,
        conditions: DisplayConditionsModel(
          privilegeLevelRequired: PrivilegeLevelRequired.NoPrivilegeRequired,
          packageCondition: MembershipPackage.MEMBER_HAS_NO_MEMBERSHIP_YET,
        ),
        workflow: workflowModel));
