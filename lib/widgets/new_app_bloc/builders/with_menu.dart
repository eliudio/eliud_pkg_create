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

class WithMenu {
  final String appId;
  final PublicMediumModel? logo;
  final String identifier;
  final String name;

  List<MenuItemModel> menuItems;

  WithMenu(this.appId, {required this.identifier, required this.name, required this.menuItems, this.logo, });

  Future<MenuDefModel> menuDef() async {
    var menuDefModel = MenuDefModel(
      documentID: identifier,
      name: name,
      menuItems: menuItems,
      admin: false,
    );
    await menuDefRepository(appId: appId)!.add(menuDefModel);
    return menuDefModel;
  }
}

