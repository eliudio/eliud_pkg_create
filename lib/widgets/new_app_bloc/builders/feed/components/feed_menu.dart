import 'package:eliud_core/model/abstract_repository_singleton.dart'
    as coreRepo;
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/model_export.dart';
import 'package:eliud_core/tools/action/action_model.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/helpers/menu_helpers.dart';
import 'package:eliud_pkg_feed/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_feed/model/feed_menu_model.dart';
import 'package:eliud_pkg_feed/model/feed_model.dart';
import 'package:flutter/material.dart';

class FeedMenu {
  final String appId;
  final String feedPageId;
  final String profilePageId;
  final String followRequestPageId;
  final String followersPageId;
  final String followingPageId;
  final String fiendFriendsPageId;
  final String appMembersPageId;

  FeedMenu(this.appId,
      {required this.feedPageId,
      required this.profilePageId,
      required this.followRequestPageId,
      required this.followersPageId,
      required this.followingPageId,
      required this.fiendFriendsPageId,
      required this.appMembersPageId});

  static String FEED_MENU_ID_CURRENT_MEMBER = "feedMenuCurrentMember";
  static String FEED_MENU_ID_OTHER_MEMBER = "feedMenuOtherMember";

  MenuItemModel feedMenuItem() => MenuItemModel(
      documentID: '1',
      text: 'Feed',
      description: 'Your Feed',
      icon: IconModel(
          codePoint: Icons.people.codePoint,
          fontFamily: Icons.settings.fontFamily),
      action: GotoPage(appId, pageID: feedPageId));

  MenuItemModel profileMenuItem() => MenuItemModel(
      documentID: '2',
      text: 'Profile',
      description: 'Your profile',
      icon: IconModel(
          codePoint: Icons.person.codePoint,
          fontFamily: Icons.settings.fontFamily),
      action: GotoPage(appId, pageID: profilePageId));

  MenuDefModel menuDefCurrentMember() {
    var menuItems = <MenuItemModel>[
      feedMenuItem(),
      profileMenuItem(),
      menuItemFollowRequestsPage(appId, followRequestPageId,
          PrivilegeLevelRequired.NoPrivilegeRequired),
      menuItemFollowersPage(
          appId, followersPageId, PrivilegeLevelRequired.NoPrivilegeRequired),
      menuItemFollowingPage(
          appId, followingPageId, PrivilegeLevelRequired.NoPrivilegeRequired),
      menuItemFiendFriendsPage(appId, fiendFriendsPageId,
          PrivilegeLevelRequired.NoPrivilegeRequired),
      menuItemAppMembersPage(appId, appMembersPageId,
          PrivilegeLevelRequired.OwnerPrivilegeRequired),
    ];
    MenuDefModel menu = MenuDefModel(
        documentID: FEED_MENU_ID_CURRENT_MEMBER,
        appId: appId,
        name: "Current Member Feed Menu",
        menuItems: menuItems);
    return menu;
  }

  MenuDefModel menuDefOtherMember() {
    var menuItems = <MenuItemModel>[
      feedMenuItem(),
      profileMenuItem(),
    ];
    MenuDefModel menu = MenuDefModel(
        documentID: FEED_MENU_ID_OTHER_MEMBER,
        appId: appId,
        name: "Other Member Feed Menu",
        menuItems: menuItems);
    return menu;
  }

  Future<MenuDefModel> createMenuDefCurrentMember() async {
    return await coreRepo.AbstractRepositorySingleton.singleton
        .menuDefRepository(appId)!
        .add(menuDefCurrentMember());
  }

  Future<MenuDefModel> createMenuDefOtherMember() async {
    return await coreRepo.AbstractRepositorySingleton.singleton
        .menuDefRepository(appId)!
        .add(menuDefOtherMember());
  }

  FeedMenuModel feedMenuModel({
    required FeedModel feed,
    required String feedMenuComponentIdentifier,
    required MenuDefModel menuCurrentMember,
    required MenuDefModel menuOtherMember,
  }) {
    return FeedMenuModel(
      documentID: feedMenuComponentIdentifier,
      appId: appId,
      description: "Feed Menu",
      feed: feed,
      menuCurrentMember: menuCurrentMember,
      menuOtherMember: menuOtherMember,
      //itemColor: EliudColors.black,
      //selectedItemColor: EliudColors.red,
      conditions: StorageConditionsModel(
          privilegeLevelRequired:
              PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple),
    );
  }

  Future<FeedMenuModel> createFeedMenuModel({
    required FeedModel feed,
    required String feedMenuComponentIdentifier,
    required MenuDefModel menuCurrentMember,
    required MenuDefModel menuOtherMember,
  }) async {
    return await AbstractRepositorySingleton.singleton
        .feedMenuRepository(appId)!
        .add(feedMenuModel(
            feed: feed,
            feedMenuComponentIdentifier: feedMenuComponentIdentifier,
            menuCurrentMember: menuCurrentMember,
            menuOtherMember: menuOtherMember));
  }

  Future<void> run({
    required FeedModel feed,
    required String feedMenuComponentIdentifier,
  }) async {
    var menuDefCurrentMember = await createMenuDefCurrentMember();
    var menuDefOtherMember = await createMenuDefOtherMember();
    await createFeedMenuModel(
        feed: feed,
        feedMenuComponentIdentifier: feedMenuComponentIdentifier,
        menuCurrentMember: menuDefCurrentMember,
        menuOtherMember: menuDefOtherMember);
  }
}
