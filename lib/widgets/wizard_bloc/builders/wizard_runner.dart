import 'package:eliud_core/core/wizards/registry/action_specification.dart';
import 'package:eliud_core/core/wizards/registry/registry.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/access_model.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_core/tools/action/action_model.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:eliud_pkg_create/widgets/utils/random_logo.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/tools/helpers/progress_manager.dart';
import 'package:eliud_pkg_medium/platform/medium_platform.dart';
import 'package:eliud_core/model/app_home_page_references_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/style/_default/default_style_family.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';

import '../../wizard_shared/helpers/menu_helpers.dart';
import '../../wizard_shared/menus/app_bar_builder.dart';
import '../../wizard_shared/menus/home_menu_builder.dart';
import '../../wizard_shared/menus/left_drawer_builder.dart';
import '../../wizard_shared/menus/right_drawer_builder.dart';
import '../wizard_bloc.dart';
import '../wizard_event.dart';


typedef Evaluate = bool Function(ActionSpecification actionSpecification);


class WizardRunner {
  final AppModel app;
  final MemberModel member;
  late String appId;
  late String memberId;

  PublicMediumModel? logo;

  final ActionSpecification signinButton;
  final ActionSpecification signoutButton;

  final Map<String, NewAppWizardParameters> newAppWizardParameters;

  /*
   * See comments NewAppWizardInfo::getPageID
   *
   */
  String? getPageID(String pageType) {
    for (var wizard in NewAppWizardRegistry.registry().registeredNewAppWizardInfos) {
      var newAppWizardName = wizard.newAppWizardName;
      var parameters = newAppWizardParameters[newAppWizardName];
      if (parameters != null) {
        var pageID = wizard.getPageID(parameters, pageType);
        if (pageID != null) return pageID;
      }
    }
    return null;
  }

  /*
   * See comments NewAppWizardInfo::getAction
   *
   */
  ActionModel? getAction(AppModel app, String actionType) {
    for (var wizard in NewAppWizardRegistry.registry().registeredNewAppWizardInfos) {
      var newAppWizardName = wizard.newAppWizardName;
      var parameters = newAppWizardParameters[newAppWizardName];
      if (parameters != null) {
        var action = wizard.getAction(parameters, app, actionType,);
        if (action != null) return action;
      }
    }
    return null;
  }

  WizardRunner(
    this.app,
    this.member, {
    required this.logo,
    required this.signinButton,
    required this.signoutButton,
    required this.newAppWizardParameters,
  }) {
    appId = app.documentID!;
    memberId = member.documentID!;
  }

  var newlyCreatedApp;

