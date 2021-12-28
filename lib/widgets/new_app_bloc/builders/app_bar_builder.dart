import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/with_menu.dart';

class AppBarBuilder extends WithMenu {
  AppBarBuilder(AppModel app, {required List<MenuItemModel> menuItems, PublicMediumModel? logo, }):
        super(app, menuItems: menuItems, name: 'Left drawer', identifier: appBarID(app.documentID!), logo: logo);

  Future<AppBarModel> create() async {
    var appBarModel = AppBarModel(
        documentID: identifier,
        appId: app.documentID!,
        header: HeaderSelection.Title,
        iconMenu: await menuDef());

    await appBarRepository(appId: app.documentID!)!.add(appBarModel);
    return appBarModel;
  }

}
