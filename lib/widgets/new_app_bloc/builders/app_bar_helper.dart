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
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/with_menu.dart';
import 'package:flutter/material.dart';

import 'dialog/chat_dialog_helper.dart';
import 'other/menu_helper.dart';

class AppBarHelper extends WithMenu {
  AppBarHelper(String appId, {required List<MenuItemModel> menuItems, PublicMediumModel? logo, }):
        super(appId, menuItems: menuItems, name: 'Left drawer', identifier: appBarID(appId), logo: logo);

  Future<AppBarModel> create() async {
    var appBarModel = AppBarModel(
        documentID: identifier,
        appId: appId,
        header: HeaderSelection.Title,
        iconMenu: await menuDef());

    await appBarRepository(appId: appId)!.add(appBarModel);
    return appBarModel;
  }

}
