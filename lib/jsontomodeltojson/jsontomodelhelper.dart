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

typedef void Feedback(String key, String documentId);

class ComponentSpec {
  final String pluginName;
  final String componentId;
  final String documentId;

  ComponentSpec(this.pluginName, this.componentId, this.documentId);
}

class JsonToModelsHelper {
  static Future<List<NewAppTask>> createAppFromURL(
      AppModel app, String memberId, String url, {Feedback? feedback,}) async {
    var theUrl = Uri.parse(url);
    return _createAppFromURI(app, memberId, theUrl, feedback: feedback);
  }

  static Future<List<NewAppTask>> createAppFromMemberMedium(AppModel app,
      String memberId, MemberMediumModel memberMediumModel, {Feedback? feedback,}) async {
    var theUrl = Uri.parse(memberMediumModel.url!);
    return _createAppFromURI(app, memberId, theUrl, feedback: feedback);
  }

  static Future<List<NewAppTask>> _createAppFromURI(
      AppModel app, String memberId, Uri uri, {Feedback? feedback,}) async {
    final response = await http.get(uri);
    var json = String.fromCharCodes(response.bodyBytes);
    return createAppFromJson(app, memberId, json, feedback: feedback);
  }

  static Future<List<NewAppTask>> createOtherFromURL(
      AppModel app, String memberId, String url, bool includeMedia, {Feedback? feedback,}) async {
    var theUrl = Uri.parse(url);
    return _createOtherFromURI(app, memberId, theUrl, includeMedia, feedback: feedback);
  }

  static Future<List<NewAppTask>> createOtherFromMemberMedium(AppModel app,
      String memberId, MemberMediumModel memberMediumModel, bool includeMedia, {Feedback? feedback,}) async {
    var theUrl = Uri.parse(memberMediumModel.url!);
    return _createOtherFromURI(app, memberId, theUrl, includeMedia, feedback: feedback);
  }

  static Future<List<NewAppTask>> _createOtherFromURI(
      AppModel app, String memberId, Uri uri, bool includeMedia, {Feedback? feedback,}) async {
    final response = await http.get(uri);
    var json = String.fromCharCodes(response.bodyBytes);
    return createOtherFromJson(app, memberId, json, includeMedia, feedback: feedback);
  }

