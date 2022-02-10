import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/app_builder.dart';
import 'package:flutter/material.dart';

abstract class NewAppWizardParameters {}

enum MenuType { leftDrawerMenu, rightDrawerMenu, appBarMenu, bottomNavBarMenu }

typedef HomeMenuModel HomeMenuProvider();
typedef AppBarModel AppBarProvider();
typedef DrawerModel DrawerProvider();

abstract class NewAppWizardInfo {
  final String newAppWizardName; // e.g. policy
  final String displayName;

  NewAppWizardInfo(this.newAppWizardName, this.displayName);

  Widget wizardParametersWidget(
      AppModel app, BuildContext context, NewAppWizardParameters parameters);

  /* a new instance of this wizard is initialised, e.g. because we create a new app
   * create the new parameters, allowing to maintain, update, and use during build
   */
  NewAppWizardParameters newAppWizardParameters();

  // create a menu item for a specific menu
  MenuItemModel? getMenuItemFor(
      AppModel app, NewAppWizardParameters parameters, MenuType type);

  // create the tasks for creating the app, i.e. the portion of the app for which this wizard is for
  List<NewAppTask>? getCreateTasks(
    AppModel app,
    NewAppWizardParameters parameters,
    MemberModel member,
    HomeMenuProvider homeMenuProvider,
    AppBarProvider appBarProvider,
    DrawerProvider leftDrawerProvider,
    DrawerProvider rightDrawerProvider,
  );

  // adjust the app
  AppModel updateApp(NewAppWizardParameters parameters, AppModel adjustMe);

  /*
   * Get pageID for a page type.
   *
   * Some pages require to have the page ID which could be provided by another wizard.
   * For example the member MembershipDashboardWizard needs the profilePageId and feedPageId
   * from the FeedWizard. The mechanism to do this is by
   *
   * - the wizard providing the page ID implementing this method and return the page ID for that type.
   *   In the example given the FeedWizard would implement this method for the types profilePageId and feedPageId
   *   The string for these types is a convention.
   *
   * - the wizard requesting that needs to know a page ID for a given page type requests the NewAppWizardRegistry
   *   for the pageID, using it's getPageID method
   *
   * For the page type we use a hard coded string, rather than using a const, to avoid introducing dependencies
   *
   */
   String? getPageID(String pageType);
}

/*
 * Global registry with new app wizards
 */
class NewAppWizardRegistry {
  static NewAppWizardRegistry? _instance;

  NewAppWizardRegistry._internal();

  static NewAppWizardRegistry registry() {
    _instance ??= NewAppWizardRegistry._internal();
    if (_instance == null) {
      throw Exception('Can create NewAppWizardRegistry registry');
    }

    return _instance!;
  }

  List<NewAppWizardInfo> registeredNewAppWizardInfos = [];

  void register(NewAppWizardInfo newAppWizardInfo) {
    registeredNewAppWizardInfos.add(newAppWizardInfo);
  }

  /*
   * See comments NewAppWizardInfo::getPageID
   */
  String? getPageID(String pageType) {
    for (var wizard in registeredNewAppWizardInfos) {
      var pageID = wizard.getPageID(pageType);
      if (pageID != null) return pageID;
    }
    return null;
  }
}
