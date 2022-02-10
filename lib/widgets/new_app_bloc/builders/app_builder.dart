import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_pkg_create/registry/action_specification.dart';
import 'package:eliud_pkg_create/registry/registry.dart';
import 'package:eliud_pkg_create/wizards/builders/dialog/assignment_dialog_builder.dart';
import 'package:eliud_pkg_create/wizards/builders/dialog/chat_dialog_builder.dart';
import 'package:eliud_pkg_create/wizards/builders/dialog/member_dashboard_dialog_builder.dart';
import 'package:eliud_pkg_create/wizards/builders/dialog/notification_dashboard_dialog_builder.dart';
import 'package:eliud_pkg_create/wizards/builders/page/about_page_builder.dart';
import 'package:eliud_pkg_create/wizards/builders/page/album_page_builder.dart';
import 'package:eliud_pkg_create/wizards/builders/page/blocked_page_builder.dart';
import 'package:eliud_pkg_create/wizards/builders/page/welcome_page_builder.dart';
import 'package:eliud_pkg_notifications/notifications_package.dart';
import 'package:eliud_core/model/access_model.dart';
import 'package:eliud_core/model/display_conditions_model.dart';
import 'package:eliud_pkg_create/widgets/utils/random_logo.dart';
import 'package:eliud_core/model/icon_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/tools/action/action_model.dart';
import 'package:eliud_core/tools/helpers/progress_manager.dart';
import 'package:eliud_pkg_chat/chat_package.dart';
import 'package:eliud_pkg_medium/platform/medium_platform.dart';
import 'package:eliud_pkg_workflow/workflow_package.dart';
import 'package:flutter/material.dart';
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

typedef NewAppTask = Future<void> Function();

class AppBuilder {
  static String WELCOME_PAGE_ID = 'welcome';
  static String BLOCKED_PAGE_ID = 'blocked';
  static String ALBUM_PAGE_ID = 'album';
  static String ALBUM_EXAMPLE1_PHOTO_ASSET_PATH =
      'packages/eliud_pkg_create/assets/example_photo_1.jpg';
  static String ALBUM_EXAMPLE2_PHOTO_ASSET_PATH =
      'packages/eliud_pkg_create/assets/example_photo_2.jpg';
  static String ABOUT_PAGE_ID = 'about';
  static String ABOUT_ASSET_PATH = 'packages/eliud_pkg_create/assets/about.png';
  static String BLOCKED_ASSET_PATH =
      'packages/eliud_pkg_create/assets/blocked.png';
  static String SHOP_PAGE_ID = 'shop';

  static String MEMBER_DASHBOARD_DIALOG_ID = 'member_dashboard';
  static String NOTIFICATION_DASHBOARD_DIALOG_ID = 'notification_dashboard';
  static String ASSIGNMENT_DASHBOARD_DIALOG_ID = 'assignment_dashboard';

  static String IDENTIFIER_MEMBER_HAS_UNREAD_CHAT = "chat_dialog_with_unread";
  static String IDENTIFIER_MEMBER_ALL_HAVE_BEEN_READ = "chat_dialog_all_read";

  static String ABOUT_COMPONENT_IDENTIFIER = "about";
  static String BLOCKED_COMPONENT_IDENTIFIER = "blocked";
  static String ALBUM_COMPONENT_IDENTIFIER = "album";

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

  final ActionSpecification welcomePageSpecifications;
  final ActionSpecification aboutPageSpecifications;
  final ActionSpecification blockedPageSpecifications;
  final ShopActionSpecifications shopPageSpecifications;
  final ActionSpecification albumPageSpecifications;

  final ActionSpecification chatDialogSpecifications;
  final ActionSpecification memberDashboardDialogSpecifications;

//  final ActionSpecification policySpecifications;

  final JoinActionSpecifications joinSpecification;
  final ActionSpecification signinButton;
  final ActionSpecification signoutButton;
  final ActionSpecification flushButton;

  final ActionSpecification notificationDashboardDialogSpecifications;
  final ActionSpecification assignmentDashboardDialogSpecifications;

  final Map<String, NewAppWizardParameters> newAppWizardParameters;

  AppBuilder(
    this.app,
    this.member, {
    required this.logo,
    required this.welcomePageSpecifications,
    required this.albumPageSpecifications,
    required this.aboutPageSpecifications,
    required this.blockedPageSpecifications,
    required this.shopPageSpecifications,
    required this.chatDialogSpecifications,
    required this.memberDashboardDialogSpecifications,
    required this.joinSpecification,
    required this.signinButton,
    required this.signoutButton,
    required this.flushButton,
    required this.notificationDashboardDialogSpecifications,
    required this.assignmentDashboardDialogSpecifications,
    required this.newAppWizardParameters,
  }) {
    appId = app.documentID!;
    memberId = member.documentID!;
  }

  var homePageId;
  var blockedPageId;
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
    var profilePageId;
    var feedPageId;

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