  Future<AppModel> create(WizardBloc wizardBloc) async {
    List<NewAppTask> tasks = [];

    // check if no errors, e.g. identifier should not exist
    late LeftDrawerBuilder leftDrawerBuilder;
    late RightDrawerBuilder rightDrawerBuilder;
    late HomeMenuBuilder theHomeMenuBuilder;
    late AppBarBuilder theAppBarBuilder;

    late DrawerModel leftDrawer;
    late DrawerModel rightDrawer;
    late HomeMenuModel theHomeMenu;
    late AppBarModel theAppBar;

    tasks.add(() async {
      print("leftDrawer");
      leftDrawerBuilder = await LeftDrawerBuilder(app,
        logo: logo, );
      leftDrawer = await leftDrawerBuilder.getOrCreate();
    });

    tasks.add(() async {
      print("rightDrawer");
      rightDrawerBuilder = RightDrawerBuilder(app,
      );
      rightDrawer = await rightDrawerBuilder.getOrCreate();
    });

    tasks.add(() async {
      print("HomeMenu");
      theHomeMenuBuilder = HomeMenuBuilder(app,
      );
      theHomeMenu = await theHomeMenuBuilder
          .getOrCreate();
    });

    tasks.add(() async {
      print("AppBar");
      theAppBarBuilder = AppBarBuilder(app,
      );
      theAppBar = await theAppBarBuilder
          .getOrCreate();
    });

    // add the tasks for the extra wizards
    List<MenuItemModel> leftDrawerMenuItems = [];
    List<MenuItemModel> rightDrawerMenuItems = [];
    List<MenuItemModel> homeMenuMenuItems = [];
    List<MenuItemModel> appBarMenuItems = [];
    for (var wizard
        in NewAppWizardRegistry.registry().registeredNewAppWizardInfos) {
      var newAppWizardName = wizard.newAppWizardName;
      var parameters = newAppWizardParameters[newAppWizardName];
      if (parameters != null) {
        var leftDrawerMenuItemsExtra = wizard.getMenuItemsFor(app, parameters, MenuType.leftDrawerMenu);
        var rightDrawerMenuItemsExtra = wizard.getMenuItemsFor(app, parameters, MenuType.rightDrawerMenu);
        var homeMenuMenuItemsExtra = wizard.getMenuItemsFor(app, parameters, MenuType.bottomNavBarMenu);
        var appBarMenuItemsExtra = wizard.getMenuItemsFor(app, parameters, MenuType.appBarMenu);

        if (leftDrawerMenuItemsExtra != null) leftDrawerMenuItems.addAll(leftDrawerMenuItemsExtra);
        if (rightDrawerMenuItemsExtra != null) rightDrawerMenuItems.addAll(rightDrawerMenuItemsExtra);
        if (homeMenuMenuItemsExtra != null) homeMenuMenuItems.addAll(homeMenuMenuItemsExtra);
        if (appBarMenuItemsExtra != null) appBarMenuItems.addAll(appBarMenuItemsExtra);

        var extraTasks = wizard.getCreateTasks(
          app,
          parameters,
          member,
          () => theHomeMenu,
          () => theAppBar,
          () => leftDrawer,
          () => rightDrawer,
          getPageID,
          getAction,
        );
        if (extraTasks != null) {
          tasks.addAll(extraTasks);
        }
      }
    }

    var blockedPageId = getPageID('blockedPageId');
    var newApp = app.copyWith();
    if (blockedPageId != null) {
      if (newApp.homePages != null) {
        newApp = newApp.copyWith(homePages: newApp.homePages!.copyWith(
            homePageBlockedMember: blockedPageId));
      } else {
        newApp = newApp.copyWith(homePages: AppHomePageReferencesModel(
            homePageBlockedMember: blockedPageId));
      }
    }

    var homePageId = getPageID('homePageId');
    if (homePageId != null) {
      if (newApp.homePages != null) {
        newApp = newApp.copyWith(homePages: newApp.homePages!.copyWith(
          homePagePublic: homePageId,
          homePageSubscribedMember: homePageId,
          homePageLevel1Member: homePageId,
          homePageLevel2Member: homePageId,
          homePageOwner: homePageId,
        ));
      } else {
        newApp = newApp.copyWith(homePages: AppHomePageReferencesModel(
            homePageBlockedMember: blockedPageId));
      }
    }
    // app
    tasks.add(() async {
      print("App");
/*
      var newApp = AppModel(
          documentID: appId,
          title: 'New application',
          ownerID: memberId,
          appStatus: AppStatus.Live,
          styleFamily:
              app.styleFamily ?? DefaultStyleFamily.defaultStyleFamilyName,
          styleName: app.styleName ?? DefaultStyle.defaultStyleName,
          email: member.email,
          description: 'Your new application',
          logo: logo,
          autoPrivileged1: app.autoPrivileged1,
          homePages: AppHomePageReferencesModel(
            homePageBlockedMember: blockedPageId ?? homePageId,
            homePagePublic: homePageId,
            homePageSubscribedMember: homePageId,
            homePageLevel1Member: homePageId,
            homePageLevel2Member: homePageId,
            homePageOwner: homePageId,
          ));
*/
      for (var wizard
          in NewAppWizardRegistry.registry().registeredNewAppWizardInfos) {
        var newAppWizardName = wizard.newAppWizardName;
        var parameters = newAppWizardParameters[newAppWizardName];
        if (parameters != null) {
          newApp = wizard.updateApp(parameters, newApp);
        }
      }
      newlyCreatedApp = await appRepository()!.update(newApp);
    });

    tasks.add(() async {
      print("update leftDrawer");
      await leftDrawerBuilder.updateMenuItems(leftDrawerMenuItems);
    });

    tasks.add(() async {
      print("update rightDrawer");
      await rightDrawerBuilder.updateMenuItems(rightDrawerMenuItems);
    });

    tasks.add(() async {
      print("update homeMenu");
      await theHomeMenuBuilder.updateMenuItems(homeMenuMenuItems);
    });

    tasks.add(() async {
      print("update appBar");
      await theAppBarBuilder.updateMenuItems(appBarMenuItems);
    });

    var progressManager = ProgressManager(tasks.length,
        (progress) => wizardBloc.add(WizardProgressed(progress)));

    var currentTask = tasks[0];
    currentTask().then((value) => tasks[1]);

    int i = 0;
    for (var task in tasks) {
      i++;
      try {
        await task();
      } catch (e) {
        print('Exception running task ' +
            i.toString() +
            ', error: ' +
            e.toString());
      }
      progressManager.progressedNextStep();
      if (wizardBloc.state is WizardCancelled)
        throw Exception("Process cancelled");
    }

    if (newlyCreatedApp != null) {
      wizardBloc.add(WizardSwitchAppEvent());
      return newlyCreatedApp;
    } else {
      throw Exception("no app created");
    }
  }

