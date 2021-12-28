import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/model_export.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_pkg_follow/model/follow_requests_dashboard_component.dart';
import 'package:eliud_pkg_follow/model/following_dashboard_component.dart';
import 'package:eliud_pkg_follow/model/invite_dashboard_component.dart';
import 'package:eliud_pkg_follow/model/model_export.dart';
import 'package:eliud_pkg_membership/model/membership_dashboard_component.dart';
import 'components/follow_dashboards.dart';
import 'other_feed_pages_builder.dart';

class FollowersDashboardPageBuilder extends OtherFeedPageBuilder {
  FollowersDashboardPageBuilder(
      String pageId,
      AppModel app,
      String memberId,
      HomeMenuModel theHomeMenu,
      AppBarModel theAppBar,
      DrawerModel leftDrawer,
      DrawerModel rightDrawer)
      : super(pageId, app, memberId, theHomeMenu, theAppBar, leftDrawer,
            rightDrawer);

  Future<PageModel> run(
      {required String componentIdentifier,
      required String feedMenuComponentIdentifier,
      required String headerComponentIdentifier,
      required String profilePageId,
      required String feedPageId}) async {
    await FollowingDashboard(app, componentIdentifier, "Followers",
            FollowingView.Followers, profilePageId, feedPageId)
        .run();
    return await doIt(
        componentName: AbstractFollowingDashboardComponent.componentName,
        feedMenuComponentIdentifier: feedMenuComponentIdentifier,
        headerComponentIdentifier: headerComponentIdentifier,
        componentIdentifier: componentIdentifier,
        title: "Followers");
  }
}