    // Wizard 1
    if (memberDashboardDialogSpecifications
        .shouldCreatePageDialogOrWorkflow()) {
      tasks.add(() async {
        print("member dashboard");
        await MemberDashboardDialogBuilder(app, MEMBER_DASHBOARD_DIALOG_ID)
            .create();
      });
    }

    // Wizard 3
    if (aboutPageSpecifications.shouldCreatePageDialogOrWorkflow()) {
      tasks.add(() async {
        print("About Page");
        await AboutPageBuilder(
                ABOUT_COMPONENT_IDENTIFIER,
                hasAccessToLocalFileSystem ? ABOUT_ASSET_PATH : null,
                ABOUT_PAGE_ID,
                app,
                memberId,
                theHomeMenu,
                theAppBar,
                leftDrawer,
                rightDrawer)
            .create();
      });
    }

    // Wizard 4
    if (blockedPageSpecifications.shouldCreatePageDialogOrWorkflow()) {
      tasks.add(() async {
        print("Blocked Page");
        var blockedPage = await BlockedPageBuilder(
                BLOCKED_COMPONENT_IDENTIFIER,
                hasAccessToLocalFileSystem ? BLOCKED_ASSET_PATH : null,
                BLOCKED_PAGE_ID,
                app,
                memberId,
                theHomeMenu,
                theAppBar,
                leftDrawer,
                rightDrawer)
            .create();
        blockedPageId = blockedPage.documentID;
      });
    }

    // Wizard 6
    if (notificationDashboardDialogSpecifications
        .shouldCreatePageDialogOrWorkflow()) {
      tasks.add(() async {
        print("Notification Dashboard");
        await NotificationDashboardDialogBuilder(
                app, NOTIFICATION_DASHBOARD_DIALOG_ID)
            .create();
      });
    }

    // Wizard 7
    if (assignmentDashboardDialogSpecifications
        .shouldCreatePageDialogOrWorkflow()) {
      tasks.add(() async {
        print("Assignment Dialog");
        await AssignmentDialogBuilder(app, ASSIGNMENT_DASHBOARD_DIALOG_ID)
            .create();
      });
    }

    // Wizard 8
    // welcome page
    if (welcomePageSpecifications.shouldCreatePageDialogOrWorkflow()) {
      tasks.add(() async {
        print("Welcome Page");
        var welcomePage = await WelcomePageBuilder(WELCOME_PAGE_ID, app,
                memberId, theHomeMenu, theAppBar, leftDrawer, rightDrawer)
            .create();
        homePageId = welcomePage.documentID;
      });
    }

    // Wizard 9
    if (albumPageSpecifications.shouldCreatePageDialogOrWorkflow()) {
      tasks.add(() async {
        print("Album page");
        await AlbumPageBuilder(
                ALBUM_COMPONENT_IDENTIFIER,
                ALBUM_EXAMPLE1_PHOTO_ASSET_PATH,
                ALBUM_EXAMPLE2_PHOTO_ASSET_PATH,
                ALBUM_PAGE_ID,
                app,
                memberId,
                theHomeMenu,
                theAppBar,
                leftDrawer,
                rightDrawer)
            .create();
      });
    }

    // Wizard 10
    // chat
    if (chatDialogSpecifications.shouldCreatePageDialogOrWorkflow()) {
      tasks.add(() async {
        print("Chat dialog");
        await ChatDialogBuilder(app,
                identifierMemberAllHaveBeenRead:
                    IDENTIFIER_MEMBER_ALL_HAVE_BEEN_READ,
                identifierMemberHasUnreadChat:
                    IDENTIFIER_MEMBER_HAS_UNREAD_CHAT)
            .create();
      });
    }

    // Wizard 11
    // join
    if (joinSpecification.shouldCreatePageDialogOrWorkflow()) {
      if (joinSpecification.paymentType == JoinPaymentType.Manual) {
        manuallyPaidMembership = true;
      } else {
        membershipPaidByCard = true;
      }
    }

    // Wizard 12
    // shop
    if (shopPageSpecifications.shouldCreatePageDialogOrWorkflow()) {
      if (shopPageSpecifications.paymentType == ShopPaymentType.Manual) {
        manualPaymentCart = true;
      } else {
        creditCardPaymentCart = true;
      }
    }

    // Wizard ????
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

    var _welcomePageId =
        evaluate(welcomePageSpecifications) ? WELCOME_PAGE_ID : null;
    var _blockedPageId =
        evaluate(blockedPageSpecifications) ? BLOCKED_PAGE_ID : null;
    var _aboutPageId = evaluate(aboutPageSpecifications) ? ABOUT_PAGE_ID : null;
    var _shopPageId = evaluate(shopPageSpecifications) ? SHOP_PAGE_ID : null;
    var _albumPageId = evaluate(albumPageSpecifications) ? ALBUM_PAGE_ID : null;

    var _notificationDashboardDialogId =
        evaluate(notificationDashboardDialogSpecifications)
            ? NOTIFICATION_DASHBOARD_DIALOG_ID
            : null;

