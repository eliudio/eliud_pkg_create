import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/with_menu.dart';

class HomeMenuBuilder extends WithMenu {
  HomeMenuBuilder(AppModel app, {required List<MenuItemModel> menuItems, PublicMediumModel? logo, }):
        super(app, menuItems: menuItems, name: 'Left drawer', identifier: homeMenuID(app.documentID!), logo: logo);

  Future<HomeMenuModel> create() async {
    var homeMenuModel = HomeMenuModel(
        documentID: identifier,
        appId: app.documentID!,
        name: 'Home menu',
        menu: await menuDef());

    await homeMenuRepository(appId: app.documentID!)!.add(homeMenuModel);
    return homeMenuModel;
  }
}
