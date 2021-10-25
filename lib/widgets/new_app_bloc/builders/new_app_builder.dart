import 'package:eliud_core/core_package.dart';
import 'package:eliud_core/model/conditions_model.dart';
import 'package:eliud_core/model/icon_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/tools/action/action_model.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_pkg_chat/chat_package.dart';
import 'package:eliud_pkg_follow/follow_package.dart';
import 'package:eliud_pkg_membership/membership_package.dart';
import 'package:eliud_pkg_workflow/model/workflow_model.dart';
import 'package:eliud_pkg_workflow/tools/action/workflow_action_model.dart';
import 'package:flutter/material.dart';
import '../action_specification.dart';
import 'package:eliud_core/model/app_home_page_references_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/style/_default/default_style_family.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';

import 'workflow_builder.dart';
import 'app_bar_builder.dart';
import 'home_menu_builder.dart';
import 'left_drawer_builder.dart';
import 'member_dashboard_builder.dart';
import 'right_drawer_builder.dart';

import 'dialog/chat_dialog_builder.dart';

import 'page/policy_page_builder.dart';
import 'page/welcome_page_builder.dart';

import 'policy/policy_medium_builder.dart';
import 'policy/app_policy_builder.dart';

typedef bool Evaluate(ActionSpecification actionSpecification);

class NewAppBuilder {
  static String WELCOME_PAGE_ID = 'welcome';
  static String SHOP_PAGE_ID = 'shop';
  static String FEED_PAGE_ID = 'feed';
  static String MEMBER_DASHBOARD_ID = 'member_dashboard';
  static String POLICY_PAGE_ID = 'policy';
  static String IDENTIFIER_MEMBER_HAS_UNREAD_CHAT = "chat_dialog_with_unread";
  static String IDENTIFIER_MEMBER_ALL_HAVE_BEEN_READ = "chat_dialog_all_read";
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

  final PublicMediumModel? logo;

  final ActionSpecification welcomePageSpecifications;
  final ShopActionSpecifications shopPageSpecifications;
  final ActionSpecification feedPageSpecifications;

  final ActionSpecification chatDialogSpecifications;
  final ActionSpecification memberDashboardDialogSpecifications;

  final ActionSpecification policySpecifications;

  final JoinActionSpecifications joinSpecification;
  final ActionSpecification signoutButton;
  final ActionSpecification flushButton;

  NewAppBuilder(
    this.app,
    this.member, {
    required this.logo,

    required this.welcomePageSpecifications,
    required this.shopPageSpecifications,
    required this.feedPageSpecifications,

    required this.chatDialogSpecifications,
    required this.memberDashboardDialogSpecifications,

    required this.policySpecifications,

    required this.joinSpecification,
    required this.signoutButton,
    required this.flushButton,
  }) {
    appId = app.documentID!;
    memberId = member.documentID!;
  }

