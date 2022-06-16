import 'package:eliud_core/core/base/model_base.dart';
import 'package:eliud_core/core/base/repository_base.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_pkg_create/widgets/utils/models_json_bloc/models_json_bloc.dart';
import 'package:eliud_pkg_create/widgets/utils/models_json_bloc/models_json_event.dart';
import 'package:eliud_core/model/app_model.dart';

import '../widgets/bodycomponents/bodycomponents__bloc/bodycomponents_create_state.dart';
import 'jsonconst.dart';

class ModelsToJsonHelper {
  static Future<List<ModelsJsonTask>> getTasksForApp(AppModel appModel,
      AppBarModel appBarModel,
      HomeMenuModel homeMenuModel,
      DrawerModel leftDrawerModel,
      DrawerModel rightDrawerModel,
      List<DialogModel> dialogs,
      List<PageModel> pages,
      List<AbstractModelWithInformation> container) async {
    List<ModelsJsonTask> tasks = [];

    List<MenuDefModel> menuDefModels = [];

    var pluginsWithComponents;
    tasks.add(() async {
      container.add(ModelWithInformation(JsonConsts.app, appModel));
    });
    tasks.add(() async {
      container.add(ModelWithInformation(JsonConsts.appBar, appBarModel));
      if (appBarModel.iconMenu != null) {
        menuDefModels.add(appBarModel.iconMenu!);
      }
    });
    tasks.add(() async {
      container.add(ModelWithInformation(JsonConsts.homeMenu, homeMenuModel));
      if (homeMenuModel.menu != null) {
        menuDefModels.add(homeMenuModel.menu!);
      }
    });
    tasks.add(() async {
      container.add(ModelWithInformation(JsonConsts.leftDrawer, leftDrawerModel));
      if (leftDrawerModel.menu != null) {
        menuDefModels.add(leftDrawerModel.menu!);
      }
    });
    tasks.add(() async {
      container.add(ModelWithInformation(JsonConsts.rightDrawer, rightDrawerModel));
      if (rightDrawerModel.menu != null) {
        menuDefModels.add(rightDrawerModel.menu!);
      }
    });

    tasks.add(() async {
      container.add(ModelsWithInformation(JsonConsts.menuDef, menuDefModels));
    });
    tasks.add(() async {
      container.add(ModelDocumentIDsWithInformation(dialogRepository(appId: appModel.documentID)!, JsonConsts.dialogs, dialogs.map((e) => e.documentID).toList()));
    });
    tasks.add(() async {
      container.add(ModelDocumentIDsWithInformation(pageRepository(appId: appModel.documentID)!, JsonConsts.pages, pages.map((e) => e.documentID).toList()));
    });
    pluginsWithComponents = await retrievePluginsWithComponents();
    for (var pluginsWithComponent in pluginsWithComponents) {
      var pluginName = pluginsWithComponent.name;
      for (var componentSpec in pluginsWithComponent.componentSpec) {
        var repository = componentSpec.retrieveRepository(
            appId: appModel.documentID) as RepositoryBase<ModelBase>;

        tasks.add(() async {
          var allValues = <ModelBase>[];
          var countDown = 3;
          while (countDown >= 0) {
            var values = await repository.valuesList(privilegeLevel: countDown);
            allValues.addAll(values.map((e) => e!).toList());
            countDown--;
          }

          if (allValues.isNotEmpty) {
            var componentName = componentSpec.name;
            var fullName = pluginName + "-" + componentName;
            container.add(ModelDocumentIDsWithInformation(repository, fullName, allValues.map((e) => e.documentID).toList()));
          }
        });
      }
    }
    return tasks;
  }
}