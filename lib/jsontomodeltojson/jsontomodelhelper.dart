import 'dart:convert';
import 'dart:typed_data';
import 'package:eliud_core/core/base/entity_base.dart';
import 'package:eliud_core/core/base/repository_base.dart';
import 'package:eliud_core/core/registry.dart';
import 'package:eliud_core/core/wizards/registry/registry.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_entity.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_core/model/dialog_entity.dart';
import 'package:eliud_core/model/member_medium_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/page_entity.dart';
import 'package:eliud_core/model/platform_medium_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/model/storage_conditions_model.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_core/tools/storage/medium_helper.dart';
import 'package:eliud_core/tools/storage/member_medium_helper.dart';
import 'package:eliud_core/tools/storage/platform_medium_helper.dart';
import 'package:eliud_core/tools/storage/public_medium_helper.dart';
import '../tools/defaults.dart';
import 'jsonconst.dart';
import 'package:http/http.dart' as http;

class JsonToModelsHelper {
  static Future<List<NewAppTask>> createAppFromURL(
      AppModel app, String memberId, String url) async {
    var theUrl = Uri.parse(url);
    return _createAppFromURI(app, memberId, theUrl);
  }

  static Future<List<NewAppTask>> createAppFromMemberMedium(AppModel app,
      String memberId, MemberMediumModel memberMediumModel) async {
    var theUrl = Uri.parse(memberMediumModel.url!);
    return _createAppFromURI(app, memberId, theUrl);
  }

  static Future<List<NewAppTask>> _createAppFromURI(
      AppModel app, String memberId, Uri uri) async {
    final response = await http.get(uri);
    var json = String.fromCharCodes(response.bodyBytes);
    return createAppFromJson(app, memberId, json);
  }

  static Future<List<NewAppTask>> createOtherFromURL(
      AppModel app, String memberId, String url, bool includeMedia) async {
    var theUrl = Uri.parse(url);
    return _createOtherFromURI(app, memberId, theUrl, includeMedia);
  }

  static Future<List<NewAppTask>> createOtherFromMemberMedium(AppModel app,
      String memberId, MemberMediumModel memberMediumModel, bool includeMedia) async {
    var theUrl = Uri.parse(memberMediumModel.url!);
    return _createOtherFromURI(app, memberId, theUrl, includeMedia);
  }

  static Future<List<NewAppTask>> _createOtherFromURI(
      AppModel app, String memberId, Uri uri, bool includeMedia) async {
    final response = await http.get(uri);
    var json = String.fromCharCodes(response.bodyBytes);
    return createOtherFromJson(app, memberId, json, includeMedia);
  }

