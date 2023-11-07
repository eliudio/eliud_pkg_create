import 'package:eliud_core/core/base/entity_base.dart';
import 'package:eliud_core/core/base/model_base.dart';
import 'package:eliud_core/core/base/repository_base.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_pkg_create/widgets/utils/models_json_bloc/models_json_bloc.dart';
import 'package:eliud_pkg_create/widgets/utils/models_json_bloc/models_json_event.dart';
import 'package:eliud_core/model/app_model.dart';

import '../widgets/bodycomponents/bodycomponents__bloc/bodycomponents_create_state.dart';
import 'jsonconst.dart';

class ModelsToJsonHelper {
  static Future<List<ModelsJsonTask>> getTasksForApp(
      AppModel appModel,
      AppBarModel appBarModel,
      HomeMenuModel homeMenuModel,
      DrawerModel leftDrawerModel,
      DrawerModel rightDrawerModel,
      List<DialogModel> dialogs,
      List<PageModel> pages,
      List<AbstractModelWithInformation> container) async {
    List<ModelsJsonTask> tasks = [];

    //Set<MenuDefModel> menuDefModels = <MenuDefModel>{};

    List<PluginWithComponents> pluginsWithComponents;
    tasks.add(() async {
      container.add(ModelWithInformation(JsonConsts.app, appModel));
    });

    tasks.add(() async {
      container.add(ModelDocumentIDsWithInformation(
          dialogRepository(appId: appModel.documentID)!,
          JsonConsts.dialogs,
          dialogs.map((e) => e.documentID).toList()));
    });
    tasks.add(() async {
      container.add(ModelDocumentIDsWithInformation(
          pageRepository(appId: appModel.documentID)!,
          JsonConsts.pages,
          pages.map((e) => e.documentID).toList()));
    });

    // add all instances of all plugins
    pluginsWithComponents = retrievePluginsWithComponents();
    for (var pluginsWithComponent in pluginsWithComponents) {
      var pluginName = pluginsWithComponent.name;
      for (var componentSpec in pluginsWithComponent.componentSpec) {
        var repository =
            componentSpec.retrieveRepository(appId: appModel.documentID)
                as RepositoryBase<ModelBase, EntityBase>;

        tasks.add(() async {
          print("Dumping ${componentSpec.name}");
          var allValues = <ModelBase>[];
          var countDown = 3;
          while (countDown >= 0) {
            var values = await repository.valuesList(privilegeLevel: countDown);
            allValues.addAll(values.map((e) => e!).toList());
            countDown--;
          }

          if (allValues.isNotEmpty) {
            var componentName = componentSpec.name;
            var fullName = "$pluginName-$componentName";
            container.add(ModelDocumentIDsWithInformation(repository, fullName,
                allValues.map((e) => e.documentID).toList()));
          }
        });
      }
    }
    return tasks;
  }

  static Future<List<ModelsJsonTask>> getTasksForPage(String appId,
      PageModel page, List<AbstractModelWithInformation> container) async {
    List<ModelsJsonTask> tasks = [];

    tasks.add(() async {
      container.add(ModelDocumentIDsWithInformation(
          pageRepository(appId: appId)!, JsonConsts.pages, [page.documentID]));
//      container.add(ModelDocumentIDsWithInformation(JsonConsts.pages, page));
    });

    // add all instances of all plugins used by this page
    var pluginsWithComponents = retrievePluginsWithComponents();
    for (var pluginsWithComponent in pluginsWithComponents) {
      var pluginName = pluginsWithComponent.name;
      for (var componentSpec in pluginsWithComponent.componentSpec) {
        if (page.bodyComponents != null) {
          for (var bodyComponent in page.bodyComponents!) {
            var componentName = componentSpec.name;
            if (componentName == bodyComponent.componentName) {
              tasks.add(() async {
                var repository = componentSpec.retrieveRepository(appId: appId)
                    as RepositoryBase<ModelBase, EntityBase>;
                var value = await repository.get(bodyComponent.componentId);
                if (value != null) {
                  var componentName = componentSpec.name;
                  var fullName = "$pluginName-$componentName";
                  container.add(ModelDocumentIDsWithInformation(
                      repository, fullName, [bodyComponent.componentId!]));

/*
                  var fullName = pluginName + "-" + componentName;
                  container.add(ModelWithInformation(fullName, value));
*/
                }
              });
            }
          }
        }
      }
    }
    return tasks;
  }
}
