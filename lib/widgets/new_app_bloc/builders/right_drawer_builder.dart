
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
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_core/style/tools/colors.dart';
import 'package:eliud_core/tools/action/action_model.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:flutter/material.dart';

import 'with_menu.dart';

class RightDrawerBuilder extends WithMenu {
  RightDrawerBuilder(String appId, {required List<MenuItemModel> menuItems, PublicMediumModel? logo, }):
        super(appId, menuItems: menuItems, name: 'Left drawer', identifier: drawerID(appId, DrawerType.Left), logo: logo);

  Future<DrawerModel> create() async {
    var drawerModel = DrawerModel(
        documentID: identifier,
        appId: appId,
        name: 'Profile Drawer',
        headerText: '',
        secondHeaderText: 'name: \${userName}\ngroup: \${userGroup}',
        headerHeight: 0,
        popupMenuBackgroundColor: EliudColors.red,
        menu: await menuDef());

    await drawerRepository(appId: appId)!.add(drawerModel);
    return drawerModel;
  }
}
