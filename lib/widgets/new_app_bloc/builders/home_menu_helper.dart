import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_policy_model.dart';
import 'package:eliud_core/model/background_model.dart';
import 'package:eliud_core/model/decoration_color_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/platform_medium_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_core/style/tools/colors.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/with_menu.dart';
import 'package:flutter/material.dart';

import 'link_specifications.dart';
import 'other/menu_helper.dart';

class HomeMenuHelper extends WithMenu {
  HomeMenuHelper(String appId, {required List<MenuItemModel> menuItems, PublicMediumModel? logo, }):
        super(appId, menuItems: menuItems, name: 'Left drawer', identifier: homeMenuID(appId), logo: logo);

  Future<HomeMenuModel> create() async {
    var homeMenuModel = HomeMenuModel(
        documentID: identifier,
        appId: appId,
        name: 'Home menu',
        menu: await menuDef());

    await homeMenuRepository(appId: appId)!.add(homeMenuModel);
    return homeMenuModel;
  }
}
