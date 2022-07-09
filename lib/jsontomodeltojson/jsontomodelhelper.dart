import 'dart:convert';
import 'dart:typed_data';
import 'package:eliud_core/core/base/entity_base.dart';
import 'package:eliud_core/core/base/model_base.dart';
import 'package:eliud_core/core/base/repository_base.dart';
import 'package:eliud_core/core/registry.dart';
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
import 'package:eliud_core/model/storage_conditions_model.dart';
import 'package:eliud_core/tools/component/component_spec.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import 'package:eliud_core/tools/storage/medium_helper.dart';
import 'package:eliud_core/tools/storage/member_medium_helper.dart';
import 'package:eliud_core/tools/storage/platform_medium_helper.dart';
import 'package:eliud_core/tools/storage/public_medium_helper.dart';
import '../widgets/bodycomponents/bodycomponents__bloc/bodycomponents_create_state.dart';
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

  static Future<List<NewAppTask>> createAppFromJson(
      AppModel app, String memberId, String jsonText) async {
    var appId = app.documentID;
    List<NewAppTask> tasks = [];

    Map<String, dynamic>? map = jsonDecode(jsonText);

/*
    tasks.add(() async {
      if (map != null) {
        var fullName = AppBarModel.packageName + "-" + AppBarModel.id;
        var theItems = map![fullName];
        if (theItems != null) {
          restoreFromMap(theItems, appBarRepository(appId: appId)!, appId);
        }
      }
    });

    tasks.add(() async {
      if (map != null) {
        var fullName = DrawerModel.packageName + "-" + DrawerModel.id;
        var theItems = map![fullName];
        if (theItems != null) {
          restoreFromMap(theItems, drawerRepository(appId: appId)!, appId);
        }
      }
    });

    tasks.add(() async {
      if (map != null) {
        var fullName = HomeMenuModel.packageName + "-" + HomeMenuModel.id;
        var theItems = map![fullName];
        if (theItems != null) {
          restoreFromMap(theItems, homeMenuRepository(appId: appId)!, appId);
        }
      }
    });

    tasks.add(() async {
      if (map != null) {
        var repository = publicMediumRepository(appId: appId)!;
        var fullName =
            PublicMediumModel.packageName + "-" + PublicMediumModel.id;
        var theItems = map![fullName];
        if (theItems != null) {
          for (var theItem in theItems) {
            var publicMedium = repository.fromMap(theItem);
            if (publicMedium != null) {
              var helper = PublicMediumHelper(
                app,
                memberId,
              );
              await upload(repository, helper, publicMedium.base,
                  publicMedium.ext, publicMedium.mediumType ?? 0, theItem);
            }
          }
        }
      }
    });

    tasks.add(() async {
      if (map != null) {
        var repository = memberMediumRepository(appId: appId)!;
        var fullName =
            MemberMediumModel.packageName + "-" + MemberMediumModel.id;
        var theItems = map![fullName];
        if (theItems != null) {
          for (var theItem in theItems) {
            var memberMedium = repository.fromMap(theItem);
            if (memberMedium != null) {
              var memberMediumAccessibleByGroup =
                  toMemberMediumAccessibleByGroup(
                      memberMedium.accessibleByGroup ??
                          MemberMediumAccessibleByGroup.Me.index);
              var helper = MemberMediumHelper(
                  app, memberId, memberMediumAccessibleByGroup,
                  accessibleByMembers: memberMedium.accessibleByMembers);
              await upload(repository, helper, memberMedium.base,
                  memberMedium.ext, memberMedium.mediumType ?? 0, theItem);
            }
          }
        }
      }
    });

    tasks.add(() async {
      if (map != null) {
        var repository = platformMediumRepository(appId: appId)!;
        var fullName =
            PlatformMediumModel.packageName + "-" + PlatformMediumModel.id;
        var theItems = map![fullName];
        if (theItems != null) {
          for (var theItem in theItems) {
            var platformMedium = repository.fromMap(theItem);
            if (platformMedium != null) {
              var helper = PlatformMediumHelper(
                  app,
                  memberId,
                  platformMedium.conditions == null
                      ? PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple
                      : toPrivilegeLevelRequiredSimple(
                          platformMedium.conditions!.privilegeLevelRequired!));
              await upload(repository, helper, platformMedium.base,
                  platformMedium.ext, platformMedium.mediumType ?? 0, theItem);
            }
          }
        }
      }
    });

    tasks.add(() async {
      if (map != null) {
        var fullName = MenuDefModel.packageName + "-" + MenuDefModel.id;
        var theItems = map![fullName];
        if (theItems != null) {
          restoreFromMap(theItems, menuDefRepository(appId: appId)!, appId,
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
*/

    if (map != null) {
      for (var entry in map.entries) {
        tasks.add(() async {
          var key = entry.key;
          if (key == JsonConsts.app) {
            var appMap = entry.value;
            appMap['ownerId'] = memberId;
            var appEntity = AppEntity.fromMap(appMap);
            if (appEntity != null) {
              await appRepository()!.updateEntity(appId, appEntity);
            }
          } else if (key == JsonConsts.pages) {
            List<dynamic>? pages = entry.value;
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
          } else if (key == JsonConsts.dialogs) {
            List<dynamic>? dialogs = entry.value;
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
          } else if (key == MenuDefModel.packageName + "-" + MenuDefModel.id) {
            var theItems = entry.value;
            if (theItems != null) {
              restoreFromMap(theItems, menuDefRepository(appId: appId)!, appId,
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
          } else if (key == PlatformMediumModel.packageName + "-" + PlatformMediumModel.id) {
            var theItems = entry.value;
            if (theItems != null) {
              var repository = platformMediumRepository(appId: appId)!;
              for (var theItem in theItems) {
                var platformMedium = repository.fromMap(theItem);
                if (platformMedium != null) {
                  var helper = PlatformMediumHelper(
                      app,
                      memberId,
                      platformMedium.conditions == null
                          ? PrivilegeLevelRequiredSimple
                          .NoPrivilegeRequiredSimple
                          : toPrivilegeLevelRequiredSimple(
                          platformMedium.conditions!.privilegeLevelRequired!));
                  await upload(repository, helper, platformMedium.base,
                      platformMedium.ext, platformMedium.mediumType ?? 0,
                      theItem);
                }
              }
            }
          } else if (key == MemberMediumModel.packageName + "-" + MemberMediumModel.id) {
            var theItems = entry.value;
            if (theItems != null) {
              var repository = memberMediumRepository(appId: appId)!;
              for (var theItem in theItems) {
                var memberMedium = repository.fromMap(theItem);
                if (memberMedium != null) {
                  var memberMediumAccessibleByGroup =
                  toMemberMediumAccessibleByGroup(
                      memberMedium.accessibleByGroup ??
                          MemberMediumAccessibleByGroup.Me.index);
                  var helper = MemberMediumHelper(
                      app, memberId, memberMediumAccessibleByGroup,
                      accessibleByMembers: memberMedium.accessibleByMembers);
                  await upload(repository, helper, memberMedium.base,
                      memberMedium.ext, memberMedium.mediumType ?? 0, theItem);
                }
              }
            }
          } else if (key == PublicMediumModel.packageName + "-" + PublicMediumModel.id) {
            var theItems = entry.value;
            if (theItems != null) {
              var repository = publicMediumRepository(appId: appId)!;
              for (var theItem in theItems) {
                var publicMedium = repository.fromMap(theItem);
                if (publicMedium != null) {
                  var helper = PublicMediumHelper(
                    app,
                    memberId,
                  );
                  await upload(repository, helper, publicMedium.base,
                      publicMedium.ext, publicMedium.mediumType ?? 0, theItem);
                }
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
                  restoreFromMap(values, retrieveRepo(appId: appId), appId);
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

  static Future<void> upload(RepositoryBase repository, MediumHelper helper,
      String? base, String? ext, int mediumType, dynamic theItem) async {
    var baseName = (base ?? 'noname') + "." + (ext ?? '');
    var thumbNailName = (base ?? 'noname') + "-thumb." + (ext ?? '');
    var extractItem = theItem['extract'];
    if (mediumType == 0) {
      var extract = Uint8List.fromList(extractItem.cast<int>());
      // Photo
      await helper.createThumbnailUploadPhotoData(
          theItem['documentID'], extract, baseName, thumbNailName);
    } else if (mediumType == 1) {
      var extract = Uint8List.fromList(extractItem.cast<int>());
      // Video
      await helper.createThumbnailUploadVideoData(
          theItem['documentID'], extract, baseName, thumbNailName);
    } else if (mediumType == 2) {
      var extract = Uint8List.fromList(extractItem.cast<int>());
      // Pdf
      await helper.createThumbnailUploadPhotoData(
          theItem['documentID'], extract, baseName, thumbNailName);
    } else if (mediumType == 3) {
      // Txt
      await helper.uploadTextData(theItem['documentID'], extractItem, baseName);
    }
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
