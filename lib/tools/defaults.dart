import 'package:eliud_pkg_workflow/model/workflow_model.dart';
import 'package:eliud_pkg_workflow/model/workflow_notification_model.dart';
import 'package:eliud_pkg_workflow/model/workflow_task_model.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_core/tools/random.dart';

String drawerID(String appID, DrawerType drawerType) {
  return appID +
      '-DRAWER' +
      (drawerType == DrawerType.Left ? '-LEFT' : '-RIGHT');
}

String homeMenuID(String appID) {
  return appID + '-HOMEMENU';
}

String appBarID(String appID) {
  return appID + '-APPBAR';
}

String appID(String appID) {
  return appID;
}

MenuDefModel copyOrDefault(String appId, String documentID, MenuDefModel? menuDefModel) {
  if (menuDefModel == null) {
    return newMenuDef(appId, documentID);
  } else {
    if (menuDefModel.menuItems == null) {
      return menuDefModel.copyWith(menuItems: []);
    } else {
      return menuDefModel.copyWith(menuItems: List.of(menuDefModel.menuItems!));
    }
  }
}

Future<HomeMenuModel> homeMenu(String appId, {bool? store}) async {
  var homeMenuId = homeMenuID(appId);
  var homeMenu = await homeMenuRepository(appId: appId)!.get(homeMenuId);
  if (homeMenu == null) {
    return newHomeMenu(appId, store: store);
  } else {
    return homeMenu;
  }
}

MenuDefModel newMenuDef(String appId, String id) => new MenuDefModel(
      documentID: id,
      appId: appId,
      name: 'no name',
      menuItems: [],
      admin: false,
    );

Future<HomeMenuModel> newHomeMenu(String appId, {bool? store}) async {
  var homeMenuId = homeMenuID(appId);
  var menuDefModel = await menuDefRepository(appId: appId)!.get(homeMenuId);
  if (menuDefModel == null) {
    menuDefModel = newMenuDef(appId, homeMenuId);
    await menuDefRepository(appId: appId)!.add(menuDefModel);
  }
  var homeMenuModel =
      HomeMenuModel(documentID: homeMenuId, appId: appId, menu: menuDefModel);
  if ((store != null) && (store)) {
    await homeMenuRepository(appId: appId)!.add(homeMenuModel);
  }
  return homeMenuModel;
}

Future<AppBarModel> appBar(String appId, {bool? store}) async {
  var appBarId = appBarID(appId);
  var appBar = await appBarRepository(appId: appId)!.get(appBarId);
  if (appBar == null) {
    return newAppBar(appId, store: store);
  } else {
    return appBar;
  }
}

Future<AppBarModel> newAppBar(String appId, {bool? store}) async {
  var appBarId = appBarID(appId);
  var menuDefModel = await menuDefRepository(appId: appId)!.get(appBarId);
  if (menuDefModel == null) {
    menuDefModel = newMenuDef(appId, appBarId);
    await menuDefRepository(appId: appId)!.add(menuDefModel);
  }
  var appBarModel = AppBarModel(
      documentID: appBarId,
      appId: appId,
      header: HeaderSelection.Title,
      iconMenu: menuDefModel);
  if ((store != null) && (store)) {
    await appBarRepository(appId: appId)!.add(appBarModel);
  }
  return appBarModel;
}

Future<DrawerModel> getDrawer(String appId, DrawerType drawerType,
    {bool? store}) async {
  var drawerId = drawerID(appId, drawerType);
  var drawer = await drawerRepository(appId: appId)!.get(drawerId);
  if (drawer == null) {
    return newDrawer(appId, drawerType, store: store);
  } else {
    return drawer;
  }
}

Future<DrawerModel> newDrawer(String appId, DrawerType drawerType,
    {bool? store}) async {
  var drawerId = drawerID(appId, drawerType);
  var menuDefModel = await menuDefRepository(appId: appId)!.get(drawerId);
  if (menuDefModel == null) {
    menuDefModel = newMenuDef(appId, drawerId);
    await menuDefRepository(appId: appId)!.add(menuDefModel);
  }
  var drawerModel =
      DrawerModel(documentID: drawerId, appId: appId, menu: menuDefModel);
  if ((store != null) && (store)) {
    await drawerRepository(appId: appId)!.add(drawerModel);
  }
  return drawerModel;
}

PageModel newPageDefaults(String appId) => PageModel(
    documentID: newRandomKey(),
    bodyComponents: [],
    appId: appId,
    conditions: null,
    layout: PageLayout.ListView);

DialogModel newDialogDefaults(String appId) => DialogModel(
    documentID: newRandomKey(),
    bodyComponents: [],
    appId: appId,
    conditions: null,
    layout: DialogLayout.ListView);

WorkflowModel newWorkflowDefaults(String appId) => WorkflowModel(
      documentID: newRandomKey(),
      appId: appId,
      name: 'New workflow',
      workflowTask: [],
    );

WorkflowTaskModel newWorkflowTaskDefaults() => WorkflowTaskModel(
    documentID: newRandomKey(),
    seqNumber: 0,
    task: null,
    confirmMessage: WorkflowNotificationModel(message: '', addressee: WorkflowNotificationAddressee.CurrentMember),
    rejectMessage: WorkflowNotificationModel(message: '', addressee: WorkflowNotificationAddressee.CurrentMember),
    responsible: WorkflowTaskResponsible.CurrentMember
);

