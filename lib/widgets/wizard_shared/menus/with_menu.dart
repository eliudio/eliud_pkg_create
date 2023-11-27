import 'package:eliud_core_main/model/abstract_repository_singleton.dart';
import 'package:eliud_core_main/model/app_model.dart';
import 'package:eliud_core_main/model/menu_def_model.dart';
import 'package:eliud_core_main/model/menu_item_model.dart';

class WithMenu {
  final AppModel app;
  final String identifier;
  final String name;

  WithMenu(
    this.app, {
    required this.identifier,
    required this.name,
  });

  Future<MenuDefModel> menuDef() async {
    var menuDefModel = MenuDefModel(
      appId: app.documentID,
      documentID: identifier,
      name: name,
      menuItems: [],
      admin: false,
    );
    await menuDefRepository(appId: app.documentID)!.add(menuDefModel);
    return menuDefModel;
  }

  Future<void> updateMenuItems(List<MenuItemModel> items) async {
    var menuDefModel =
        await menuDefRepository(appId: app.documentID)!.get(identifier);
    menuDefModel ??= await menuDef();
    List<MenuItemModel> newItems = [];
    if (menuDefModel.menuItems != null) {
      newItems.addAll(menuDefModel.menuItems!);
    }
    newItems.addAll(items);
    menuDefModel = menuDefModel.copyWith(menuItems: newItems);
    await menuDefRepository(appId: app.documentID)!.update(menuDefModel);
  }
}