  static Future<List<NewAppTask>> createAppFromJson(
      AppModel app, String memberId, String jsonText, {Feedback? feedback,}) async {
    var appId = app.documentID;
    List<NewAppTask> tasks = [];

    Map<String, dynamic>? map = jsonDecode(jsonText);
    if (map != null) {
      var oldAppId = map['app']['documentID'];
      var leftDrawerDocumentId = drawerID(appId, DrawerType.Left);
      var rightDrawerDocumentId = drawerID(appId, DrawerType.Right);
      var homeMenuId = homeMenuID(appId);
      var appBarId = appBarID(appId);
      List<ComponentSpec> createdComponents = [];
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
                await createPageEntity(page, appId, homeMenuId, leftDrawerDocumentId, rightDrawerDocumentId, appBarId, feedback: feedback);
              }
            }
          } else if (key == JsonConsts.dialogs) {
            List<dynamic>? dialogs = entry.value;
            if (dialogs != null) {
              for (var dialog in dialogs) {
                await createDialogEntity(dialog, appId, feedback: feedback);
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
                if (componentId == "pays") {
                  int i = 1;
                }
                print(componentId + " ");
                var values = entry.value;
                var retrieveRepo = Registry.registry()!
                    .getRetrieveRepository(pluginName, componentId);
                if (retrieveRepo != null) {
                  var documentIds = await restoreFromMap(values, retrieveRepo(appId: appId), appId);
                  createdComponents.addAll(documentIds.map((documentId) => ComponentSpec(
                      pluginName,
                      componentId,
                      documentId)).toList());
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
      revalidateComponentModels(app, tasks, createdComponents);
    }

    return tasks;
  }

  static Future<List<NewAppTask>> createOtherFromJson(
      AppModel app, String memberId, String jsonText, bool includeMedia, {Feedback? feedback,}) async {
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
                await createPageEntity(page, appId, homeMenuId, leftDrawerDocumentId, rightDrawerDocumentId, appBarId, feedback: feedback);
              }
            }
          } else if (key == JsonConsts.dialogs) {
            List<dynamic>? dialogs = entry.value;
            if (dialogs != null) {
              for (var dialog in dialogs) {
                dialog['documentID'] = newRandomKey();
                await createDialogEntity(dialog, appId, feedback: feedback);
              }
            }
          }
        });
      }

      List<ComponentSpec> createdComponents = [];
      // components
      for (var entry in map.entries) {
        tasks.add(() async {
          var key = entry.key;
          if (key == JsonConsts.app) {} else
          if (key == DrawerModel.packageName + "-" + DrawerModel.id) {} else
          if (key == AppBarModel.packageName + "-" + AppBarModel.id) {} else
          if (key == HomeMenuModel.packageName + "-" + HomeMenuModel.id) {} else
          if (key == MenuDefModel.packageName + "-" + MenuDefModel.id) {} else
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
                  var documentIds = await restoreFromMap(
                      values, retrieveRepo(appId: appId), appId,
                      newDocumentIds: newDocumentIds, );
                  createdComponents.addAll(documentIds.map((documentId) => ComponentSpec(
                      pluginName,
                      componentId,
                      documentId)).toList());
                } else {
                  print("Can't find repo for: " + key);
                }
              } catch (e) {
                print("Error processing " + key);
              }
            } else {
              print("Don't know how to handle this entry with key: " + key);
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
                      theItem, app, memberId, repository, newDocumentIds: newDocumentIds);
                }
              }
            } else if (key ==
                MemberMediumModel.packageName + "-" + MemberMediumModel.id) {
              var theItems = entry.value;
              if (theItems != null) {
                var repository = memberMediumRepository(appId: appId)!;
                for (var theItem in theItems) {
                  await createMemberMedium(theItem, app, memberId, repository, newDocumentIds: newDocumentIds);
                }
              }
            } else if (key ==
                PublicMediumModel.packageName + "-" + PublicMediumModel.id) {
              var theItems = entry.value;
              if (theItems != null) {
                var repository = publicMediumRepository(appId: appId)!;
                for (var theItem in theItems) {
                  await createPublicMedium(theItem, app, memberId, repository, newDocumentIds: newDocumentIds);
                }
              }
            }
          });
        }
      }

      revalidateComponentModels(app, tasks, createdComponents);
    }

    return tasks;
  }

  static void revalidateComponentModels(AppModel app, List<NewAppTask> tasks, List<ComponentSpec> createdComponents) {
    // now run all revalidateModel to make sure the documents are consistent, e.g. update html links
    tasks.add(() async {
      for (var createdComponent in createdComponents) {
        var componentSpecs = await Registry.registry()!.getComponentSpecs(
            createdComponent.componentId);
        if (componentSpecs == null) {
          print("Exception during retrieval of component " +
              createdComponent.componentId);
        } else {
          var repository = componentSpecs.retrieveRepository(appId: app.documentID);
          var entity = await repository.getEntity(createdComponent.documentId);
          if (entity != null) {
            var newEntity = await componentSpecs.editor.revalidateEntity(
                app, entity);
            await repository.updateEntity(createdComponent.documentId, newEntity);
          } else {
            print("Couldn't find model with id " + createdComponent.documentId + " for componentSpecs with name " + componentSpecs.name);
          }
        }
      }
    });

  }

  static Future<PageEntity> createPageEntity( dynamic page, String appId, String homeMenuId, String leftDrawerDocumentId, String rightDrawerDocumentId, String appBarId, {Feedback? feedback,}) async {
    var documentID = page['documentID'];
    page['appId'] = appId;
    page['homeMenuId'] = homeMenuId;
    page['drawerId'] = leftDrawerDocumentId;
    page['endDrawerId'] = rightDrawerDocumentId;
    page['appBarId'] = appBarId;
    var pageEntity = PageEntity.fromMap(page);
    if (pageEntity != null) {
      var newPageEntity = await pageRepository(appId: appId)!
          .addEntity(documentID, pageEntity);
      if (feedback != null) {
        feedback(JsonConsts.pages, documentID);
      }
      return newPageEntity;
    } else {
      throw Exception('Can not create pageEntity');
    }
  }

  static Future<DialogEntity> createDialogEntity(dynamic dialog, String appId, {Feedback? feedback,}) async {
    var documentID = dialog['documentID'];
    dialog['appId'] = appId;
    var dialogEntity = DialogEntity.fromMap(dialog);
    if (dialogEntity != null) {
      var newDialogEntity = await dialogRepository(appId: appId)!
          .addEntity(documentID, dialogEntity);
      if (feedback != null) {
        feedback(JsonConsts.dialogs, documentID);
      }
      return newDialogEntity;
    } else {
      throw Exception('Can not create dialogEntity');
    }
  }

  static String renameDoc(dynamic theItem, Map<String, String>? newDocumentIds ) {
    var documentID = theItem['documentID'];
    // potentially rename the document
    if (newDocumentIds != null) {
      var newDocumentID = newDocumentIds[documentID];
      if (newDocumentID != null) {
        theItem['documentID'] = newDocumentID;
        return newDocumentID;
      }
    }
    return documentID;
  }

  static Future<void> createPlatformMedium(Map theNewItem, AppModel app, String memberId, RepositoryBase repository, { Map<String, String>? newDocumentIds }) async {
    var oldDocumentId = theNewItem["documentID"];
    renameDoc(theNewItem, newDocumentIds);
    var newDocumentId = theNewItem["documentID"];
    try {
      var platformMedium = repository.fromMap(theNewItem);
      if (platformMedium != null) {
        var helper = PlatformMediumHelper(
            app,
            memberId,
            platformMedium.conditions == null
                ? PrivilegeLevelRequiredSimple
                .NoPrivilegeRequiredSimple
                : toPrivilegeLevelRequiredSimple(platformMedium
                .conditions!.privilegeLevelRequired!));
        var base = platformMedium.base;
        if (base == oldDocumentId) {
          base = newDocumentId;
        }
        await upload(
            repository,
            helper,
            base,
            platformMedium.ext,
            platformMedium.mediumType ?? 0,
            theNewItem,
            platformMedium.relatedMediumId, newDocumentIds: newDocumentIds);
      }
    } catch (e) {
      print("Error whilst creating public medium " + e.toString());
    }
  }

  static Future<void> createMemberMedium(Map theNewItem, AppModel app, String memberId, RepositoryBase repository, { Map<String, String>? newDocumentIds }) async {
    var oldDocumentId = theNewItem["documentID"];
    renameDoc(theNewItem, newDocumentIds);
    var newDocumentId = theNewItem["documentID"];
    try {
      var memberMedium = repository.fromMap(theNewItem);
      if (memberMedium != null) {
        var memberMediumAccessibleByGroup =
        toMemberMediumAccessibleByGroup(
            memberMedium.accessibleByGroup ??
                MemberMediumAccessibleByGroup.Me.index);
        var helper = MemberMediumHelper(
            app, memberId, memberMediumAccessibleByGroup,
            accessibleByMembers: memberMedium.accessibleByMembers);
        var base = memberMedium.base;
        if (base == oldDocumentId) {
          base = newDocumentId;
        }
        await upload(
            repository,
            helper,
            base,
            memberMedium.ext,
            memberMedium.mediumType ?? 0,
            theNewItem,
            memberMedium.relatedMediumId);
      }
    } catch (e) {
      print("Error whilst creating public medium " + e.toString());
    }
  }

  static Future<void> createPublicMedium(Map theNewItem, AppModel app, String memberId, RepositoryBase repository, { Map<String, String>? newDocumentIds }) async {
    var oldDocumentId = theNewItem["documentID"];
    renameDoc(theNewItem, newDocumentIds);
    var newDocumentId = theNewItem["documentID"];
    try {
      var publicMedium = repository.fromMap(theNewItem);
      if (publicMedium != null) {
        var helper = PublicMediumHelper(
          app,
          memberId,
        );
        var base = publicMedium.base;
        if (base == oldDocumentId) {
          base = newDocumentId;
        }
        await upload(
            repository,
            helper,
            base,
            publicMedium.ext,
            publicMedium.mediumType ?? 0,
            theNewItem,
            publicMedium.relatedMediumId);
      }
    } catch (e) {
      print("Error whilst creating public medium " + e.toString());
    }
  }

  static String noNameId = "nonameno-name-nona-meno-namenonameno";

  static Future<T> upload<T>(
      RepositoryBase repository,
      MediumHelper helper,
      String? base,
      String? ext,
      int mediumType,
      dynamic theItem,
      String? relatedMediumId, { Map<String, String>? newDocumentIds }) async {

    if (base == null) base = noNameId;

    if (newDocumentIds != null) {
      var baseId = base.substring(0, 36);
      if (baseId == noNameId) {
        base = newRandomKey();
      } else {
        var newBaseID = newDocumentIds[baseId];
        if (newBaseID != null) {
          base = newBaseID + base.substring(16);
        }
      }
    }

    var baseName = (base ?? 'noname') + "." + (ext ?? '');
    var thumbNailName = (base ?? 'noname') + "-thumb." + (ext ?? '');
    var extractItem = theItem['extract'];
    if (mediumType == 0) {
      var extract = Uint8List.fromList(extractItem.cast<int>());
      // Photo
      return await helper.createThumbnailUploadPhotoData(
          theItem['documentID'], extract, baseName, thumbNailName,
          relatedMediumId: relatedMediumId);
    } else if (mediumType == 1) {
      var extract = Uint8List.fromList(extractItem.cast<int>());
      // Video
      return await helper.createThumbnailUploadVideoData(
        theItem['documentID'],
        extract,
        baseName,
        thumbNailName,
      );
    } else if (mediumType == 2) {
      var extract = Uint8List.fromList(extractItem.cast<int>());
      // Pdf
      return await helper.createThumbnailUploadPhotoData(
          theItem['documentID'], extract, baseName, thumbNailName,
          relatedMediumId: relatedMediumId);
    } else if (mediumType == 3) {
      // Txt
      return await helper.uploadTextData(
        theItem['documentID'],
        extractItem,
        baseName,
      );
    }
    throw Exception("Exception during upload of base $base, ext $ext: mediumType $mediumType not supported");
  }

  static Future<List<String>> restoreFromMap(
    dynamic theItems,
    RepositoryBase repository,
    String appId, {
    PostProcessing? postProcessing,
    Map<String, String>? newDocumentIds,
  }) async {
    List<String> documentIds = [];
    if (theItems != null) {
      for (var theNewItem in theItems) {
        var documentID = renameDoc(theNewItem, newDocumentIds);
        if (postProcessing != null) {
          postProcessing(theNewItem);
        }

        EntityBase entity = repository.fromMap(theNewItem, newDocumentIds: newDocumentIds);
        var newEntity = entity.switchAppId(newAppId: appId);
        await repository.addEntity(documentID, newEntity);
        documentIds.add(documentID);
      }
    }
    return documentIds;
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
