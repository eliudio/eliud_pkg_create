import 'package:eliud_core/core_package.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_notifications/notifications_package.dart';
import 'package:eliud_core/model/access_model.dart';
import 'package:eliud_core/model/display_conditions_model.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/page/album_page_builder.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/page/blocked_page_builder.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/page/page_with_text.dart';
import 'package:eliud_pkg_create/widgets/utils/random_logo.dart';
import 'package:eliud_core/model/icon_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/tools/action/action_model.dart';
import 'package:eliud_core/tools/helpers/progress_manager.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_pkg_chat/chat_package.dart';
import 'package:eliud_pkg_follow/follow_package.dart';
import 'package:eliud_pkg_medium/platform/medium_platform.dart';
import 'package:eliud_pkg_membership/membership_package.dart';
import 'package:eliud_pkg_workflow/model/workflow_model.dart';
import 'package:eliud_pkg_workflow/tools/action/workflow_action_model.dart';
import 'package:eliud_pkg_workflow/workflow_package.dart';
import 'package:flutter/material.dart';
import '../action_specification.dart';
import 'package:eliud_core/model/app_home_page_references_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/style/_default/default_style_family.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';

import 'dialog/assignment_dialog_builder.dart';
import 'dialog/member_dashboard_dialog_builder.dart';
import 'dialog/membership_dashboard_dialog_builder.dart';
import 'dialog/notification_dashboard_dialog_builder.dart';
import 'feed/feed_page_builder.dart';
import 'feed/follow_requests_dashboard_page_builder.dart';
import 'feed/followers_dashboard_page_builder.dart';
import 'feed/following_dashboard_page_builder.dart';
import 'feed/invite_dashboard_page_builder.dart';
import 'feed/membership_dashboard_page_builder.dart';
import 'feed/profile_page_builder.dart';
import 'helpers/menu_helpers.dart';
import 'page/about_page_builder.dart';
import 'workflow_builder.dart';
import 'app_bar_builder.dart';
import 'home_menu_builder.dart';
import 'left_drawer_builder.dart';
import 'right_drawer_builder.dart';
import 'dialog/chat_dialog_builder.dart';
import 'page/policy_page_builder.dart';
import 'page/welcome_page_builder.dart';
import 'policy/policy_medium_builder.dart';
import 'policy/app_policy_builder.dart';

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
  static String POLICY_PAGE_ID = 'policy';
  static String FEED_PAGE_ID = 'feed';
  static String PROFILE_PAGE_ID = 'profile';
  static String FOLLOW_REQUEST_PAGE_ID = 'follow_request';
  static String FOLLOWERS_PAGE_ID = 'followers';
  static String FOLLOWING_PAGE_ID = 'following';
  static String FIND_FRIEND_PAGE_ID = 'fiend_friends';
  static String APP_MEMBERS_PAGE_ID = 'app_members';

  static String MEMBER_DASHBOARD_DIALOG_ID = 'member_dashboard';
  static String MEMBERSHIP_DASHBOARD_DIALOG_ID = 'membership_dashboard';
  static String NOTIFICATION_DASHBOARD_DIALOG_ID = 'notification_dashboard';
  static String ASSIGNMENT_DASHBOARD_DIALOG_ID = 'assignment_dashboard';

  static String IDENTIFIER_MEMBER_HAS_UNREAD_CHAT = "chat_dialog_with_unread";
  static String IDENTIFIER_MEMBER_ALL_HAVE_BEEN_READ = "chat_dialog_all_read";

  static String FEED_MENU_COMPONENT_IDENTIFIER = "feed_menu";
  static String ABOUT_COMPONENT_IDENTIFIER = "about";
  static String BLOCKED_COMPONENT_IDENTIFIER = "blocked";
  static String FOLLOW_REQUEST_COMPONENT_ID = "follow_request";
  static String FEED_HEADER_COMPONENT_IDENTIFIER = "feed_header";
  static String FEED_PROFILE_COMPONENT_IDENTIFIER = "feed_profile";
  static String FOLLOWERS_COMPONENT_IDENTIFIER = "followers";
  static String FOLLOWING_COMPONENT_IDENTIFIER = "following";
  static String INVITE_COMPONENT_IDENTIFIER = "invite";
  static String MEMBERSHIP_COMPONENT_IDENTIFIER = "membership";
  static String PROFILE_COMPONENT_IDENTIFIER = "profile";
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
  final ActionSpecification feedPageSpecifications;
  final ActionSpecification albumPageSpecifications;

  final ActionSpecification chatDialogSpecifications;
  final ActionSpecification memberDashboardDialogSpecifications;

  final ActionSpecification policySpecifications;

  final JoinActionSpecifications joinSpecification;
  final ActionSpecification signoutButton;
  final ActionSpecification flushButton;

  final ActionSpecification membershipDashboardDialogSpecifications;
  final ActionSpecification notificationDashboardDialogSpecifications;
  final ActionSpecification assignmentDashboardDialogSpecifications;

  AppBuilder(
    this.app,
    this.member, {
    required this.logo,
    required this.welcomePageSpecifications,
    required this.albumPageSpecifications,
    required this.aboutPageSpecifications,
    required this.blockedPageSpecifications,
    required this.shopPageSpecifications,
    required this.feedPageSpecifications,
    required this.chatDialogSpecifications,
    required this.memberDashboardDialogSpecifications,
    required this.policySpecifications,
    required this.joinSpecification,
    required this.signoutButton,
    required this.flushButton,
    required this.membershipDashboardDialogSpecifications,
    required this.notificationDashboardDialogSpecifications,
    required this.assignmentDashboardDialogSpecifications,
  }) {
    appId = app.documentID!;
    memberId = member.documentID!;
  }

  var homePageId;
  var blockedPageId;
  var leftDrawer;
  var rightDrawer;
  var theHomeMenu;
  var theAppBar;
  var policyMedium;
  var policyModel;

  var manuallyPaidMembership = false;
  var membershipPaidByCard = false;
  var manualPaymentCart = false;
  var creditCardPaymentCart = false;

  var newlyCreatedApp;
  var feedModel;

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
            logo = await RandomLogo.getRandomPhoto(appId, memberId, null);
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
          ownerID: memberId,));
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
      leftDrawer = await LeftDrawerBuilder(appId,
          logo: logo,
          menuItems:
              getMenuItemsFor((value) => value.availableInLeftDrawer)).create();
    });

    tasks.add(() async {
      print("rightDrawer");
      rightDrawer = await RightDrawerBuilder(appId,
              logo: logo,
              menuItems:
                  getMenuItemsFor((value) => value.availableInRightDrawer))
          .create();
    });

    tasks.add(() async {
      print("HomeMenu");
      theHomeMenu = await HomeMenuBuilder(appId,
              logo: logo,
              menuItems: getMenuItemsFor((value) => value.availableInHomeMenu))
          .create();
    });

    tasks.add(() async {
      print("AppBar");
      theAppBar = await AppBarBuilder(appId,
              logo: logo,
              menuItems: getMenuItemsFor((value) => value.availableInAppBar))
          .create();
    });

    if (memberDashboardDialogSpecifications
        .shouldCreatePageDialogOrWorkflow()) {
      tasks.add(() async {
        print("member dashboard");
        await MemberDashboardDialogBuilder(appId, MEMBER_DASHBOARD_DIALOG_ID)
            .create();
      });
    }

    // Feed and profile page
    if (feedPageSpecifications.shouldCreatePageDialogOrWorkflow()) {
      profilePageId = PROFILE_PAGE_ID;
      feedPageId = FEED_PAGE_ID;
      tasks.add(() async {
        print("feedModel");
        feedModel = await FeedPageBuilder(FEED_PAGE_ID, appId, memberId,
                theHomeMenu, theAppBar, leftDrawer, rightDrawer)
            .run(
                feedMenuComponentIdentifier: FEED_MENU_COMPONENT_IDENTIFIER,
                headerComponentIdentifier: FEED_HEADER_COMPONENT_IDENTIFIER,
                profileComponentIdentifier: FEED_PROFILE_COMPONENT_IDENTIFIER,
                feedPageId: FEED_PAGE_ID,
                profilePageId: PROFILE_PAGE_ID,
                followRequestPageId: FOLLOW_REQUEST_PAGE_ID,
                followersPageId: FOLLOWERS_PAGE_ID,
                followingPageId: FOLLOWING_PAGE_ID,
                fiendFriendsPageId: FIND_FRIEND_PAGE_ID,
                appMembersPageId: APP_MEMBERS_PAGE_ID);
      });

      tasks.add(() async {
        print("Follow Request");
        await FollowRequestsDashboardPageBuilder(FOLLOW_REQUEST_PAGE_ID, appId,
                memberId, theHomeMenu, theAppBar, leftDrawer, rightDrawer)
            .run(
          componentIdentifier: FOLLOW_REQUEST_COMPONENT_ID,
          profilePageId: PROFILE_PAGE_ID,
          feedPageId: FEED_PAGE_ID,
          feedMenuComponentIdentifier: FEED_MENU_COMPONENT_IDENTIFIER,
          headerComponentIdentifier: FEED_HEADER_COMPONENT_IDENTIFIER,
        );
      });
      tasks.add(() async {
        print("Followers Dashboard");
        await FollowersDashboardPageBuilder(FOLLOWERS_PAGE_ID, appId, memberId,
                theHomeMenu, theAppBar, leftDrawer, rightDrawer)
            .run(
          componentIdentifier: FOLLOWERS_COMPONENT_IDENTIFIER,
          profilePageId: PROFILE_PAGE_ID,
          feedPageId: FEED_PAGE_ID,
          feedMenuComponentIdentifier: FEED_MENU_COMPONENT_IDENTIFIER,
          headerComponentIdentifier: FEED_HEADER_COMPONENT_IDENTIFIER,
        );
      });
      tasks.add(() async {
        print("Following Dashboard");
        await FollowingDashboardPageBuilder(FOLLOWING_PAGE_ID, appId, memberId,
                theHomeMenu, theAppBar, leftDrawer, rightDrawer)
            .run(
          componentIdentifier: FOLLOWING_COMPONENT_IDENTIFIER,
          profilePageId: PROFILE_PAGE_ID,
          feedPageId: FEED_PAGE_ID,
          feedMenuComponentIdentifier: FEED_MENU_COMPONENT_IDENTIFIER,
          headerComponentIdentifier: FEED_HEADER_COMPONENT_IDENTIFIER,
        );
      });
      tasks.add(() async {
        print("Invite Dashboard");
        await InviteDashboardPageBuilder(FIND_FRIEND_PAGE_ID, appId, memberId,
                theHomeMenu, theAppBar, leftDrawer, rightDrawer)
            .run(
          componentIdentifier: INVITE_COMPONENT_IDENTIFIER,
          profilePageId: PROFILE_PAGE_ID,
          feedPageId: FEED_PAGE_ID,
          feedMenuComponentIdentifier: FEED_MENU_COMPONENT_IDENTIFIER,
          headerComponentIdentifier: FEED_HEADER_COMPONENT_IDENTIFIER,
        );
      });
      tasks.add(() async {
        print("Membership Dashboard");
        await MembershipDashboardPageBuilder(APP_MEMBERS_PAGE_ID, appId,
                memberId, theHomeMenu, theAppBar, leftDrawer, rightDrawer)
            .run(
          componentIdentifier: MEMBERSHIP_COMPONENT_IDENTIFIER,
          profilePageId: PROFILE_PAGE_ID,
          feedPageId: FEED_PAGE_ID,
          feedMenuComponentIdentifier: FEED_MENU_COMPONENT_IDENTIFIER,
          headerComponentIdentifier: FEED_HEADER_COMPONENT_IDENTIFIER,
        );
      });
      tasks.add(() async {
        print("Profile Page");
        await ProfilePageBuilder(PROFILE_PAGE_ID, appId, memberId, theHomeMenu,
                theAppBar, leftDrawer, rightDrawer)
            .run(
          feed: feedModel,
          member: member,
          feedMenuComponentIdentifier: FEED_MENU_COMPONENT_IDENTIFIER,
          headerComponentIdentifier: FEED_HEADER_COMPONENT_IDENTIFIER,
          profileComponentIdentifier: PROFILE_COMPONENT_IDENTIFIER,
        );
      });
    }

    if (aboutPageSpecifications.shouldCreatePageDialogOrWorkflow()) {
      tasks.add(() async {
        print("About Page");
          await AboutPageBuilder(
              ABOUT_COMPONENT_IDENTIFIER,
              hasAccessToLocalFileSystem ? ABOUT_ASSET_PATH : null,
              ABOUT_PAGE_ID,
              appId,
              memberId,
              theHomeMenu,
              theAppBar,
              leftDrawer,
              rightDrawer)
              .create();
      });
    }

    if (blockedPageSpecifications.shouldCreatePageDialogOrWorkflow()) {
      tasks.add(() async {
        print("Blocked Page");
          var blockedPage = await BlockedPageBuilder(
              BLOCKED_COMPONENT_IDENTIFIER,
              hasAccessToLocalFileSystem ? BLOCKED_ASSET_PATH : null,
              BLOCKED_PAGE_ID,
              appId,
              memberId,
              theHomeMenu,
              theAppBar,
              leftDrawer,
              rightDrawer)
              .create();
          blockedPageId = blockedPage.documentID;
      });
    }

    if (membershipDashboardDialogSpecifications
        .shouldCreatePageDialogOrWorkflow()) {
      print("Membership Dashboard");
      tasks.add(() async => await MembershipDashboardDialogBuilder(
              appId, MEMBERSHIP_DASHBOARD_DIALOG_ID,
              profilePageId: profilePageId, feedPageId: feedPageId)
          .create());
    }

    if (notificationDashboardDialogSpecifications
        .shouldCreatePageDialogOrWorkflow()) {
      tasks.add(() async {
        print("Notification Dashboard");
        await NotificationDashboardDialogBuilder(
                appId, NOTIFICATION_DASHBOARD_DIALOG_ID)
            .create();
      });
    }

    if (assignmentDashboardDialogSpecifications
        .shouldCreatePageDialogOrWorkflow()) {
      tasks.add(() async {
        print("Assignment Dialog");
        await AssignmentDialogBuilder(appId, ASSIGNMENT_DASHBOARD_DIALOG_ID)
            .create();
      });
    }
    // policy
    if (policySpecifications.shouldCreatePageDialogOrWorkflow()) {
      // policy medium
      tasks.add(() async {
        print("Policy Medium");
        policyMedium =
            await PolicyMediumBuilder((value) => {}, appId, memberId).create();
      });

      // policy
      tasks.add(() async {
        print("Policy Model");
        policyModel =
            await AppPolicyBuilder(appId, memberId, policyMedium).create();
      });

      // policy page
      tasks.add(() async {
        print("Policy Page");
        await PolicyPageBuilder(POLICY_PAGE_ID, appId, memberId, theHomeMenu,
                theAppBar, leftDrawer, rightDrawer, policyMedium, 'Policy')
            .create();
      });
    }

    // welcome page
    if (welcomePageSpecifications.shouldCreatePageDialogOrWorkflow()) {
      tasks.add(() async {
        print("Welcome Page");
        var welcomePage = await WelcomePageBuilder(WELCOME_PAGE_ID, appId,
                memberId, theHomeMenu, theAppBar, leftDrawer, rightDrawer)
            .create();
        homePageId = welcomePage.documentID;
      });
    }

    if (albumPageSpecifications.shouldCreatePageDialogOrWorkflow()) {
      tasks.add(() async {
        print("Album page");
        await AlbumPageBuilder(
                ALBUM_COMPONENT_IDENTIFIER,
                ALBUM_EXAMPLE1_PHOTO_ASSET_PATH,
                ALBUM_EXAMPLE2_PHOTO_ASSET_PATH,
                ALBUM_PAGE_ID,
                appId,
                memberId,
                theHomeMenu,
                theAppBar,
                leftDrawer,
                rightDrawer)
            .create();
      });
    }

    // chat
    if (chatDialogSpecifications.shouldCreatePageDialogOrWorkflow()) {
      tasks.add(() async {
        print("Chat dialog");
        await ChatDialogBuilder(appId,
                identifierMemberAllHaveBeenRead:
                    IDENTIFIER_MEMBER_ALL_HAVE_BEEN_READ,
                identifierMemberHasUnreadChat:
                    IDENTIFIER_MEMBER_HAS_UNREAD_CHAT)
            .create();
      });
    }

    // join
    if (joinSpecification.shouldCreatePageDialogOrWorkflow()) {
      if (joinSpecification.paymentType == JoinPaymentType.Manual) {
        manuallyPaidMembership = true;
      } else {
        membershipPaidByCard = true;
      }
    }

    // shop
    if (shopPageSpecifications.shouldCreatePageDialogOrWorkflow()) {
      if (shopPageSpecifications.paymentType == ShopPaymentType.Manual) {
        manualPaymentCart = true;
      } else {
        creditCardPaymentCart = true;
      }
    }

    tasks.add(() async {
      print("WorkflowBuilder");
      await WorkflowBuilder(appId,
              manuallyPaidMembership: manuallyPaidMembership,
              membershipPaidByCard: membershipPaidByCard,
              manualPaymentCart: manualPaymentCart,
              creditCardPaymentCart: creditCardPaymentCart)
          .create();
    });

    // app
    tasks.add(() async {
      print("App");
      newlyCreatedApp = await appRepository()!.update(AppModel(
          documentID: appId,
          title: 'New application',
          ownerID: memberId,
          styleFamily:
              app.styleFamily ?? DefaultStyleFamily.defaultStyleFamilyName,
          styleName: app.styleName ?? DefaultStyle.defaultStyleName,
          email: member.email,
          policies: policyModel,
          description: 'Your new application',
          logo: logo,
          homePages: AppHomePageReferencesModel(
            homePageBlockedMember: blockedPageId ?? homePageId,
            homePagePublic: homePageId,
            homePageSubscribedMember: homePageId,
            homePageLevel1Member: homePageId,
            homePageLevel2Member: homePageId,
            homePageOwner: homePageId,
          )));
    });

    var progressManager = ProgressManager(tasks.length,
        (progress) => newAppCreateBloc.add(NewAppCreateProgressed(progress)));

    var currentTask = tasks[0];
    currentTask().then((value) => tasks[1]);

    for (var task in tasks) {
      await task();
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

  List<MenuItemModel> getMenuItemsFor(Evaluate evaluate) {
    var _welcomePageId =
        evaluate(welcomePageSpecifications) ? WELCOME_PAGE_ID : null;
    var _blockedPageId =
        evaluate(blockedPageSpecifications) ? BLOCKED_PAGE_ID : null;
    var _aboutPageId = evaluate(aboutPageSpecifications) ? ABOUT_PAGE_ID : null;
    var _shopPageId = evaluate(shopPageSpecifications) ? SHOP_PAGE_ID : null;
    var _feedPageId = evaluate(feedPageSpecifications) ? FEED_PAGE_ID : null;
    var _albumPageId = evaluate(albumPageSpecifications) ? ALBUM_PAGE_ID : null;
/*
    var _profilePageId = evaluate(feedPageSpecifications) ? PROFILE_PAGE_ID : null;
    var _followRequestPageId = evaluate(feedPageSpecifications) ? FOLLOW_REQUEST_PAGE_ID : null;
    var _followersPageId = evaluate(feedPageSpecifications) ? FOLLOWERS_PAGE_ID : null;
    var _followingPageId = evaluate(feedPageSpecifications) ? FOLLOWING_PAGE_ID : null;
    var _findFriendPageId = evaluate(feedPageSpecifications) ? FIND_FRIEND_PAGE_ID : null;
    var _appMembersPageId = evaluate(feedPageSpecifications) ? APP_MEMBERS_PAGE_ID : null;
    var _invitePageId = evaluate(feedPageSpecifications) ? INVITE_PAGE_ID : null;
    var _membershipPageId = evaluate(feedPageSpecifications) ? MEMBERSHIP_PAGE_ID : null;
*/

    var _membershipDashboardDialogId =
        evaluate(membershipDashboardDialogSpecifications)
            ? MEMBERSHIP_DASHBOARD_DIALOG_ID
            : null;

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
    var _policyPageId = evaluate(policySpecifications) ? POLICY_PAGE_ID : null;

    var _hasUnreadChatDialogId = evaluate(chatDialogSpecifications)
        ? IDENTIFIER_MEMBER_HAS_UNREAD_CHAT
        : null;
    var _allMessagesHaveBeenReadChatDialog = evaluate(chatDialogSpecifications)
        ? IDENTIFIER_MEMBER_ALL_HAVE_BEEN_READ
        : null;

    var _signout = evaluate(signoutButton);

    return [
      if (_welcomePageId != null)
        menuItemWelcome(appId, _welcomePageId, 'Welcome'),
      if (_blockedPageId != null)
        menuItem(appId, _blockedPageId, 'Blocked', Icons.do_not_disturb),
      if (_aboutPageId != null) menuItemAbout(appId, _aboutPageId, 'About'),
      if (_albumPageId != null) menuItemAbout(appId, _albumPageId, 'Album'),
      if (_memberDashboardDialogId != null)
        menuItemManageAccount(appId, _memberDashboardDialogId),
      if (_policyPageId != null)
        menuItem(appId, _policyPageId, 'Policy', Icons.rule),
      if (_shopPageId != null) menuItemShop(appId, _shopPageId, 'Shop'),
      if (_feedPageId != null) menuItemFeed(appId, _feedPageId, 'Feed'),
      if (_notificationDashboardDialogId != null)
        MenuItemModel(
            documentID: 'notifications',
            text: 'Notifications',
            description: 'Notifications',
            icon: IconModel(
                codePoint: Icons.notifications.codePoint,
                fontFamily: Icons.notifications.fontFamily),
            action:
                OpenDialog(appId, dialogID: _notificationDashboardDialogId,
                conditions: DisplayConditionsModel(
                  privilegeLevelRequired: PrivilegeLevelRequired.NoPrivilegeRequired,
                    packageCondition:
                    NotificationsPackage.CONDITION_MEMBER_HAS_UNREAD_NOTIFICATIONS,
                    conditionOverride: ConditionOverride.InclusiveForBlockedMembers // allow blocked members to see
                )
                )),
      if (_assignmentDasboardDialogId != null)
        MenuItemModel(
            documentID: 'assignments',
            text: 'Assignments',
            description: 'Assignments',
            icon: IconModel(
                codePoint: Icons.playlist_add_check.codePoint,
                fontFamily: Icons.notifications.fontFamily),
            action: OpenDialog(appId, dialogID: _assignmentDasboardDialogId,
            conditions: DisplayConditionsModel(
                packageCondition: WorkflowPackage.CONDITION_MUST_HAVE_ASSIGNMENTS,
                conditionOverride: ConditionOverride.InclusiveForBlockedMembers // allow blocked members to see
            )
            )),
      if (_membershipDashboardDialogId != null)
        MenuItemModel(
            documentID: '3',
            text: 'Members',
            description: 'Members',
            icon: IconModel(
                codePoint: Icons.people.codePoint,
                fontFamily: Icons.notifications.fontFamily),
            action: OpenDialog(appId, dialogID: _membershipDashboardDialogId)),
      if (_hasUnreadChatDialogId != null)
        MenuItemModel(
            documentID: IDENTIFIER_MEMBER_HAS_UNREAD_CHAT,
            text: 'Chat',
            description: 'Some unread messages available',
            icon: IconModel(
                codePoint: Icons.chat_bubble_rounded.codePoint,
                fontFamily: Icons.notifications.fontFamily),
            action: OpenDialog(appId,
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
            action: OpenDialog(appId,
                dialogID: _allMessagesHaveBeenReadChatDialog,
                conditions: DisplayConditionsModel(
                    privilegeLevelRequired:
                        PrivilegeLevelRequired.NoPrivilegeRequired,
                    packageCondition:
                        ChatPackage.CONDITION_MEMBER_ALL_HAVE_BEEN_READ))),
      if (_signout) menuItemSignOut(appId),
    ];
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
