import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_policy_model.dart';
import 'package:eliud_core/model/background_model.dart';
import 'package:eliud_core/model/decoration_color_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/platform_medium_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_core/style/tools/colors.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:flutter/material.dart';

import 'link_specifications.dart';
import 'other/menu_helper.dart';
import 'with_menu.dart';

class LeftDrawerHelper extends WithMenu {
  LeftDrawerHelper(String appId, {required List<MenuItemModel> menuItems, PublicMediumModel? logo, }):
        super(appId, menuItems: menuItems, name: 'Left drawer', identifier: drawerID(appId, DrawerType.Left), logo: logo);

  Future<DrawerModel> create() async {
    var drawerModel = DrawerModel(
        documentID: identifier,
        appId: appId,
        name: 'Drawer',
        headerText: '',
        headerBackgroundOverride:
            logo != null ? _drawerHeaderBGOverride(logo) : null,
        headerHeight: 0,
        popupMenuBackgroundColor: EliudColors.red,
        menu: await menuDef());

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
}

