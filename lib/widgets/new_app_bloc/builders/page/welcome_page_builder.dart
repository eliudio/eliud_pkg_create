import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/conditions_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'page_builder.dart';
import 'package:eliud_pkg_text/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_text/model/html_component.dart';
import 'package:eliud_pkg_text/model/html_model.dart';

class WelcomePageBuilder extends PageBuilder {
  WelcomePageBuilder(
      String pageId,
      String appId,
      String memberId,
      HomeMenuModel theHomeMenu,
      AppBarModel theAppBar,
      DrawerModel leftDrawer,
      DrawerModel rightDrawer)
      : super(pageId, appId, memberId, theHomeMenu, theAppBar, leftDrawer,
            rightDrawer);

  Future<PageModel> create() async {
    // welcome page
    var htmlComponentId = 'html_1';
    await htmlRepository(appId: appId)!.add(HtmlModel(
      documentID: htmlComponentId,
      appId: appId,
      name: 'html 1',
      html: '<p>Hello world</p>',
    ));

    var page = PageModel(
      documentID: pageId,
      title: 'Welcome',
      appId: appId,
      bodyComponents: [
        BodyComponentModel(
            documentID: "1",
            componentName: AbstractHtmlComponent.componentName,
            componentId: htmlComponentId)
      ],
      layout: PageLayout.ListView,
      appBar: theAppBar,
      homeMenu: theHomeMenu,
      drawer: leftDrawer,
      endDrawer: rightDrawer,
      conditions: ConditionsModel(
          privilegeLevelRequired: PrivilegeLevelRequired.NoPrivilegeRequired),
    );
    await pageRepository(appId: appId)!.add(page);
    return page;
  }
}
