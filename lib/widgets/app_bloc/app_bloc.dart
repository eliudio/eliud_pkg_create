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

  AppCreateBloc(
    this.appId,
    AppModel initialiseWithApp,
  )   : appModel = deepCopy(appId, initialiseWithApp),
        super(AppCreateUninitialised()) {
    on<AppCreateEventValidateEvent>((event, emit) async {
      var pages = <PageModel?>[];
      {
        var countDown = 3;
        while (countDown >= 0) {
          pages.addAll(await pageRepository(appId: appId)!
              .valuesList(privilegeLevel: countDown));
          countDown--;
        }
      }
      var dialogs = <DialogModel?>[];
      {
        var countDown = 3;
        while (countDown >= 0) {
          dialogs.addAll(await dialogRepository(appId: appId)!
              .valuesList(privilegeLevel: countDown));
          countDown--;
        }
      }

      var theHomeMenu = await homeMenu(appId, store: true);
      var theAppBar = await appBar(appId);
      var leftDrawer = await getDrawer(appId, DrawerType.Left, store: true);
      var rightDrawer = await getDrawer(appId, DrawerType.Right, store: true);

      emit(AppCreateValidated(deepCopy(appId, event.appModel), pages, dialogs,
          theHomeMenu, theAppBar, leftDrawer, rightDrawer));
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
