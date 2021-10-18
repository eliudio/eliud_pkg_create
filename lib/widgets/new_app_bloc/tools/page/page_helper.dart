
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/conditions_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_pkg_text/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_text/model/html_component.dart';
import 'package:eliud_pkg_text/model/html_model.dart';

class PageHelper {
  final String pageId;
  final AppModel newApp;
  final MemberModel member;
  final HomeMenuModel theHomeMenu;
  final AppBarModel theAppBar;
  final DrawerModel leftDrawer;
  final DrawerModel rightDrawer;

  PageHelper(this.pageId, this.newApp, this.member, this.theHomeMenu, this.theAppBar, this.leftDrawer, this.rightDrawer);

  String newAppId() => newApp.documentID!;

  String memberId() => member.documentID!;
}