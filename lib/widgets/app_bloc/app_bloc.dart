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
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppCreateBloc extends Bloc<AppCreateEvent, AppCreateState> {
  final AppModel originalAppModel;
  final AppModel appModelCurrentApp;
  final String appId;

  AppCreateBloc(this.appId, this.appModelCurrentApp, )
      : originalAppModel = deepCopy(appId, appModelCurrentApp),
        super(AppCreateUninitialised());

  @override
  Stream<AppCreateState> mapEventToState(AppCreateEvent event) async* {
    if (event is AppCreateEventValidateEvent) {
      List<PageModel?> pages =
          await pageRepository(appId: appId)!.valuesList();
      List<DialogModel?> dialogs =
          await dialogRepository(appId: appId)!.valuesList();

      var theHomeMenu = await homeMenu(appId, store: true);
      var theAppBar = await appBar(appId);
      var leftDrawer = await getDrawer(appId, DrawerType.Left, store: true);
      var rightDrawer = await getDrawer(appId, DrawerType.Right, store: true);

      yield AppCreateValidated(deepCopy(appId, event.appModel), pages, dialogs,
          theHomeMenu, theAppBar, leftDrawer, rightDrawer);
    } else if (state is AppCreateInitialised) {
      var theState = state as AppCreateInitialised;
      if (event is AppCreateEventApplyChanges) {
        // check other blocks for implementation
        appModelCurrentApp.email = theState.appModel.email;
        appModelCurrentApp.description = theState.appModel.description;
        appModelCurrentApp.policies = theState.appModel.policies;
        appModelCurrentApp.title = theState.appModel.title;
        appModelCurrentApp.logo = theState.appModel.logo;
        appModelCurrentApp.homePages = theState.appModel.homePages;
        appModelCurrentApp.appStatus = theState.appModel.appStatus;
        appModelCurrentApp.routeAnimationDuration =
            theState.appModel.routeAnimationDuration;
        appModelCurrentApp.routeBuilder = theState.appModel.routeBuilder;
        if (event.save) {
          var app = await appRepository(appId: appId)!
              .get(theState.appModel.documentID);
          if (app == null) {
            await appRepository(appId: appId)!.add(theState.appModel);
          } else {
            await appRepository(appId: appId)!.update(theState.appModel);
          }
        }
      } else if (event is AppCreateEventRevertChanges) {
        // we could just refresh the app, give we haven't saved anything. However, more efficient is :
        appModelCurrentApp.email = originalAppModel.email;
        appModelCurrentApp.description = originalAppModel.description;
        appModelCurrentApp.policies = originalAppModel.policies;
        appModelCurrentApp.title = originalAppModel.title;
        appModelCurrentApp.logo = originalAppModel.logo;
        appModelCurrentApp.homePages = originalAppModel.homePages;
        appModelCurrentApp.appStatus = originalAppModel.appStatus;
        appModelCurrentApp.routeAnimationDuration =
            originalAppModel.routeAnimationDuration;
        appModelCurrentApp.routeBuilder = originalAppModel.routeBuilder;
      }
    }
  }

  static AppModel deepCopy(String appID, AppModel from) {
    var homePages = from.homePages ?? AppHomePageReferencesModel();
    var policies = from.policies ?? AppPolicyModel(documentID: newRandomKey());
    policies.policies = policies.policies == null ? [] : policies.policies!.map((v) => v).toList();
    var copyOfAppModel = from.copyWith(
        documentID: appID,
        homePages: homePages,
        policies: policies,
        title: from.title);
    return copyOfAppModel;
  }
}
