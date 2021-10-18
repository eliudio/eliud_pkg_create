import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_policy_model.dart';
import 'package:eliud_core/model/background_model.dart';
import 'package:eliud_core/model/decoration_color_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/platform_medium_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_core/style/tools/colors.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:flutter/material.dart';

import 'other/menu_helper.dart';

class HomeMenuHelper {
  final String appId;
  final String homeMenuId;
  final String? welcomePageId;
  final String? shopPageId;
  final String? feedPageId;

  HomeMenuHelper(this.appId, {this.welcomePageId, this.shopPageId, this.feedPageId})
      : homeMenuId = homeMenuID(appId);

  Future<HomeMenuModel> create() async {
    var homeMenuModel = HomeMenuModel(
        documentID: homeMenuId,
        appId: appId,
        name: 'Home menu',
        menu: await _homeMenuDef());

    await homeMenuRepository(appId: appId)!.add(homeMenuModel);
    return homeMenuModel;
  }

  Future<MenuDefModel> _homeMenuDef() async {
    var menuDefModel = MenuDefModel(
      documentID: homeMenuId,
      name: 'home menu',
      menuItems: [
        if (welcomePageId != null)
          menuItem(appId, welcomePageId, 'Welcome', Icons.rule),
      ],
      admin: false,
    );
    await menuDefRepository(appId: appId)!.add(menuDefModel);
    return menuDefModel;
  }
}
