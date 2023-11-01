import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/background_model.dart';
import 'package:eliud_core/model/decoration_color_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/model/rgb_model.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'with_menu.dart';

class LeftDrawerBuilder extends WithMenu {
  final PublicMediumModel? logo;
  LeftDrawerBuilder(
    AppModel app, {
    this.logo,
  }) : super(app,
            name: 'Left drawer',
            identifier: drawerID(app.documentID, DrawerType.Left));

  Future<DrawerModel> getOrCreate() async {
    var drawerModel =
        await drawerRepository(appId: app.documentID)!.get(identifier);
    if (drawerModel == null) {
      var headerBackgroundOverride;
      if (logo != null) {
        headerBackgroundOverride = _drawerHeaderBGOverride(logo);
      }

      drawerModel = DrawerModel(
          documentID: identifier,
          appId: app.documentID,
          name: 'Drawer',
          headerText: '',
          headerBackgroundOverride: headerBackgroundOverride,
          headerHeight: 0,
          popupMenuBackgroundColor: RgbModel(r: 255, g: 0, b: 0, opacity: 1.00),
          menu: await menuDef());

      await drawerRepository(appId: app.documentID)!.add(drawerModel);
    } else {
      // update the logo with the logo provided
      if (logo != null) {
        var headerBackgroundOverride = _drawerHeaderBGOverride(logo);
        await drawerRepository(appId: app.documentID)!.update(drawerModel
            .copyWith(headerBackgroundOverride: headerBackgroundOverride));
      }
    }
    return drawerModel;
  }

  BackgroundModel _drawerHeaderBGOverride(PublicMediumModel? logo) {
    var decorationColorModels = <DecorationColorModel>[];
    var backgroundModel = BackgroundModel(
        decorationColors: decorationColorModels, backgroundImage: logo);
    return backgroundModel;
  }
}
