import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_pkg_create/registry/registry.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/app_builder.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/helpers/menu_helpers.dart';
import 'package:eliud_pkg_create/widgets/new_app_widget.dart';
import 'package:eliud_pkg_medium/platform/medium_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

abstract class NewAppWizardInfoWithActionSpecification extends NewAppWizardInfo {
  final String wizardWidgetLabel;

  NewAppWizardInfoWithActionSpecification(String newAppWizardName, String displayName, this.wizardWidgetLabel) : super(newAppWizardName, displayName);

  @override
  MenuItemModel? getMenuItemFor(AppModel app, NewAppWizardParameters parameters, MenuType type) {
    if (parameters is ActionSpecificationParametersBase) {
      var feedSpecifications = parameters.actionSpecifications;
      bool generate = (type == MenuType.leftDrawerMenu) && feedSpecifications.availableInLeftDrawer ||
          (type == MenuType.rightDrawerMenu) && feedSpecifications.availableInRightDrawer ||
          (type == MenuType.bottomNavBarMenu) && feedSpecifications.availableInHomeMenu ||
          (type == MenuType.appBarMenu) && feedSpecifications.availableInAppBar;
      if (generate) {
        return getThatMenuItem(app);
      }
    } else {
      throw Exception('Unexpected class for parameters: ' + parameters.toString());
    }
    return null;
  }

  MenuItemModel getThatMenuItem(AppModel app);

  @override
  Widget wizardParametersWidget(AppModel app, BuildContext context, NewAppWizardParameters parameters) {
    if (parameters is ActionSpecificationParametersBase) {
      return ActionSpecificationWidget(
          app: app,
          enabled: true,
          actionSpecification: parameters.actionSpecifications,
          label: wizardWidgetLabel);
    } else {
      return text(app, context, 'Unexpected class for parameters: ' + parameters.toString());
    }
  }

  @override
  AppModel updateApp(NewAppWizardParameters parameters, AppModel adjustMe, ) => adjustMe;

  @override
  String? getPageID(String pageType) => null;
}
