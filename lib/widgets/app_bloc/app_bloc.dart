import 'package:bloc/bloc.dart';
import 'package:eliud_core/core/components/page_constructors/eliud_appbar.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_home_page_references_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/app_policy_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import 'package:eliud_core/tools/query/query_tools.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppCreateBloc extends Bloc<AppCreateEvent, AppCreateState> {
  final AppModel appModel;
  final String appId;

  static EliudQuery getQuery() {
    return EliudQuery(theConditions: [
      EliudQueryCondition('conditions.privilegeLevelRequired', isEqualTo: 3),
    ]);
  }

  String comparable(String? title) => title == null ? '?' : title.toLowerCase();

  Future<List<PageModel>> _pages() async {
    var pages = <PageModel>[];
    {
      var countDown = 3;
      while (countDown >= 0) {
        var newPages = await pageRepository(appId: appId)!.valuesList(
            eliudQuery: getComponentSelectorQuery(countDown, appId));
        pages.addAll(newPages.map((e) => e!).toList());
        countDown--;
      }
    }
    pages.sort((a, b) => (comparable(a.title) + a.documentID)
        .compareTo((comparable(b.title) + b.documentID)));
    return pages;

  }

  Future<List<DialogModel>> _dialogs() async {
    var dialogs = <DialogModel>[];
    {
      var countDown = 3;
      while (countDown >= 0) {
        var newDialogs = await dialogRepository(appId: appId)!
            .valuesList(privilegeLevel: countDown);
        dialogs.addAll(newDialogs.map((d) => d!).toList());
        countDown--;
      }
    }
    dialogs.sort((a, b) => (comparable(a.title) + a.documentID)
        .compareTo((comparable(b.title) + b.documentID)));
    return dialogs;
  }

  AppCreateBloc(
    this.appId,
    AppModel initialiseWithApp,
  )   : appModel = deepCopy(appId, initialiseWithApp),
        super(AppCreateUninitialised()) {
    on<AppCreateEventValidateEvent>((event, emit) async {
      var pages = await _pages();
      var dialogs = await _dialogs();
      var theHomeMenu = await homeMenu(appId, store: true);
      var theAppBar = await appBar(appId);
      var leftDrawer = await getDrawer(appId, DrawerType.Left, store: true);
      var rightDrawer = await getDrawer(appId, DrawerType.Right, store: true);

      emit(AppCreateValidated(deepCopy(appId, event.appModel), pages, dialogs,
          theHomeMenu, theAppBar, leftDrawer, rightDrawer));
    });

    on<AppCreateDeletePage>((event, emit) async {
      if (state is AppCreateInitialised) {
        var appCreateInitialised = state as AppCreateInitialised;
        var page = event.deleteThis;
        await pageRepository(appId: appId)!.delete(page);
        var pages = await _pages();
        emit(AppCreateValidated(
            appCreateInitialised.appModel,
            pages,
            appCreateInitialised.dialogs,
            appCreateInitialised.homeMenuModel,
            appCreateInitialised.appBarModel,
            appCreateInitialised.leftDrawerModel,
            appCreateInitialised.rightDrawerModel));
      }
    });

    on<AppCreateDeleteDialog>((event, emit) async {
      if (state is AppCreateInitialised) {
        var appCreateInitialised = state as AppCreateInitialised;
        var dialog = event.deleteThis;
        await dialogRepository(appId: appId)!.delete(dialog);
        var dialogs = await _dialogs();
        emit(AppCreateValidated(
            appCreateInitialised.appModel,
            appCreateInitialised.pages,
            dialogs,
            appCreateInitialised.homeMenuModel,
            appCreateInitialised.appBarModel,
            appCreateInitialised.leftDrawerModel,
            appCreateInitialised.rightDrawerModel));
      }
    });

    on<AppCreateEventApplyChanges>((event, emit) async {
      var theState = state as AppCreateInitialised;
      // check other blocks for implementation
      appModel.email = theState.appModel.email;
      appModel.description = theState.appModel.description;
      appModel.policies = theState.appModel.policies;
      appModel.title = theState.appModel.title;
      appModel.logo = theState.appModel.logo;
      appModel.homePages = theState.appModel.homePages;
      appModel.appStatus = theState.appModel.appStatus;
      if (event.save) {
        var app = await appRepository(appId: appId)!
            .get(theState.appModel.documentID);
        if (app == null) {
          await appRepository(appId: appId)!.add(theState.appModel);
        } else {
          await appRepository(appId: appId)!.update(theState.appModel);
        }

        if (appModel.policies != null) {
          appPolicyRepository(appId: appId)!.update(appModel.policies!);
        }
      }
    });
  }

  static AppModel deepCopy(String appID, AppModel from) {
    var homePages = from.homePages ?? AppHomePageReferencesModel();
    var policies = from.policies ??
        AppPolicyModel(documentID: newRandomKey(), appId: appID);
    policies.policies = policies.policies == null
        ? []
        : policies.policies!.map((v) => v).toList();
    var copyOfAppModel = from.copyWith(
        documentID: appID,
        homePages: homePages,
        policies: policies,
        title: from.title);
    return copyOfAppModel;
  }
}