  Future<AppModel> create() async {
    // check if no errors, e.g. identifier should not exist
    var homePageId = null;

    var leftDrawer = await LeftDrawerBuilder(appId,
            logo: logo,
            menuItems:
                geDrawerMenuItemsFor((value) => value.availableInLeftDrawer))
        .create();

    var rightDrawer = await RightDrawerBuilder(appId,
            logo: logo,
            menuItems:
                geDrawerMenuItemsFor((value) => value.availableInRightDrawer))
        .create();

    var theHomeMenu = await HomeMenuBuilder(appId,
            logo: logo,
            menuItems:
                geDrawerMenuItemsFor((value) => value.availableInHomeMenu))
        .create();

    var theAppBar = await AppBarBuilder(appId,
            logo: logo,
            menuItems: geDrawerMenuItemsFor((value) => value.availableInAppBar))
        .create();

    // member dashboard
    if (memberDashboardDialogSpecifications
        .shouldCreatePageDialogOrWorkflow()) {
      await MemberDashboardBuilder(appId).create();
    }

    // policy
    var policyMedium;
    var policyModel;
    if (policySpecifications.shouldCreatePageDialogOrWorkflow()) {
      // policy medium
      policyMedium =
          await PolicyMediumBuilder((value) => {}, appId, memberId).create();

      // policy
      policyModel =
          await AppPolicyBuilder(appId, memberId, policyMedium).create();

      // policy page
      await PolicyPageBuilder(POLICY_PAGE_ID, appId, memberId, theHomeMenu,
              theAppBar, leftDrawer, rightDrawer, policyMedium, 'Policy')
          .create();
    }

    // welcome page
    if (welcomePageSpecifications.shouldCreatePageDialogOrWorkflow()) {
      var welcomePage = await WelcomePageBuilder(WELCOME_PAGE_ID, appId, memberId, theHomeMenu,
              theAppBar, leftDrawer, rightDrawer)
          .create();
      homePageId = welcomePage.documentID;
    }

    // chat
    if (chatDialogSpecifications.shouldCreatePageDialogOrWorkflow()) {
      await ChatDialogBuilder(appId).create();
    }

    // join
    var manuallyPaidMembership = false;
    var membershipPaidByCard = false;
    if (joinSpecification.shouldCreatePageDialogOrWorkflow()) {
      if (joinSpecification.paymentType == JoinPaymentType.Manual) {
        manuallyPaidMembership = true;
      } else {
        membershipPaidByCard = true;
      }
    }

    // shop
    var manualPaymentCart = false;
    var creditCardPaymentCart = false;
    if (shopPageSpecifications.shouldCreatePageDialogOrWorkflow()) {
      if (shopPageSpecifications.paymentType == ShopPaymentType.Manual) {
        manualPaymentCart = true;
      } else {
        creditCardPaymentCart = true;
      }
    }

    await WorkflowBuilder(appId,
            manuallyPaidMembership: manuallyPaidMembership,
            membershipPaidByCard: membershipPaidByCard,
            manualPaymentCart: manualPaymentCart,
            creditCardPaymentCart: creditCardPaymentCart)
        .create();

    // app
    var appModel = await appRepository()!.add(AppModel(
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
          homePageBlockedMember: homePageId,
          homePagePublic: homePageId,
          homePageSubscribedMember: homePageId,
          homePageLevel1Member: homePageId,
          homePageLevel2Member: homePageId,
          homePageOwner: homePageId,
        )));
    return appModel;
  }

  List<MenuItemModel> geDrawerMenuItemsFor(Evaluate evaluate) {
    var _welcomePageId =
        evaluate(welcomePageSpecifications) ? WELCOME_PAGE_ID : null;
    var _shopPageId = evaluate(shopPageSpecifications) ? SHOP_PAGE_ID : null;
    var _feedPageId = evaluate(feedPageSpecifications) ? FEED_PAGE_ID : null;
    var _memberDashboardDialogId = evaluate(memberDashboardDialogSpecifications)
        ? MEMBER_DASHBOARD_ID
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
      if (_memberDashboardDialogId != null)
        menuItemManageAccount(appId, _memberDashboardDialogId),
      if (_policyPageId != null)
        menuItem(appId, _policyPageId, 'Policy', Icons.rule),
      if (_shopPageId != null) menuItemShop(appId, _shopPageId, 'Shop'),
      if (_feedPageId != null) menuItemFeed(appId, _feedPageId, 'Feed'),
      if (_hasUnreadChatDialogId != null)
        MenuItemModel(
            documentID: ChatDialogBuilder.IDENTIFIER_MEMBER_HAS_UNREAD_CHAT,
            text: 'Chat',
            description: 'Some unread messages available',
            icon: IconModel(
                codePoint: Icons.chat_bubble_rounded.codePoint,
                fontFamily: Icons.notifications.fontFamily),
            action: OpenDialog(appId,
                dialogID: _hasUnreadChatDialogId,
                conditions: ConditionsModel(
                    privilegeLevelRequired:
                        PrivilegeLevelRequired.NoPrivilegeRequired,
                    packageCondition:
                        ChatPackage.CONDITION_MEMBER_HAS_UNREAD_CHAT))),
      if (_allMessagesHaveBeenReadChatDialog != null)
        MenuItemModel(
            documentID: ChatDialogBuilder.IDENTIFIER_MEMBER_ALL_HAVE_BEEN_READ,
            text: 'Chat',
            description: 'Open chat',
            icon: IconModel(
                codePoint: Icons.chat_bubble_outline_rounded.codePoint,
                fontFamily: Icons.notifications.fontFamily),
            action: OpenDialog(appId,
                dialogID: _allMessagesHaveBeenReadChatDialog,
                conditions: ConditionsModel(
                    privilegeLevelRequired:
                        PrivilegeLevelRequired.NoPrivilegeRequired,
                    packageCondition:
                        ChatPackage.CONDITION_MEMBER_ALL_HAVE_BEEN_READ))),
      if (_signout) menuItemSignOut(appId),
    ];
  }
}

