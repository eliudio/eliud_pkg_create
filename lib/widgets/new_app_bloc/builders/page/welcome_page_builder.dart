import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/page/page_with_text.dart';
import 'page_builder.dart';

class WelcomePageBuilder extends PageBuilder {
  WelcomePageBuilder(
      String pageId,
      AppModel app,
      String memberId,
      HomeMenuModel theHomeMenu,
      AppBarModel theAppBar,
      DrawerModel leftDrawer,
      DrawerModel rightDrawer)
      : super(pageId, app, memberId, theHomeMenu, theAppBar, leftDrawer,
            rightDrawer);

  Future<PageModel> create() async {
    return PageWithTextBuilder('Welcome', 'Hello world', pageId, app, memberId, theHomeMenu, theAppBar, leftDrawer, rightDrawer).create();
  }
}