  List<MenuItemModel> getMenuItemsFor(MenuType type) {
    Evaluate evaluate;
    switch (type) {
      case MenuType.leftDrawerMenu:
        evaluate = (value) => value.availableInLeftDrawer;
        break;
      case MenuType.rightDrawerMenu:
        evaluate = (value) => value.availableInRightDrawer;
        break;
      case MenuType.appBarMenu:
        evaluate = (value) => value.availableInAppBar;
        break;
      case MenuType.bottomNavBarMenu:
        evaluate = (value) => value.availableInHomeMenu;
        break;
    }

    var _signout = evaluate(signoutButton);
    var _signin = evaluate(signinButton);

    List<MenuItemModel> oldMenuItems = [
      if (_signout) menuItemSignOut(app),
      if (_signin) menuItemSignIn(app),
    ];

    List<MenuItemModel> newMenuItems = [];
    for (var wizard
        in NewAppWizardRegistry.registry().registeredNewAppWizardInfos) {
      var newAppWizardName = wizard.newAppWizardName;
      var newAppWizardParam = newAppWizardParameters[newAppWizardName];
      if (newAppWizardParam != null) {
        var menuItems = wizard.getMenuItemsFor(app, newAppWizardParam, type);
        if (menuItems != null) {
          newMenuItems.addAll(menuItems);
        }
      }
    }
    var mergedMenuItems = oldMenuItems;
    mergedMenuItems.addAll(newMenuItems);
    return mergedMenuItems;
  }

  // Start the installation by claiming ownership of the app.
  // Otherwise you won't be able to add data, given security depends on the ownerId of the app being allowed to add data to app's entities
  // We do this twice: the first time before wiping the data. This is to assure that we can wipe
  // The second time because the wipe has deleted the entry
  // This process works except when the app was create by someone else before. In which case you must delete the app through console.firebase.google.com or by logging in as the owner of the app
  Future<AppModel> claimOwnerShipApplication(
      String appId, String ownerID) async {
    // add the app
    var application = AppModel(
      appStatus: AppStatus.Offline,
      documentID: appId,
      ownerID: ownerID,
    );
    return await AbstractMainRepositorySingleton.singleton
        .appRepository()!
        .add(application);
  }

  Future<AccessModel> claimAccess(String appId, String ownerID) async {
    return await accessRepository(appId: appId)!.add(AccessModel(
        documentID: ownerID,
        privilegeLevel: PrivilegeLevel.OwnerPrivilege,
        points: 0));
  }
}