  static Future<List<NewAppTask>> createAppFromJson(
      AppModel app, String memberId, String jsonText) async {
    var appId = app.documentID;
    List<NewAppTask> tasks = [];

    Map<String, dynamic>? map = jsonDecode(jsonText);
    if (map != null) {
      var oldAppId = map['app']['documentID'];
      var leftDrawerDocumentId = drawerID(appId, DrawerType.Left);
      var rightDrawerDocumentId = drawerID(appId, DrawerType.Right);
      var homeMenuId = homeMenuID(appId);
      var appBarId = appBarID(appId);
      for (var entry in map.entries) {
        tasks.add(() async {
          var key = entry.key;
          if (key == JsonConsts.app) {
            var appMap = entry.value;
            appMap['ownerID'] = memberId;
            var appEntity = AppEntity.fromMap(appMap);
            if (appEntity != null) {
              await appRepository()!.updateEntity(appId, appEntity);
            }
          } else if (key == DrawerModel.packageName + "-" + DrawerModel.id) {
            var values = entry.value;
            for (var theItem in values) {
              var documentID;
              if (theItem['documentID'] == drawerID(oldAppId, DrawerType.Left)) {
                documentID = leftDrawerDocumentId;
              } else {
                documentID = rightDrawerDocumentId;
              }
              theItem['appId'] = appId;
              var entity = drawerRepository(appId: appId)!.fromMap(theItem);
              if (entity != null) {
                await drawerRepository(appId: appId)!.addEntity(documentID, entity);
              } else {
                print("Error getting entity for " + theItem);
              }
            }
          } else if (key == AppBarModel.packageName + "-" + AppBarModel.id) {
            var values = entry.value;
            for (var theItem in values) {
              theItem['appId'] = appId;
              var entity = appBarRepository(appId: appId)!.fromMap(theItem);
              if (entity != null) {
                await appBarRepository(appId: appId)!.addEntity(appBarId, entity);
              } else {
                print("Error getting entity for " + theItem);
              }
            }
          } else if (key == HomeMenuModel.packageName + "-" + HomeMenuModel.id) {
            var values = entry.value;
            for (var theItem in values) {
              theItem['appId'] = appId;
              var entity = homeMenuRepository(appId: appId)!.fromMap(theItem);
              if (entity != null) {
                await homeMenuRepository(appId: appId)!.addEntity(homeMenuId, entity);
              } else {
                print("Error getting entity for " + theItem);
              }
            }
          } else if (key == JsonConsts.pages) {
            List<dynamic>? pages = entry.value;
            if (pages != null) {
              for (var page in pages) {
                await createPageEntity(page, appId, homeMenuId, leftDrawerDocumentId, rightDrawerDocumentId, appBarId);
              }
            }
          } else if (key == JsonConsts.dialogs) {
            List<dynamic>? dialogs = entry.value;
            if (dialogs != null) {
              for (var dialog in dialogs) {
                await createDialogEntity(dialog, appId);
              }
            }
          } else if (key == MenuDefModel.packageName + "-" + MenuDefModel.id) {
            var theItems = entry.value;
            if (theItems != null) {
              await restoreFromMap(theItems, menuDefRepository(appId: appId)!, appId,
                  postProcessing: (menuDef) {
                    var menuItems = menuDef['menuItems'];
                    for (var menuItem in menuItems) {
                      var action = menuItem['action'];
                      if (action != null) {
                        action['appID'] = appId;
                      }
                    }
                  });
            }
          } else if (key ==
              PlatformMediumModel.packageName + "-" + PlatformMediumModel.id) {
            var theItems = entry.value;
            if (theItems != null) {
              var repository = platformMediumRepository(appId: appId)!;
              for (var theItem in theItems) {
                await createPlatformMedium(theItem, app, memberId, repository);
              }
            }
          } else if (key ==
              MemberMediumModel.packageName + "-" + MemberMediumModel.id) {
            var theItems = entry.value;
            if (theItems != null) {
              var repository = memberMediumRepository(appId: appId)!;
              for (var theItem in theItems) {
                await createMemberMedium(theItem, app, memberId, repository);
              }
            }
          } else if (key ==
              PublicMediumModel.packageName + "-" + PublicMediumModel.id) {
            var theItems = entry.value;
            if (theItems != null) {
              var repository = publicMediumRepository(appId: appId)!;
              for (var theItem in theItems) {
                await createPublicMedium(theItem, app, memberId, repository);
              }
            }
          } else {
            var split = key.split('-');
            if (split.length == 2) {
              try {
                var pluginName = split[0];
                var componentId = split[1];
                var values = entry.value;
                var retrieveRepo = Registry.registry()!
                    .getRetrieveRepository(pluginName, componentId);
                if (retrieveRepo != null) {
                  await restoreFromMap(values, retrieveRepo(appId: appId), appId);
                } else {
                  print("Can't find repo for: " + key);
                }
              } catch (e) {
                print("Error processing " + key);
              }
            } else {
              print("Dont know how to handle this entry with key: " + key);
            }
          }
        });
      }
    }

    return tasks;
  }

