
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/conditions_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/tools/page/page_helper.dart';
import 'package:eliud_pkg_text/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_text/model/html_component.dart';
import 'package:eliud_pkg_text/model/html_model.dart';


class WelcomePageHelper extends PageHelper {
  WelcomePageHelper(String pageId, AppModel newApp, MemberModel member, HomeMenuModel theHomeMenu, AppBarModel theAppBar, DrawerModel leftDrawer, DrawerModel rightDrawer
      ) : super(pageId, newApp, member, theHomeMenu, theAppBar, leftDrawer, rightDrawer);

  Future<PageModel> create() async {
    // welcome page
    var htmlComponentId = 'html_1';
    await htmlRepository(appId: newAppId())!.add(HtmlModel(
      documentID: htmlComponentId,
      appId: newAppId(),
      name: 'html 1',
      html: '<p>Hello world</p>',
    ));

    var page = PageModel(
      documentID: pageId,
      title: 'Welcome',
      appId: newAppId(),
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
    await pageRepository(appId: newAppId())!.add(page);
    return page;
  }
}
