import 'dart:convert';
import 'package:eliud_core/core/base/entity_base.dart';
import 'package:eliud_core/core/base/model_base.dart';
import 'package:eliud_core/core/base/repository_base.dart';
import 'package:eliud_core/core/wizards/registry/registry.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_bar_entity.dart';
import 'package:eliud_core/model/app_entity.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/dialog_entity.dart';
import 'package:eliud_core/model/drawer_entity.dart';
import 'package:eliud_core/model/home_menu_entity.dart';
import 'package:eliud_core/model/menu_def_entity.dart';
import 'package:eliud_core/model/page_entity.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import '../widgets/bodycomponents/bodycomponents__bloc/bodycomponents_create_state.dart';
import 'jsonconst.dart';

class JsonToModelsHelper {
  static Future<List<NewAppTask>> createAppFromJson(
      String appId, String memberId, String jsonText) async {
    List<NewAppTask> tasks = [];

    Map<String, dynamic>? map;
    tasks.add(() async {
      try {
        map = jsonDecode(jsonText);
      } catch (e) {
        print('Exception during jsonDecode');
        print('json: ' + jsonText);
      }
    });

    tasks.add(() async {
      if (map != null) {
        var appBarMap = map![JsonConsts.appBar];
        appBarMap['appId'] = appId;
        var documentID = appBarMap['documentID'];
        var appBarEntity = AppBarEntity.fromMap(appBarMap);
        if (appBarEntity != null) {
          await appBarRepository(appId: appId)!
              .addEntity(documentID, appBarEntity);
        }
      }
    });

    tasks.add(() async {
      if (map != null) {
        var leftDrawerMap = map![JsonConsts.leftDrawer];
        leftDrawerMap['appId'] = appId;
        var documentID = leftDrawerMap['documentID'];
        var leftDrawerEntity = DrawerEntity.fromMap(leftDrawerMap);
        if (leftDrawerEntity != null) {
          await drawerRepository(appId: appId)!
              .addEntity(documentID, leftDrawerEntity);
        }
      }
    });

    tasks.add(() async {
      if (map != null) {
        var rightDrawerMap = map![JsonConsts.rightDrawer];
        rightDrawerMap['appId'] = appId;
        var documentID = rightDrawerMap['documentID'];
        var rightDrawerEntity = DrawerEntity.fromMap(rightDrawerMap);
        if (rightDrawerEntity != null) {
          await drawerRepository(appId: appId)!
              .addEntity(documentID, rightDrawerEntity);
        }
      }
    });

    tasks.add(() async {
      if (map != null) {
        var homeMenuMap = map![JsonConsts.homeMenu];
        homeMenuMap['appId'] = appId;
        var documentID = homeMenuMap['documentID'];
        var homeMenuEntity = HomeMenuEntity.fromMap(homeMenuMap);
        if (homeMenuEntity != null) {
          await homeMenuRepository(appId: appId)!
              .addEntity(documentID, homeMenuEntity);
        }
      }
    });

    tasks.add(() async {
      if (map != null) {
        List<dynamic>? menuDefs = map![JsonConsts.menuDef];
        if (menuDefs != null) {
          for (var menuDef in menuDefs) {
            var documentID = menuDef['documentID'];
            menuDef['appId'] = appId;
            var menuItems = menuDef['menuItems'];
            for (var menuItem in menuItems) {
              var action = menuItem['action'];
              if (action != null) {
                action['appID'] = appId;
              }
            }
            var menuDefEntity = MenuDefEntity.fromMap(menuDef);
            if (menuDefEntity != null) {
              await menuDefRepository(appId: appId)!
                  .addEntity(documentID, menuDefEntity);
            }
          }
        }
      }
    });

    tasks.add(() async {
      if (map != null) {
        List<dynamic>? dialogs = map![JsonConsts.dialogs];
        if (dialogs != null) {
          for (var dialog in dialogs) {
            var documentID = dialog['documentID'];
            dialog['appId'] = appId;
            var dialogEntity = DialogEntity.fromMap(dialog);
            if (dialogEntity != null) {
              await dialogRepository(appId: appId)!
                  .addEntity(documentID, dialogEntity);
            }
          }
        }
      }
    });

    tasks.add(() async {
      if (map != null) {
        List<dynamic>? pages = map![JsonConsts.pages];
        if (pages != null) {
          for (var page in pages) {
            var documentID = page['documentID'];
            page['appId'] = appId;
            var pageEntity = PageEntity.fromMap(page);
            if (pageEntity != null) {
              await pageRepository(appId: appId)!
                  .addEntity(documentID, pageEntity);
            }
          }
        }
      }
    });

    tasks.add(() async {
      if (map != null) {
        var appMap = map![JsonConsts.app];
        appMap['ownerId'] = memberId;
        var appEntity = AppEntity.fromMap(appMap);
        if (appEntity != null) {
          await appRepository()!.updateEntity(appId, appEntity);
        }
      }
    });

    var pluginsWithComponents = await retrievePluginsWithComponents();
    for (var pluginsWithComponent in pluginsWithComponents) {
      tasks.add(() async {
        if (map != null) {
          var pluginName = pluginsWithComponent.name;
          for (var componentSpec in pluginsWithComponent.componentSpec) {
            var componentName = componentSpec.name;
            var fullName = pluginName + "-" + componentName;
            var theItems = map![fullName];
            if (theItems != null) {
              var repository = componentSpec.retrieveRepository(appId: appId)
                  as RepositoryBase<ModelBase, EntityBase>;
              for (var theItem in theItems) {
                theItem['appId'] = appId;
                var documentID = theItem['documentID'];
                var entity = repository.fromMap(theItem);
                if (entity != null) {
                  repository.addEntity(documentID, entity);
                }
              }
            }
          }
        }
      });
    }


    // Do this for all, including the need to loop though all components, sometimes change entry, like documentID
    // Perhaps change ownership / author
    // Upload/create images
    return tasks;
  }
}
