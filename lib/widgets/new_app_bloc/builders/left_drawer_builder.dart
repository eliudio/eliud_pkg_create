import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/background_model.dart';
import 'package:eliud_core/model/decoration_color_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_core/style/tools/colors.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'with_menu.dart';

class LeftDrawerBuilder extends WithMenu {
  LeftDrawerBuilder(String appId, {required List<MenuItemModel> menuItems, PublicMediumModel? logo, }):
        super(appId, menuItems: menuItems, name: 'Left drawer', identifier: drawerID(appId, DrawerType.Left), logo: logo);

  Future<DrawerModel> create() async {
    var headerBackgroundOverride;
    if (logo != null) {
      headerBackgroundOverride = _drawerHeaderBGOverride(logo);
      await backgroundRepository()!.add(headerBackgroundOverride);
    }

    var drawerModel = DrawerModel(
        documentID: identifier,
        appId: appId,
        name: 'Drawer',
        headerText: '',
        headerBackgroundOverride:headerBackgroundOverride,
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

