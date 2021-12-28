import 'package:eliud_core/model/abstract_repository_singleton.dart'
    as corerepo;
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/model_export.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/page/page_builder.dart';
import 'package:eliud_pkg_feed/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_feed/model/feed_component.dart';
import 'package:eliud_pkg_feed/model/feed_menu_component.dart';
import 'package:eliud_pkg_feed/model/feed_model.dart';
import 'package:eliud_pkg_feed/model/header_component.dart';

import 'components/feed_menu.dart';
import 'components/header_component.dart';
import 'components/profile_component.dart';

class FeedPageBuilder extends PageBuilder {
  FeedPageBuilder(
      String pageId,
      AppModel app,
      String memberId,
      HomeMenuModel theHomeMenu,
      AppBarModel theAppBar,
      DrawerModel leftDrawer,
      DrawerModel rightDrawer)
      : super(pageId, app, memberId, theHomeMenu, theAppBar, leftDrawer,
            rightDrawer);

  Future<PageModel> _setupPage({required String feedMenuComponentIdentifier, required String headerComponentIdentifier}) async {
    return await corerepo.AbstractRepositorySingleton.singleton
        .pageRepository(app.documentID!)!
        .add(_page(feedMenuComponentIdentifier: feedMenuComponentIdentifier, headerComponentIdentifier: headerComponentIdentifier));
  }

  PageModel _page({required String feedMenuComponentIdentifier, required String headerComponentIdentifier}) {
    List<BodyComponentModel> components = [];
    components.add(BodyComponentModel(
        documentID: "1",
        componentName: AbstractFeedMenuComponent.componentName,
        componentId: feedMenuComponentIdentifier));
    components.add(BodyComponentModel(
        documentID: "2",
        componentName: AbstractHeaderComponent.componentName,
        componentId: headerComponentIdentifier));
    components.add(BodyComponentModel(
        documentID: "3",
        componentName: AbstractFeedComponent.componentName,
        componentId: pageId));

    return PageModel(
        documentID: pageId,
        appId: app.documentID!,
        title: "Feed",
        drawer: leftDrawer,
        endDrawer: rightDrawer,
        appBar: theAppBar,
        homeMenu: theHomeMenu,
        layout: PageLayout.ListView,
        conditions: StorageConditionsModel(
          privilegeLevelRequired:
              PrivilegeLevelRequiredSimple.Level1PrivilegeRequiredSimple,
        ),
        bodyComponents: components);
  }

  FeedModel feedModel() =>
     FeedModel(
      documentID: pageId,
      appId: app.documentID!,
      description: "My Feed",
      thumbImage: ThumbStyle.Thumbs,
      photoPost: true,
      videoPost: true,
      messagePost: true,
      audioPost: false,
      albumPost: true,
      articlePost: true,
      conditions: StorageConditionsModel(
          privilegeLevelRequired:
              PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple),
    );

  Future<FeedModel> _setupFeed() async {
    return await AbstractRepositorySingleton.singleton
        .feedRepository(app.documentID!)!
        .add(feedModel());
  }

  Future<FeedModel> run(
      {required String feedMenuComponentIdentifier,
      required String headerComponentIdentifier,
        required String profileComponentIdentifier,

      required String feedPageId,
      required String profilePageId,
      required String followRequestPageId,
      required String followersPageId,
      required String followingPageId,
      required String fiendFriendsPageId,
      required String appMembersPageId}) async {
    var feed = await _setupFeed();
    await FeedMenu(
      app,
      feedPageId: feedPageId,
      profilePageId: profilePageId,
      followRequestPageId: followRequestPageId,
      followersPageId: followersPageId,
      followingPageId: followingPageId,
      fiendFriendsPageId: fiendFriendsPageId,
      appMembersPageId: appMembersPageId,
    ).run(feed: feed, feedMenuComponentIdentifier: feedMenuComponentIdentifier);
    await ProfileComponent(app.documentID!).run(feed: feed, profileComponentId: profileComponentIdentifier);
    await HeaderComponent(app.documentID!)
        .run(feed: feed, headerComponentIdentifier: headerComponentIdentifier);

    // Specific to feed page
    await _setupPage(feedMenuComponentIdentifier: feedMenuComponentIdentifier, headerComponentIdentifier: headerComponentIdentifier, );
    return feed;
  }
}