  static Future<List<NewAppTask>> createOtherFromJson(
      AppModel app, String memberId, String jsonText, bool includeMedia) async {
    var appId = app.documentID;
    List<NewAppTask> tasks = [];

    Map<String, dynamic>? map = jsonDecode(jsonText);
    if (map != null) {
      var leftDrawerDocumentId = drawerID(appId, DrawerType.Left);
      var rightDrawerDocumentId = drawerID(appId, DrawerType.Right);
      var homeMenuId = homeMenuID(appId);
      var appBarId = appBarID(appId);

      Map<String, String> newDocumentIds = {};

      // pages and/or dialogs
      for (var entry in map.entries) {
        tasks.add(() async {
          var key = entry.key;
          if (key == JsonConsts.pages) {
            List<dynamic>? pages = entry.value;
            if (pages != null) {
              for (var page in pages) {
                page['documentID'] = newRandomKey();
                var bodyComponents = page['bodyComponents'];
                for (var bodyComponent in bodyComponents) {
                  var oldComponentId = bodyComponent['componentId'];
                  var newComponentId = newRandomKey();
                  bodyComponent['componentId'] = newComponentId;
                  newDocumentIds[oldComponentId] = newComponentId;
                }
                await createPageEntity(page, appId, homeMenuId, leftDrawerDocumentId, rightDrawerDocumentId, appBarId);
              }
            }
          } else if (key == JsonConsts.dialogs) {
            List<dynamic>? dialogs = entry.value;
            if (dialogs != null) {
              for (var dialog in dialogs) {
                dialog['documentID'] = newRandomKey();
                await createDialogEntity(dialog, appId);
              }
            }
          }
        });
      }

      // components
      for (var entry in map.entries) {
        tasks.add(() async {
          var key = entry.key;
          if (key == JsonConsts.app) {} else
          if (key == DrawerModel.packageName + "-" + DrawerModel.id) {} else
          if (key == AppBarModel.packageName + "-" + AppBarModel.id) {} else
          if (key == HomeMenuModel.packageName + "-" + HomeMenuModel.id) {} else
          if (key == JsonConsts.pages) {} else
          if (key == JsonConsts.dialogs) {} else if (key ==
              PlatformMediumModel.packageName + "-" +
                  PlatformMediumModel.id) {} else if (key ==
              MemberMediumModel.packageName + "-" +
                  MemberMediumModel.id) {} else if (key ==
              PublicMediumModel.packageName + "-" +
                  PublicMediumModel.id) {} else {
            var split = key.split('-');
            if (split.length == 2) {
              try {
                var pluginName = split[0];
                var componentId = split[1];
                var values = entry.value;
                var retrieveRepo = Registry.registry()!
                    .getRetrieveRepository(pluginName, componentId);
                if (retrieveRepo != null) {
                  await restoreFromMap(
                      values, retrieveRepo(appId: appId), appId,
                      newDocumentIds: newDocumentIds);
                } else {
                  print("Can't find repo for: " + key);
                }
              } catch (e) {
                print("Error processing " + key);
              }
            } else {
              print("Dont know how to handle this entry with key: " + key);
            }
          }
        });
      }

        // medium
      if (includeMedia) {
        for (var entry in map.entries) {
          tasks.add(() async {
            var key = entry.key;
            if (key ==
                PlatformMediumModel.packageName + "-" +
                    PlatformMediumModel.id) {
              var theItems = entry.value;
              if (theItems != null) {
                var repository = platformMediumRepository(appId: appId)!;
                for (var theItem in theItems) {
                  await createPlatformMedium(
                      theItem, app, memberId, repository);
                }
              }
            } else if (key ==
                MemberMediumModel.packageName + "-" + MemberMediumModel.id) {
              var theItems = entry.value;
              if (theItems != null) {
                var repository = memberMediumRepository(appId: appId)!;
                for (var theItem in theItems) {
                  await createMemberMedium(theItem, app, memberId, repository);
                }
              }
            } else if (key ==
                PublicMediumModel.packageName + "-" + PublicMediumModel.id) {
              var theItems = entry.value;
              if (theItems != null) {
                var repository = publicMediumRepository(appId: appId)!;
                for (var theItem in theItems) {
                  await createPublicMedium(theItem, app, memberId, repository);
                }
              }
            }
          });
        }
      }
    }

    return tasks;
  }

  static Future<PageEntity> createPageEntity(dynamic page, String appId, String homeMenuId, String leftDrawerDocumentId, String rightDrawerDocumentId, String appBarId) async {
    var documentID = page['documentID'];
    page['appId'] = appId;
    page['homeMenuId'] = homeMenuId;
    page['drawerId'] = leftDrawerDocumentId;
    page['endDrawerId'] = rightDrawerDocumentId;
    page['appBarId'] = appBarId;
    var pageEntity = PageEntity.fromMap(page);
    if (pageEntity != null) {
      return await pageRepository(appId: appId)!
          .addEntity(documentID, pageEntity);
    } else {
      throw Exception('Can not create pageEntity');
    }
  }

  static Future<DialogEntity> createDialogEntity(dynamic dialog, String appId, ) async {
    var documentID = dialog['documentID'];
    dialog['appId'] = appId;
    var dialogEntity = DialogEntity.fromMap(dialog);
    if (dialogEntity != null) {
      return await dialogRepository(appId: appId)!
          .addEntity(documentID, dialogEntity);
    } else {
      throw Exception('Can not create dialogEntity');
    }
  }

