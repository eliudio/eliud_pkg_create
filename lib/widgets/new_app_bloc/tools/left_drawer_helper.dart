import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_policy_model.dart';
import 'package:eliud_core/model/background_model.dart';
import 'package:eliud_core/model/decoration_color_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/platform_medium_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_core/style/tools/colors.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:flutter/material.dart';

import 'other/menu_helper.dart';

class LeftDrawerHelper {
  final String appId;
  final PublicMediumModel? logo;
  final String drawerId;
  final String? policyPageId;
  final String? shopPageId;
  final String? feedPageId;
  final String? welcomePageId;

  LeftDrawerHelper(this.appId, {this.welcomePageId, this.policyPageId, this.logo, this.shopPageId, this.feedPageId, })
      : drawerId = drawerID(appId, DrawerType.Left);

  Future<DrawerModel> create() async {
    var drawerModel = DrawerModel(
        documentID: drawerId,
        appId: appId,
        name: 'Drawer',
        headerText: '',
        headerBackgroundOverride:
            logo != null ? _drawerHeaderBGOverride(logo) : null,
        headerHeight: 0,
        popupMenuBackgroundColor: EliudColors.red,
        menu: await _drawerMenuDef());

    await drawerRepository(appId: appId)!.add(drawerModel);
    return drawerModel;
  }

  BackgroundModel _drawerHeaderBGOverride(PublicMediumModel? logo) {
    var decorationColorModels = <DecorationColorModel>[];
    var backgroundModel = BackgroundModel(
        documentID: 'left_drawer_header_bg_' + appId,
        decorationColors: decorationColorModels,
        backgroundImage: logo);
    return backgroundModel;
  }

  Future<MenuDefModel> _drawerMenuDef() async {
    var menuDefModel = MenuDefModel(
      documentID: drawerId,
      name: 'Left drawer',
      menuItems: [
        if (welcomePageId != null)
          menuItem(appId, welcomePageId, 'Welcome', Icons.rule),
        if (policyPageId != null)
          menuItem(appId, policyPageId, 'Policy', Icons.rule),
        if (shopPageId != null)
          menuItem(appId, shopPageId, 'Shop', Icons.rule),
        if (feedPageId != null)
          menuItem(appId, feedPageId, 'Feed', Icons.rule),
      ],
      admin: false,
    );
    await menuDefRepository(appId: appId)!.add(menuDefModel);
    return menuDefModel;
  }
}
