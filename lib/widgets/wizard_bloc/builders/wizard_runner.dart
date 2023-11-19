import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/wizards/registry/action_specification.dart';
import 'package:eliud_core/core/wizards/registry/registry.dart';
import 'package:eliud_core/core/wizards/tools/document_identifier.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/tools/helpers/progress_manager.dart';
import 'package:eliud_core/model/app_home_page_references_model.dart';
import 'package:eliud_core_model/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core_model/tools/etc/random.dart';
import '../../wizard_shared/menus/app_bar_builder.dart';
import '../../wizard_shared/menus/home_menu_builder.dart';
import '../../wizard_shared/menus/left_drawer_builder.dart';
import '../../wizard_shared/menus/right_drawer_builder.dart';
import '../wizard_bloc.dart';
import '../wizard_event.dart';

typedef Evaluate = bool Function(ActionSpecification actionSpecification);

class WizardRunner {
  final String uniqueId = newRandomKey();
  final AppModel app;
  final MemberModel member;
  late String appId;
  late String memberId;

  final String? styleFamily;
  final String? styleName;

  final Map<String, NewAppWizardParameters> newAppWizardParameters;
  final bool autoPrivileged1;

  final AccessBloc accessBloc;

  /*
   * See comments NewAppWizardInfo::getPageID
   *
   */
  String? getPageID(String pageType) {
    for (var wizard
        in NewAppWizardRegistry.registry().registeredNewAppWizardInfos) {
      var newAppWizardName = wizard.newAppWizardName;
      var parameters = newAppWizardParameters[newAppWizardName];
      if (parameters != null) {
        var pageID = wizard.getPageID(uniqueId, parameters, pageType);
        if (pageID != null) return pageID;
      }
    }
    return null;
  }

  /*
   * See comments NewAppWizardInfo::getImage
   *
   */
  PublicMediumModel? getPublicMediumModel(
      AppModel app, String publicMediumModelType) {
    for (var wizard
        in NewAppWizardRegistry.registry().registeredNewAppWizardInfos) {
      var newAppWizardName = wizard.newAppWizardName;
      var parameters = newAppWizardParameters[newAppWizardName];
      if (parameters != null) {
        var image = wizard.getPublicMediumModel(
          uniqueId,
          parameters,
          publicMediumModelType,
        );
        if (image != null) return image;
      }
    }
    return null;
  }

  WizardRunner(
    this.app,
    this.member, {
    required this.newAppWizardParameters,
    required this.autoPrivileged1,
    required this.styleFamily,
    required this.styleName,
    required this.accessBloc,
  }) {
    appId = app.documentID;
    memberId = member.documentID;
  }

