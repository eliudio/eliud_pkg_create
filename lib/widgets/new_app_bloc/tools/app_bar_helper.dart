import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_policy_model.dart';
import 'package:eliud_core/model/background_model.dart';
import 'package:eliud_core/model/conditions_model.dart';
import 'package:eliud_core/model/decoration_color_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/icon_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/platform_medium_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_core/style/tools/colors.dart';
import 'package:eliud_core/tools/action/action_model.dart';
import 'package:eliud_pkg_chat/chat_package.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:flutter/material.dart';

import 'dialog/chat_dialog_helper.dart';
import 'other/menu_helper.dart';

class AppBarHelper {
  final String appId;
  final String appBarId;
  final ChatDialogs? chatDialogs;

  AppBarHelper(
    this.appId, {this.chatDialogs}
  ) : appBarId = appBarID(appId);

  Future<AppBarModel> create() async {
    var appBarModel = AppBarModel(
        documentID: appBarId,
        appId: appId,
        header: HeaderSelection.Title,
        iconMenu: await _menuDefModel());

    await appBarRepository(appId: appId)!.add(appBarModel);
    return appBarModel;
  }

  Future<MenuDefModel> _menuDefModel() async {
    var menuDefModel = MenuDefModel(
      documentID: appBarId,
      name: 'AppBar Menu',
      menuItems: [
        if (chatDialogs != null) MenuItemModel(
            documentID: ChatDialogHelper.IDENTIFIER_MEMBER_HAS_UNREAD_CHAT,
            text: 'Chat',
            description: 'Some unread messages available',
            icon: IconModel(
                codePoint: Icons.chat_bubble_rounded.codePoint,
                fontFamily: Icons.notifications.fontFamily),
            action: OpenDialog(appId,
                dialogID: chatDialogs!.hasUnreadChatDialog.documentID!,
                conditions: ConditionsModel(
                    privilegeLevelRequired:
                    PrivilegeLevelRequired.NoPrivilegeRequired,
                    packageCondition: ChatPackage.CONDITION_MEMBER_HAS_UNREAD_CHAT))),
        if (chatDialogs != null) MenuItemModel(
            documentID: ChatDialogHelper.IDENTIFIER_MEMBER_ALL_HAVE_BEEN_READ,
            text: 'Chat',
            description: 'Open chat',
            icon: IconModel(
                codePoint: Icons.chat_bubble_outline_rounded.codePoint,
                fontFamily: Icons.notifications.fontFamily),
            action: OpenDialog(appId,
                dialogID: chatDialogs!.allMessagesHaveBeenReadChatDialog.documentID!,
                conditions: ConditionsModel(
                    privilegeLevelRequired:
                    PrivilegeLevelRequired.NoPrivilegeRequired,
                    packageCondition: ChatPackage.CONDITION_MEMBER_ALL_HAVE_BEEN_READ))),

      ],
      admin: false,
    );
    await menuDefRepository(appId: appId)!.add(menuDefModel);
    return menuDefModel;
  }
}
