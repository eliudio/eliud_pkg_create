import 'package:eliud_core/model/abstract_repository_singleton.dart'
    as corerepo;
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/model_export.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/page/page_builder.dart';
import 'package:eliud_pkg_feed/model/feed_menu_component.dart';
import 'package:eliud_pkg_feed/model/header_component.dart';

class OtherFeedPageBuilder extends PageBuilder {
  OtherFeedPageBuilder(
      String pageId,
      AppModel app,
      String memberId,
      HomeMenuModel theHomeMenu,
      AppBarModel theAppBar,
      DrawerModel leftDrawer,
      DrawerModel rightDrawer)
      : super(pageId, app, memberId, theHomeMenu, theAppBar, leftDrawer,
            rightDrawer);

  Future<PageModel> _setupPage(
      {required String componentName,
      required String feedMenuComponentIdentifier,
      required String headerComponentIdentifier,
      required String componentIdentifier,
      required String title}) async {
    return await corerepo.AbstractRepositorySingleton.singleton
        .pageRepository(app.documentID!)!
        .add(_page(
            componentName: componentName,
            feedMenuComponentIdentifier: feedMenuComponentIdentifier,
            headerComponentIdentifier: headerComponentIdentifier,
            componentIdentifier: componentIdentifier,
            title: title));
  }

  PageModel _page(
      {required String componentName,
      required String feedMenuComponentIdentifier,
      required String componentIdentifier,
      required String headerComponentIdentifier,
      required String title}) {
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
        componentName: componentName,
        componentId: componentIdentifier));

    return PageModel(
        documentID: pageId,
        appId: app.documentID!,
        title: title,
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

  Future<PageModel> doIt(
      {required String componentName,
      required String feedMenuComponentIdentifier,
      required String headerComponentIdentifier,
      required String componentIdentifier,
      required String title}) async {
    return await _setupPage(
        componentName: componentName,
        headerComponentIdentifier: headerComponentIdentifier,
        feedMenuComponentIdentifier: feedMenuComponentIdentifier,
        componentIdentifier: componentIdentifier,
        title: title);
  }
}
