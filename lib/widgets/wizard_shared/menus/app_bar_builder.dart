import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';

import 'with_menu.dart';

class AppBarBuilder extends WithMenu {
  AppBarBuilder(super.app)
      : super(name: 'Left drawer', identifier: appBarID(app.documentID));

  Future<AppBarModel> getOrCreate() async {
    var appBarModel =
        await appBarRepository(appId: app.documentID)!.get(identifier);
    if (appBarModel == null) {
      appBarModel = AppBarModel(
          documentID: identifier,
          appId: app.documentID,
          header: HeaderSelection.title,
          iconMenu: await menuDef());

      await appBarRepository(appId: app.documentID)!.add(appBarModel);
    }
    return appBarModel;
  }
}
