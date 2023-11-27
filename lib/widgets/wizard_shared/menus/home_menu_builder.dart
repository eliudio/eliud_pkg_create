import 'package:eliud_core_main/model/abstract_repository_singleton.dart';
import 'package:eliud_core_main/model/home_menu_model.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';

import 'with_menu.dart';

class HomeMenuBuilder extends WithMenu {
  HomeMenuBuilder(super.app)
      : super(name: 'Left drawer', identifier: homeMenuID(app.documentID));

  Future<HomeMenuModel> getOrCreate() async {
    var homeMenuModel =
        await homeMenuRepository(appId: app.documentID)!.get(identifier);
    if (homeMenuModel == null) {
      homeMenuModel = HomeMenuModel(
          documentID: identifier,
          appId: app.documentID,
          name: 'Home menu',
          menu: await menuDef());
      await homeMenuRepository(appId: app.documentID)!.add(homeMenuModel);
    }
    return homeMenuModel;
  }
}