    var _assignmentDasboardDialogId =
        evaluate(assignmentDashboardDialogSpecifications)
            ? ASSIGNMENT_DASHBOARD_DIALOG_ID
            : null;

    var _memberDashboardDialogId = evaluate(memberDashboardDialogSpecifications)
        ? MEMBER_DASHBOARD_DIALOG_ID
        : null;

    var _hasUnreadChatDialogId = evaluate(chatDialogSpecifications)
        ? IDENTIFIER_MEMBER_HAS_UNREAD_CHAT
        : null;
    var _allMessagesHaveBeenReadChatDialog = evaluate(chatDialogSpecifications)
        ? IDENTIFIER_MEMBER_ALL_HAVE_BEEN_READ
        : null;

    var _signout = evaluate(signoutButton);
    var _signin = evaluate(signinButton);

    List<MenuItemModel> oldMenuItems = [
      if (_welcomePageId != null)
        menuItemWelcome(app, _welcomePageId, 'Welcome'),
      if (_blockedPageId != null)
        menuItem(app, _blockedPageId, 'Blocked', Icons.do_not_disturb),
      if (_aboutPageId != null) menuItemAbout(app, _aboutPageId, 'About'),
      if (_memberDashboardDialogId != null)
        menuItemManageAccount(app, _memberDashboardDialogId),
      if (_shopPageId != null) menuItemShop(app, _shopPageId, 'Shop'),
      if (_notificationDashboardDialogId != null)
        MenuItemModel(
            documentID: 'notifications',
            text: 'Notifications',
            description: 'Notifications',
            icon: IconModel(
                codePoint: Icons.notifications.codePoint,
                fontFamily: Icons.notifications.fontFamily),
            action: OpenDialog(app,
                dialogID: _notificationDashboardDialogId,
                conditions: DisplayConditionsModel(
                    privilegeLevelRequired:
                        PrivilegeLevelRequired.NoPrivilegeRequired,
                    packageCondition: NotificationsPackage
                        .CONDITION_MEMBER_HAS_UNREAD_NOTIFICATIONS,
                    conditionOverride: ConditionOverride
                        .InclusiveForBlockedMembers // allow blocked members to see
                    ))),
      if (_assignmentDasboardDialogId != null)
        MenuItemModel(
            documentID: 'assignments',
            text: 'Assignments',
            description: 'Assignments',
            icon: IconModel(
                codePoint: Icons.playlist_add_check.codePoint,
                fontFamily: Icons.notifications.fontFamily),
            action: OpenDialog(app,
                dialogID: _assignmentDasboardDialogId,
                conditions: DisplayConditionsModel(
                    packageCondition:
                        WorkflowPackage.CONDITION_MUST_HAVE_ASSIGNMENTS,
                    conditionOverride: ConditionOverride
                        .InclusiveForBlockedMembers // allow blocked members to see
                    ))),
      if (_hasUnreadChatDialogId != null)
        MenuItemModel(
            documentID: IDENTIFIER_MEMBER_HAS_UNREAD_CHAT,
            text: 'Chat',
            description: 'Some unread messages available',
            icon: IconModel(
                codePoint: Icons.chat_bubble_rounded.codePoint,
                fontFamily: Icons.notifications.fontFamily),
            action: OpenDialog(app,
                dialogID: _hasUnreadChatDialogId,
                conditions: DisplayConditionsModel(
                    privilegeLevelRequired:
                        PrivilegeLevelRequired.NoPrivilegeRequired,
                    packageCondition:
                        ChatPackage.CONDITION_MEMBER_HAS_UNREAD_CHAT))),
      if (_allMessagesHaveBeenReadChatDialog != null)
        MenuItemModel(
            documentID: IDENTIFIER_MEMBER_ALL_HAVE_BEEN_READ,
            text: 'Chat',
            description: 'Open chat',
            icon: IconModel(
                codePoint: Icons.chat_bubble_outline_rounded.codePoint,
                fontFamily: Icons.notifications.fontFamily),
            action: OpenDialog(app,
                dialogID: _allMessagesHaveBeenReadChatDialog,
                conditions: DisplayConditionsModel(
                    privilegeLevelRequired:
                        PrivilegeLevelRequired.NoPrivilegeRequired,
                    packageCondition:
                        ChatPackage.CONDITION_MEMBER_ALL_HAVE_BEEN_READ))),
      if (_signout) menuItemSignOut(app),
      if (_signin) menuItemSignIn(app),
    ];

    List<MenuItemModel> newMenuItems = [];
    for (var wizard
        in NewAppWizardRegistry.registry().registeredNewAppWizardInfos) {
      var newAppWizardName = wizard.newAppWizardName;
      var newAppWizardParam = newAppWizardParameters[newAppWizardName];
      if (newAppWizardParam != null) {
        var menuItem = wizard.getMenuItemFor(app, newAppWizardParam, type);
        if (menuItem != null) {
          newMenuItems.add(menuItem);
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
