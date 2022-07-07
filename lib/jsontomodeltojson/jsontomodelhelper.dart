import 'dart:convert';
import 'package:eliud_core/core/base/entity_base.dart';
import 'package:eliud_core/core/base/model_base.dart';
import 'package:eliud_core/core/base/repository_base.dart';
import 'package:eliud_core/core/wizards/registry/registry.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_bar_entity.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_entity.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/dialog_entity.dart';
import 'package:eliud_core/model/drawer_entity.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_entity.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/member_medium_model.dart';
import 'package:eliud_core/model/menu_def_entity.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/page_entity.dart';
import 'package:eliud_core/model/platform_medium_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/tools/component/component_spec.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import '../widgets/bodycomponents/bodycomponents__bloc/bodycomponents_create_state.dart';
import 'jsonconst.dart';
import 'package:http/http.dart' as http;

class JsonToModelsHelper {
  static Future<List<NewAppTask>> createAppFromURL(String appId,
      String memberId, String url) async {
    var theUrl = Uri.parse(url);
    return _createAppFromURI(appId, memberId, theUrl);
  }

  static Future<List<NewAppTask>> createAppFromMemberMedium(String appId,
      String memberId, MemberMediumModel memberMediumModel) async {
    var theUrl = Uri.parse(memberMediumModel.url!);
    return _createAppFromURI(appId, memberId, theUrl);
  }

  static Future<List<NewAppTask>> _createAppFromURI(String appId,
      String memberId, Uri uri) async {
    final response = await http.get(uri);
    var json = String.fromCharCodes(response.bodyBytes);
    return createAppFromJson(appId, memberId, json);
  }

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
        var fullName = AppBarModel.packageName + "-" + AppBarModel.id;
        var theItems = map![fullName];
        if (theItems != null) {
          restoreFromMap(
              theItems,
              appBarRepository(appId: appId)!,
              appId);
        }
      }
    });

    tasks.add(() async {
      if (map != null) {
        var fullName = DrawerModel.packageName + "-" + DrawerModel.id;
        var theItems = map![fullName];
        if (theItems != null) {
          restoreFromMap(
              theItems,
              drawerRepository(appId: appId)!,
              appId);
        }
      }
    });

    tasks.add(() async {
      if (map != null) {
        var fullName = HomeMenuModel.packageName + "-" + HomeMenuModel.id;
        var theItems = map![fullName];
        if (theItems != null) {
          restoreFromMap(
              theItems,
              homeMenuRepository(appId: appId)!,
              appId);
        }
      }
    });

    tasks.add(() async {
      if (map != null) {
        var fullName = PublicMediumModel.packageName + "-" + PublicMediumModel.id;
        var theItems = map![fullName];
        if (theItems != null) {
          restoreFromMap(
              theItems,
              publicMediumRepository(appId: appId)!,
              appId);
        }
      }
    });

    tasks.add(() async {
      if (map != null) {
        var fullName = MemberMediumModel.packageName + "-" + MemberMediumModel.id;
        var theItems = map![fullName];
        if (theItems != null) {
          restoreFromMap(
              theItems,
              memberMediumRepository(appId: appId)!,
              appId);
        }
      }
    });

    tasks.add(() async {
      if (map != null) {
        var fullName = PlatformMediumModel.packageName + "-" + PlatformMediumModel.id;
        var theItems = map![fullName];
        if (theItems != null) {
          restoreFromMap(
              theItems,
              platformMediumRepository(appId: appId)!,
              appId);
        }
      }
    });

    tasks.add(() async {
      if (map != null) {
        var fullName = MenuDefModel.packageName + "-" + MenuDefModel.id;
        var theItems = map![fullName];
        if (theItems != null) {
          restoreFromMap(
              theItems,
              menuDefRepository(appId: appId)!,
              appId, postProcessing: (menuDef) {
            var menuItems = menuDef['menuItems'];
            for (var menuItem in menuItems) {
              var action = menuItem['action'];
              if (action != null) {
                action['appID'] = appId;
              }
            }
          });
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
              restoreFromMap(
                  theItems,
                  componentSpec.retrieveRepository(appId: appId)
                      as RepositoryBase<ModelBase, EntityBase>,
                  appId);
            }
          }
        }
      });
    }

    return tasks;
  }

  static void restoreFromMap(
    dynamic theItems,
    RepositoryBase repository,
    String appId, {
    PostProcessing? postProcessing,
  }) {
    if (theItems != null) {
      for (var theItem in theItems) {
        theItem['appId'] = appId;
        var documentID = theItem['documentID'];
        if (postProcessing != null) {
          postProcessing(theItem);
        }
        var entity = repository.fromMap(theItem);
        if (entity != null) {
          repository.addEntity(documentID, entity);
        }
      }
    }
  }
}

typedef PostProcessing = void Function(Map<String, dynamic> item);
