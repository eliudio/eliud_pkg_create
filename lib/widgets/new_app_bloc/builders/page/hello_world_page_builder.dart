import 'package:eliud_core/core/wizards/builders/page_builder.dart';
import 'package:eliud_core/core/wizards/registry/registry.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_pkg_text/wizards/builders/page/page_with_text.dart';

class HelloWorldPageBuilder extends PageBuilder {
  HelloWorldPageBuilder(
    String uniqueId,
    String pageId,
    AppModel app,
    String memberId,
    HomeMenuModel theHomeMenu,
    AppBarModel theAppBar,
    DrawerModel leftDrawer,
    DrawerModel rightDrawer,
  ) : super(
          uniqueId,
          pageId,
          app,
          memberId,
          theHomeMenu,
          theAppBar,
          leftDrawer,
          rightDrawer,
        );

  Future<PageModel> create() async {
    return PageWithTextBuilder(
      uniqueId,
      'Hello',
      'Hello world',
      'Hello world',
      pageId,
      app,
      memberId,
      theHomeMenu,
      theAppBar,
      leftDrawer,
      rightDrawer,
    ).create();
  }
}
