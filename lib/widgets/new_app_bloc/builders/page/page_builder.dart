import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';

class PageBuilder {
  final String pageId;
  final AppModel app;
  final String memberId;
  final HomeMenuModel theHomeMenu;
  final AppBarModel theAppBar;
  final DrawerModel leftDrawer;
  final DrawerModel rightDrawer;

  PageBuilder(this.pageId, this.app, this.memberId, this.theHomeMenu, this.theAppBar, this.leftDrawer, this.rightDrawer);
}