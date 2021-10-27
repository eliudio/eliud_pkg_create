import 'package:eliud_core/model/abstract_repository_singleton.dart'
    as corerepo;
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/model_export.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/page/page_builder.dart';
import 'package:eliud_pkg_feed/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_feed/model/feed_menu_component.dart';
import 'package:eliud_pkg_feed/model/feed_model.dart';
import 'package:eliud_pkg_feed/model/header_component.dart';
import 'package:eliud_pkg_feed/model/profile_component.dart';
import 'package:eliud_pkg_feed/model/profile_model.dart';

class ProfilePageBuilder extends PageBuilder {
  ProfilePageBuilder(
      String pageId,
      String appId,
      String memberId,
      HomeMenuModel theHomeMenu,
      AppBarModel theAppBar,
      DrawerModel leftDrawer,
      DrawerModel rightDrawer)
      : super(pageId, appId, memberId, theHomeMenu, theAppBar, leftDrawer,
            rightDrawer);

  Future<PageModel> _setupPage({
    required String profileComponentIdentifier,
    required String feedMenuComponentIdentifier,
    required String headerComponentIdentifier,
  }) async {
    return await corerepo.AbstractRepositorySingleton.singleton
        .pageRepository(appId)!
        .add(_page(
          profileComponentIdentifier: profileComponentIdentifier,
          feedMenuComponentIdentifier: feedMenuComponentIdentifier,
          headerComponentIdentifier: headerComponentIdentifier,
        ));
  }

  PageModel _page(
      {required String profileComponentIdentifier,
      required String feedMenuComponentIdentifier,
      required String headerComponentIdentifier}) {
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
        componentName: AbstractProfileComponent.componentName,
        componentId: profileComponentIdentifier));

    return PageModel(
        documentID: pageId,
        appId: appId,
        title: "Profile",
        drawer: leftDrawer,
        endDrawer: rightDrawer,
        appBar: theAppBar,
        homeMenu: theHomeMenu,
        layout: PageLayout.ListView,
        conditions: ConditionsModel(
          privilegeLevelRequired:
              PrivilegeLevelRequired.Level1PrivilegeRequired,
        ),
        bodyComponents: components);
  }

  ProfileModel profileModel(
      {required FeedModel feed, required String profileComponentIdentifier}) {
    return ProfileModel(
      documentID: profileComponentIdentifier,
      feed: feed,
      appId: appId,
      description: "My Profile",
      conditions: ConditionsSimpleModel(
          privilegeLevelRequired:
              PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple),
    );
  }

  Future<ProfileModel> _setupProfile(
      {required FeedModel feed,
      required String profileComponentIdentifier}) async {
    return await AbstractRepositorySingleton.singleton
        .profileRepository(appId)!
        .add(profileModel(
            feed: feed,
            profileComponentIdentifier: profileComponentIdentifier));
  }

  Future<PageModel> run(
      {required MemberModel member,
      required FeedModel feed,
      required String profileComponentIdentifier,
      required String feedMenuComponentIdentifier,
      required String headerComponentIdentifier}) async {
    await _setupProfile(
        feed: feed, profileComponentIdentifier: profileComponentIdentifier);
    return await _setupPage(
        profileComponentIdentifier: profileComponentIdentifier,
        feedMenuComponentIdentifier: feedMenuComponentIdentifier,
        headerComponentIdentifier: headerComponentIdentifier
    );
  }
}