  Future<void> create(
    AccessBloc accessBloc,
    WizardBloc wizardBloc,
  ) async {
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

    var logo = getPublicMediumModel(app, 'logo');

    tasks.add(() async {
      print("leftDrawer");
      leftDrawerBuilder = LeftDrawerBuilder(
        app,
        logo: logo,
      );
      leftDrawer = await leftDrawerBuilder.getOrCreate();
    });

    tasks.add(() async {
      print("rightDrawer");
      rightDrawerBuilder = RightDrawerBuilder(
        app,
      );
      rightDrawer = await rightDrawerBuilder.getOrCreate();
    });

    tasks.add(() async {
      print("HomeMenu");
      theHomeMenuBuilder = HomeMenuBuilder(
        app,
      );
      theHomeMenu = await theHomeMenuBuilder.getOrCreate();
    });

    tasks.add(() async {
      print("AppBar");
      theAppBarBuilder = AppBarBuilder(
        app,
      );
      theAppBar = await theAppBarBuilder.getOrCreate();
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
        var leftDrawerMenuItemsExtra = wizard.getMenuItemsFor(
            uniqueId, app, parameters, MenuType.leftDrawerMenu);
        var rightDrawerMenuItemsExtra = wizard.getMenuItemsFor(
            uniqueId, app, parameters, MenuType.rightDrawerMenu);
        var homeMenuMenuItemsExtra = wizard.getMenuItemsFor(
            uniqueId, app, parameters, MenuType.bottomNavBarMenu);
        var appBarMenuItemsExtra = wizard.getMenuItemsFor(
            uniqueId, app, parameters, MenuType.appBarMenu);

        if (leftDrawerMenuItemsExtra != null) {
          leftDrawerMenuItems.addAll(leftDrawerMenuItemsExtra);
        }
        if (rightDrawerMenuItemsExtra != null) {
          rightDrawerMenuItems.addAll(rightDrawerMenuItemsExtra);
        }
        if (homeMenuMenuItemsExtra != null) {
          homeMenuMenuItems.addAll(homeMenuMenuItemsExtra);
        }
        if (appBarMenuItemsExtra != null) {
          appBarMenuItems.addAll(appBarMenuItemsExtra);
        }

        var extraTasks = wizard.getCreateTasks(
          uniqueId,
          app,
          parameters,
          member,
          () => theHomeMenu,
          () => theAppBar,
          () => leftDrawer,
          () => rightDrawer,
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
        newApp = newApp.copyWith(
            homePages: newApp.homePages!.copyWith(
                homePageBlockedMember: constructDocumentId(
                    uniqueId: uniqueId, documentId: blockedPageId)));
      } else {
        newApp = newApp.copyWith(
            homePages: AppHomePageReferencesModel(
                homePageBlockedMember: constructDocumentId(
                    uniqueId: uniqueId, documentId: blockedPageId)));
      }
    }

    var homePageId = getPageID('homePageId');
    if (homePageId != null) {
      if (newApp.homePages != null) {
        newApp = newApp.copyWith(
            homePages: newApp.homePages!.copyWith(
          homePagePublic:
              constructDocumentId(uniqueId: uniqueId, documentId: homePageId),
          homePageSubscribedMember:
              constructDocumentId(uniqueId: uniqueId, documentId: homePageId),
          homePageLevel1Member:
              constructDocumentId(uniqueId: uniqueId, documentId: homePageId),
          homePageLevel2Member:
              constructDocumentId(uniqueId: uniqueId, documentId: homePageId),
          homePageOwner:
              constructDocumentId(uniqueId: uniqueId, documentId: homePageId),
        ));
      } else {
        newApp = newApp.copyWith(
            homePages: AppHomePageReferencesModel(
                homePageBlockedMember: blockedPageId == null
                    ? null
                    : constructDocumentId(
                        uniqueId: uniqueId, documentId: blockedPageId)));
      }
    }

    tasks.add(() async {
      print("App");
      for (var wizard
          in NewAppWizardRegistry.registry().registeredNewAppWizardInfos) {
        var newAppWizardName = wizard.newAppWizardName;
        var parameters = newAppWizardParameters[newAppWizardName];
        if (parameters != null) {
          newApp = wizard.updateApp(uniqueId, parameters, newApp);
        }
      }
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

    tasks.add(() async {
      print("App");
      newApp = newApp.copyWith(autoPrivileged1: autoPrivileged1);
      if (logo != null) {
        newApp = newApp.copyWith(logo: logo);
      }
      //newlyCreatedApp = await appRepository()!.update(newApp);
    });

    // Now run all tasks
    var progressManager = ProgressManager(
        tasks.length, (progress) => wizardBloc.add(WizardProgressed(progress)));

    int i = 0;
    for (var task in tasks) {
      i++;
      try {
        await task();
      } catch (e) {
        print('Exception running task $i, error: $e');
      }
      progressManager.progressedNextStep();
      if (wizardBloc.state is WizardCancelled) {
        throw Exception("Process cancelled");
      }
    }
  }

  List<MenuItemModel> getMenuItemsFor(MenuType type) {
/*
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
*/

    List<MenuItemModel> newMenuItems = [];
    for (var wizard
        in NewAppWizardRegistry.registry().registeredNewAppWizardInfos) {
      var newAppWizardName = wizard.newAppWizardName;
      var newAppWizardParam = newAppWizardParameters[newAppWizardName];
      if (newAppWizardParam != null) {
        var menuItems =
            wizard.getMenuItemsFor(uniqueId, app, newAppWizardParam, type);
        if (menuItems != null) {
          newMenuItems.addAll(menuItems);
        }
      }
    }
    return newMenuItems;
  }
}
