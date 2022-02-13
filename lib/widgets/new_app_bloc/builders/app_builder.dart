import 'package:eliud_core/core/wizards/registry/action_specification.dart';
import 'package:eliud_core/core/wizards/registry/registry.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/access_model.dart';
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

import 'helpers/menu_helpers.dart';
import 'workflow_builder.dart';
import 'app_bar_builder.dart';
import 'home_menu_builder.dart';
import 'left_drawer_builder.dart';
import 'right_drawer_builder.dart';

import '../new_app_bloc.dart';
import '../new_app_event.dart';
import '../new_app_state.dart';

typedef Evaluate = bool Function(ActionSpecification actionSpecification);


class AppBuilder {
  static String MANUALLY_PAY_MEMBERSHIP_WORKFLOW_ID =
      'manually_paid_membership_workflow';
  static String MEMBERSHIP_PAID_BY_CARD_WORKFLOW_ID =
      'membership_paid_by_card_workflow';
  static String MANUAL_PAYMENT_CART_WORKFLOW_ID =
      'manual_payment_cart_workflow';
  static String CREDITCARD_PAYMENT_CART_WORKFLOW_ID =
      'creditcard_payment_cart_workflow';

  final AppModel app;
  final MemberModel member;
  late String appId;
  late String memberId;

  PublicMediumModel? logo;

  final ShopActionSpecifications shopPageSpecifications;

  final ActionSpecification signinButton;
  final ActionSpecification signoutButton;
  final ActionSpecification flushButton;

  final Map<String, NewAppWizardParameters> newAppWizardParameters;

  AppBuilder(
    this.app,
    this.member, {
    required this.logo,
    required this.shopPageSpecifications,
    required this.signinButton,
    required this.signoutButton,
    required this.flushButton,
    required this.newAppWizardParameters,
  }) {
    appId = app.documentID!;
    memberId = member.documentID!;
  }

  var leftDrawer;
  var rightDrawer;
  late HomeMenuModel theHomeMenu;
  var theAppBar;

  var manuallyPaidMembership = false;
  var membershipPaidByCard = false;
  var manualPaymentCart = false;
  var creditCardPaymentCart = false;

  var newlyCreatedApp;

  Future<AppModel> create(NewAppCreateBloc newAppCreateBloc) async {
    List<NewAppTask> tasks = [];

    var hasAccessToLocalFileSystem =
        AbstractMediumPlatform.platform!.hasAccessToLocalFilesystem();

    // uploading a random photo requires access to the local file system
    if (hasAccessToLocalFileSystem) {
      tasks.add(() async {
        print("Logo");
        if (logo == null) {
          try {
            logo = await RandomLogo.getRandomPhoto(app, memberId, null);
          } catch (_) {
            //swallow. On web, today, this fails because we don't have access to asset files
          }
        }
      });
    }

    // create the app
    tasks.add(() async {
      newlyCreatedApp = await appRepository()!.add(AppModel(
        documentID: appId,
        title: 'New application',
        ownerID: memberId,
      ));
    });

    tasks.add(() async {
      print("claimAccess");
      await claimAccess(appId, memberId);
    });
    tasks.add(() async {
      print("claimOwnerShipApplication");
      claimOwnerShipApplication(appId, memberId);
    });

    // check if no errors, e.g. identifier should not exist
    tasks.add(() async {
      print("leftDrawer");
      leftDrawer = await LeftDrawerBuilder(app,
              logo: logo, menuItems: getMenuItemsFor(MenuType.leftDrawerMenu))
          .create();
    });

    tasks.add(() async {
      print("rightDrawer");
      rightDrawer = await RightDrawerBuilder(app,
              logo: logo, menuItems: getMenuItemsFor(MenuType.rightDrawerMenu))
          .create();
    });

    tasks.add(() async {
      print("HomeMenu");
      theHomeMenu = await HomeMenuBuilder(app,
              logo: logo, menuItems: getMenuItemsFor(MenuType.bottomNavBarMenu))
          .create();
    });

    tasks.add(() async {
      print("AppBar");
      theAppBar = await AppBarBuilder(app,
              logo: logo, menuItems: getMenuItemsFor(MenuType.appBarMenu))
          .create();
    });

    tasks.add(() async {
      print("WorkflowBuilder");
      await WorkflowBuilder(appId,
              manuallyPaidMembership: manuallyPaidMembership,
              membershipPaidByCard: membershipPaidByCard,
              manualPaymentCart: manualPaymentCart,
              creditCardPaymentCart: creditCardPaymentCart)
          .create();
    });

    // add the tasks for the extra wizards
    for (var wizard
        in NewAppWizardRegistry.registry().registeredNewAppWizardInfos) {
      var newAppWizardName = wizard.newAppWizardName;
      var parameters = newAppWizardParameters[newAppWizardName];
      if (parameters != null) {
        var extraTasks = wizard.getCreateTasks(
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

    var blockedPageId = NewAppWizardRegistry.registry().getPageID('blockedPageId');
    var homePageId = NewAppWizardRegistry.registry().getPageID('homePageId');
    // app
    tasks.add(() async {
      print("App");
      var newApp = AppModel(
          documentID: appId,
          title: 'New application',
          ownerID: memberId,
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

    var progressManager = ProgressManager(tasks.length,
        (progress) => newAppCreateBloc.add(NewAppCreateProgressed(progress)));

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
      if (newAppCreateBloc.state is NewAppCreateCreateCancelled)
        throw Exception("Process cancelled");
    }

    if (newlyCreatedApp != null) {
      newAppCreateBloc.add(NewAppSwitchAppEvent());
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