menuItem(appID, pageID, text, IconData iconData) => MenuItemModel(
    documentID: pageID,
    text: text,
    description: text,
    icon: IconModel(
        codePoint: iconData.codePoint, fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID, pageID: pageID));

menuItemSignOut(appID) => MenuItemModel(
    documentID: newRandomKey(),
    text: "Sign out",
    description: "Sign out",
    icon: IconModel(
        codePoint: Icons.power_settings_new.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action:
        InternalAction(appID, internalActionEnum: InternalActionEnum.Logout));

menuItemFlushCache(appID) => MenuItemModel(
    documentID: newRandomKey(),
    text: "Flush cache",
    description: "Flush cache",
    icon: IconModel(
        codePoint: Icons.power_settings_new.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action:
        InternalAction(appID, internalActionEnum: InternalActionEnum.Flush));

menuItemManageAccount(appID, dialogID) => MenuItemModel(
    documentID: dialogID,
    text: 'Manage your account',
    description: 'Manage your account',
    icon: IconModel(
        codePoint: Icons.account_box.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: OpenDialog(appID,
        dialogID: dialogID,
        conditions: ConditionsModel(
            privilegeLevelRequired: PrivilegeLevelRequired.NoPrivilegeRequired,
            packageCondition: CorePackage.MUST_BE_LOGGED_ON)));

menuItemHome(appID, pageID) => MenuItemModel(
    documentID: pageID,
    text: "Home",
    description: "Home",
    icon: IconModel(
        codePoint: Icons.home.codePoint, fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID, pageID: pageID));

menuItemAbout(appID, pageID, text) => MenuItemModel(
    documentID: pageID,
    text: text,
    description: text,
    icon: IconModel(
        codePoint: Icons.info.codePoint, fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID, pageID: pageID));

menuItemFeed(appID, pageID, text) => MenuItemModel(
    documentID: pageID,
    text: text,
    description: text,
    icon: IconModel(
        codePoint: Icons.group.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID, pageID: pageID));

menuItemWelcome(appID, pageID, text) => MenuItemModel(
    documentID: pageID,
    text: text,
    description: text,
    icon: IconModel(
        codePoint: Icons.emoji_people.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID, pageID: pageID));

menuItemShop(appID, pageID, text) => MenuItemModel(
    documentID: pageID,
    text: text,
    description: text,
    icon: IconModel(
        codePoint: Icons.shop.codePoint, fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID, pageID: pageID));

menuItemShoppingBag(appID, pageID, text) => MenuItemModel(
    documentID: pageID,
    text: text,
    description: text,
    icon: IconModel(
        codePoint: Icons.shopping_basket.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID, pageID: pageID));

menuItemShoppingCart(appID, pageID, text) => MenuItemModel(
    documentID: pageID,
    text: text,
    description: text,
    icon: IconModel(
        codePoint: Icons.shopping_cart.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID, pageID: pageID));

menuItemFollowRequests(appID, dialogID) => MenuItemModel(
    documentID: dialogID,
    text: 'Follow requests',
    description: 'Follow requests',
    icon: IconModel(
        codePoint: Icons.favorite_border.codePoint,
        fontFamily: Icons.notifications.fontFamily),
    action: OpenDialog(
      appID,
      dialogID: dialogID,
    ));

menuItemFollowRequestsPage(appID, pageID, privilegeLevelRequired) =>
    MenuItemModel(
        documentID: pageID,
        text: 'Follow Requests',
        description: 'Follow Requests',
        icon: IconModel(
            codePoint: Icons.person.codePoint,
            fontFamily: Icons.notifications.fontFamily),
        action: GotoPage(appID,
            pageID: pageID,
            conditions: ConditionsModel(
                privilegeLevelRequired: privilegeLevelRequired,
                packageCondition:
                    FollowPackage.CONDITION_MEMBER_HAS_OPEN_REQUESTS)));

menuItemFollowers(appID, dialogID, privilegeLevelRequired) => MenuItemModel(
    documentID: dialogID,
    text: 'Followers',
    description: 'Followers',
    icon: IconModel(
        codePoint: Icons.favorite_sharp.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: OpenDialog(appID,
        dialogID: dialogID,
        conditions: ConditionsModel(
            privilegeLevelRequired: privilegeLevelRequired,
            packageCondition: CorePackage.MUST_BE_LOGGED_ON)));

menuItemFollowersPage(appID, pageID, privilegeLevelRequired) => MenuItemModel(
    documentID: pageID,
    text: 'Followers',
    description: 'Followers',
    icon: IconModel(
        codePoint: Icons.favorite_sharp.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID,
        pageID: pageID,
        conditions: ConditionsModel(
            privilegeLevelRequired: privilegeLevelRequired,
            packageCondition: CorePackage.MUST_BE_LOGGED_ON)));

menuItemFollowing(appID, dialogID, privilegeLevelRequired) => MenuItemModel(
    documentID: dialogID,
    text: 'Following',
    description: 'Following',
    icon: IconModel(
        codePoint: Icons.favorite_sharp.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: OpenDialog(appID,
        dialogID: dialogID,
        conditions: ConditionsModel(
            privilegeLevelRequired: privilegeLevelRequired,
            packageCondition: CorePackage.MUST_BE_LOGGED_ON)));

menuItemFollowingPage(appID, pageID, privilegeLevelRequired) => MenuItemModel(
    documentID: pageID,
    text: 'Following',
    description: 'Following',
    icon: IconModel(
        codePoint: Icons.favorite_sharp.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: GotoPage(appID,
        pageID: pageID,
        conditions: ConditionsModel(
            privilegeLevelRequired: privilegeLevelRequired,
            packageCondition: CorePackage.MUST_BE_LOGGED_ON)));

menuItemAppMembers(appID, dialogID, privilegeLevelRequired) => MenuItemModel(
    documentID: dialogID,
    text: 'App Members',
    description: 'Members of the app',
    icon: IconModel(
        codePoint: Icons.people.codePoint,
        fontFamily: Icons.notifications.fontFamily),
    action: OpenDialog(
      appID,
      conditions: ConditionsModel(
          privilegeLevelRequired: privilegeLevelRequired,
          packageCondition: CorePackage.MUST_BE_LOGGED_ON),
      dialogID: dialogID,
    ));

menuItemAppMembersPage(appID, pageID, privilegeLevelRequired) => MenuItemModel(
    documentID: pageID,
    text: 'App Members',
    description: 'Members of the app',
    icon: IconModel(
        codePoint: Icons.people.codePoint,
        fontFamily: Icons.notifications.fontFamily),
    action: GotoPage(
      appID,
      conditions: ConditionsModel(
          privilegeLevelRequired: privilegeLevelRequired,
          packageCondition: CorePackage.MUST_BE_LOGGED_ON),
      pageID: pageID,
    ));

menuItemFiendFriends(appID, dialogID, privilegeLevelRequired) => MenuItemModel(
    documentID: dialogID,
    text: 'Find friends',
    description: 'Fiend friends',
    icon: IconModel(
        codePoint: Icons.favorite_sharp.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action: OpenDialog(appID,
        dialogID: dialogID,
        conditions: ConditionsModel(
            privilegeLevelRequired: privilegeLevelRequired,
            packageCondition: CorePackage.MUST_BE_LOGGED_ON)));

menuItemFiendFriendsPage(appID, pageID, privilegeLevelRequired) =>
    MenuItemModel(
        documentID: pageID,
        text: 'Find friends',
        description: 'Fiend friends',
        icon: IconModel(
            codePoint: Icons.favorite_sharp.codePoint,
            fontFamily: Icons.settings.fontFamily),
        action: GotoPage(appID,
            pageID: pageID,
            conditions: ConditionsModel(
                privilegeLevelRequired: privilegeLevelRequired,
                packageCondition: CorePackage.MUST_BE_LOGGED_ON)));

menuItemJoin(appID, WorkflowModel workflowModel) => MenuItemModel(
    documentID: "join",
    text: "JOIN",
    description: "Request membership",
    icon: null,
    action: WorkflowActionModel(appID,
        conditions: ConditionsModel(
          privilegeLevelRequired: PrivilegeLevelRequired.NoPrivilegeRequired,
          packageCondition: MembershipPackage.MEMBER_HAS_NO_MEMBERSHIP_YET,
        ),
        workflow: workflowModel));