  static Future<void> createPlatformMedium(dynamic theItem, AppModel app, String memberId, RepositoryBase repository) async {
    try {
      var platformMedium = repository.fromMap(theItem);
      if (platformMedium != null) {
        var helper = PlatformMediumHelper(
            app,
            memberId,
            platformMedium.conditions == null
                ? PrivilegeLevelRequiredSimple
                .NoPrivilegeRequiredSimple
                : toPrivilegeLevelRequiredSimple(platformMedium
                .conditions!.privilegeLevelRequired!));
        await upload(
            repository,
            helper,
            platformMedium.base,
            platformMedium.ext,
            platformMedium.mediumType ?? 0,
            theItem,
            platformMedium.relatedMediumId);
      }
    } catch (e) {
      print("Error whilst creating public medium " + e.toString());
    }
  }

  static Future<void> createMemberMedium(dynamic theItem, AppModel app, String memberId, RepositoryBase repository) async {
    try {
      var memberMedium = repository.fromMap(theItem);
      if (memberMedium != null) {
        var memberMediumAccessibleByGroup =
        toMemberMediumAccessibleByGroup(
            memberMedium.accessibleByGroup ??
                MemberMediumAccessibleByGroup.Me.index);
        var helper = MemberMediumHelper(
            app, memberId, memberMediumAccessibleByGroup,
            accessibleByMembers: memberMedium.accessibleByMembers);
        await upload(
            repository,
            helper,
            memberMedium.base,
            memberMedium.ext,
            memberMedium.mediumType ?? 0,
            theItem,
            memberMedium.relatedMediumId);
      }
    } catch (e) {
      print("Error whilst creating public medium " + e.toString());
    }
  }

  static Future<void> createPublicMedium(dynamic theItem, AppModel app, String memberId, RepositoryBase repository) async {
    try {
      var publicMedium = repository.fromMap(theItem);
      if (publicMedium != null) {
        var helper = PublicMediumHelper(
          app,
          memberId,
        );
        await upload(
            repository,
            helper,
            publicMedium.base,
            publicMedium.ext,
            publicMedium.mediumType ?? 0,
            theItem,
            publicMedium.relatedMediumId);
      }
    } catch (e) {
      print("Error whilst creating public medium " + e.toString());
    }
  }


  static Future<void> upload(
      RepositoryBase repository,
      MediumHelper helper,
      String? base,
      String? ext,
      int mediumType,
      dynamic theItem,
      String? relatedMediumId) async {
    var baseName = (base ?? 'noname') + "." + (ext ?? '');
    var thumbNailName = (base ?? 'noname') + "-thumb." + (ext ?? '');
    var extractItem = theItem['extract'];
    if (mediumType == 0) {
      var extract = Uint8List.fromList(extractItem.cast<int>());
      // Photo
      await helper.createThumbnailUploadPhotoData(
          theItem['documentID'], extract, baseName, thumbNailName,
          relatedMediumId: relatedMediumId);
    } else if (mediumType == 1) {
      var extract = Uint8List.fromList(extractItem.cast<int>());
      // Video
      await helper.createThumbnailUploadVideoData(
        theItem['documentID'],
        extract,
        baseName,
        thumbNailName,
      );
    } else if (mediumType == 2) {
      var extract = Uint8List.fromList(extractItem.cast<int>());
      // Pdf
      await helper.createThumbnailUploadPhotoData(
          theItem['documentID'], extract, baseName, thumbNailName,
          relatedMediumId: relatedMediumId);
    } else if (mediumType == 3) {
      // Txt
      await helper.uploadTextData(
        theItem['documentID'],
        extractItem,
        baseName,
      );
    }
  }

  static Future<void> restoreFromMap(
    dynamic theItems,
    RepositoryBase repository,
    String appId, {
    PostProcessing? postProcessing,
    Map<String, String>? newDocumentIds
  }) async {
    if (theItems != null) {
      for (var theItem in theItems) {
        var documentID = theItem['documentID'];
        // potentially rename the document
        if (newDocumentIds != null) {
          var newDocumentID = newDocumentIds[documentID];
          if (newDocumentID != null) {
            theItem['documentID'] = newDocumentID;
            documentID = newDocumentID;
          }
        }
        if (postProcessing != null) {
          postProcessing(theItem);
        }

        EntityBase entity = repository.fromMap(theItem);
        var newEntity = entity.switchAppId(newAppId: appId);
        await repository.addEntity(documentID, newEntity);
      }
    }
  }

  static void replaceAll(Map map, String key, String value) {
    for (var theItem in map.entries) {
      if (theItem.key == key) {
        map[value] = value;
      }
      if (theItem.value is Map) {
        replaceAll(theItem.value, key, value);
      }
    }
  }
}

typedef PostProcessing = void Function(Map<String, dynamic> item);
