import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core_model/model/rgb_model.dart';
import 'package:eliud_core_model/style/frontend/has_drawer.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';

import 'with_menu.dart';

class RightDrawerBuilder extends WithMenu {
  RightDrawerBuilder(
    super.app,
  ) : super(
          name: 'Left drawer',
          identifier: drawerID(app.documentID, DrawerType.right),
        );

  Future<DrawerModel> getOrCreate() async {
    var drawerModel =
        await drawerRepository(appId: app.documentID)!.get(identifier);
    if (drawerModel == null) {
      drawerModel = DrawerModel(
          documentID: identifier,
          appId: app.documentID,
          name: 'Profile Drawer',
          headerText: '',
          secondHeaderText: 'name: \${userName}\ngroup: \${userGroup}',
          headerHeight: 0,
          popupMenuBackgroundColor: RgbModel(r: 255, g: 0, b: 0, opacity: 1.00),
          menu: await menuDef());

      await drawerRepository(appId: app.documentID)!.add(drawerModel);
    }
    return drawerModel;
  }
}
