import 'package:eliud_core/model/abstract_repository_singleton.dart'
    as corerepo;
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/app_policy_model.dart';
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/model/platform_medium_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/model/storage_conditions_model.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_pkg_create/registry/registry.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/action_specification.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/app_builder.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/helpers/menu_helpers.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/page/page_builder.dart';
import 'package:eliud_pkg_create/widgets/new_app_widget.dart';
import 'package:eliud_pkg_etc/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_etc/model/policy_presentation_component.dart';
import 'package:eliud_pkg_etc/model/policy_presentation_model.dart';
import 'package:eliud_pkg_medium/platform/medium_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'builders/policy/app_policy_builder.dart';
import 'builders/policy/policy_medium_builder.dart';
import 'builders/policy_page_builder.dart';

class NewPolicyWizard extends NewAppWizardInfo {
  static String POLICY_PAGE_ID = 'policy';

  NewPolicyWizard() : super('policy', 'App policy');

  @override
  NewAppWizardParameters newAppWizardParameters() {
    return NewPolicyParameters();
  }

  @override
  MenuItemModel? getMenuItemFor(AppModel app, NewAppWizardParameters parameters, MenuType type) {
    if (parameters is NewPolicyParameters) {
      var examplePolicySpecifications = parameters.examplePolicySpecifications;
      bool generate = (type == MenuType.leftDrawerMenu) && examplePolicySpecifications.availableInLeftDrawer ||
          (type == MenuType.rightDrawerMenu) && examplePolicySpecifications.availableInRightDrawer ||
          (type == MenuType.bottomNavBarMenu) && examplePolicySpecifications.availableInHomeMenu ||
          (type == MenuType.appBarMenu) && examplePolicySpecifications.availableInAppBar;
      if (generate) {
        return menuItem(app, POLICY_PAGE_ID, 'Policy', Icons.rule);
      }
    } else {
      throw Exception('Unexpected class for parameters: ' + parameters.toString());
    }
    return null;
  }

  @override
  Widget wizardParametersWidget(AppModel app, BuildContext context, NewAppWizardParameters parameters) {
    if (parameters is NewPolicyParameters) {
      bool hasAccessToLocalFileSystem = AbstractMediumPlatform.platform!
          .hasAccessToLocalFilesystem();
      return ActionSpecificationWidget(
          app: app,
          enabled: hasAccessToLocalFileSystem,
          actionSpecification: parameters.examplePolicySpecifications,
          label: 'Generate Example Policy');
    } else {
      return text(app, context, 'Unexpected class for parameters: ' + parameters.toString());
    }
  }

  List<NewAppTask>? getCreateTasks(
      AppModel app,
      NewAppWizardParameters parameters,
      String memberId,
      HomeMenuProvider homeMenuProvider,
      AppBarProvider appBarProvider,
      DrawerProvider leftDrawerProvider,
      DrawerProvider rightDrawerProvider,
      ) {
    if (parameters is NewPolicyParameters) {
      var policySpecifications = parameters.examplePolicySpecifications;
      var appId = app.documentID!;
      if (policySpecifications.shouldCreatePageDialogOrWorkflow()) {
        List<NewAppTask> tasks = [];
        late PublicMediumModel policyMedium;
        late AppPolicyModel policyModel;
        // policy medium
        tasks.add(() async {
          print("Policy Medium");
          policyMedium = await PolicyMediumBuilder((value) => {}, app, memberId).create();
        });

        // policy
        tasks.add(() async {
          policyModel = await AppPolicyBuilder(appId, memberId, policyMedium).create();
          parameters.registerTheAppPolicy(policyModel);
        });

        // policy page
        tasks.add(() async {
          print("Policy Page");
          await PolicyPageBuilder(
              POLICY_PAGE_ID,
              app,
              memberId,
              homeMenuProvider(),
              appBarProvider(),
              leftDrawerProvider(),
              rightDrawerProvider(),
              policyMedium,
              'Policy')
              .create();
        });
        return tasks;
      }
    } else {
      throw Exception('Unexpected class for parameters: ' + parameters.toString());
    }
  }

  @override
  AppModel updateApp(NewAppWizardParameters parameters, AppModel adjustMe, ) {
    if (parameters is NewPolicyParameters) {
      adjustMe.policies = parameters.appPolicyModel;
      return adjustMe;
    } else {
      throw Exception('Unexpected class for parameters: ' + parameters.toString());
    }
  }
}

class NewPolicyParameters extends NewAppWizardParameters {
  static bool hasAccessToLocalFileSystem = AbstractMediumPlatform.platform!.hasAccessToLocalFilesystem();

  late  ActionSpecification examplePolicySpecifications;
  late AppPolicyModel? appPolicyModel;

  NewPolicyParameters() {
    examplePolicySpecifications = ActionSpecification(
    requiresAccessToLocalFileSystem: false,
    availableInLeftDrawer: hasAccessToLocalFileSystem,
    availableInRightDrawer: false,
    availableInAppBar: false,
    availableInHomeMenu: false,
    available: false,
    );
  }

  void registerTheAppPolicy(AppPolicyModel theAppPolicyModel) {
    appPolicyModel = theAppPolicyModel;
  }

}