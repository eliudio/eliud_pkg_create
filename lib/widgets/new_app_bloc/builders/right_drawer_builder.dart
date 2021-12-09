import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_core/style/tools/colors.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';

import 'with_menu.dart';

class RightDrawerBuilder extends WithMenu {
  RightDrawerBuilder(String appId, {required List<MenuItemModel> menuItems, PublicMediumModel? logo, }):
        super(appId, menuItems: menuItems, name: 'Left drawer', identifier: drawerID(appId, DrawerType.Right), logo: logo);

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
