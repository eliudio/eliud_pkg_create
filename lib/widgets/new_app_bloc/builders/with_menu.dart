import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';

class WithMenu {
  final AppModel app;
  final PublicMediumModel? logo;
  final String identifier;
  final String name;

  List<MenuItemModel> menuItems;

  WithMenu(this.app, {required this.identifier, required this.name, required this.menuItems, this.logo, });

  Future<MenuDefModel> menuDef() async {
    var menuDefModel = MenuDefModel(
      documentID: identifier,
      name: name,
      menuItems: menuItems,
      admin: false,
    );
    await menuDefRepository(appId: app.documentID!)!.add(menuDefModel);
    return menuDefModel;
  }
}

