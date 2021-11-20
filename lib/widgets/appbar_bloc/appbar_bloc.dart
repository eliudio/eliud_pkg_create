import 'package:bloc/bloc.dart';
import 'package:eliud_core/core/components/page_constructors/eliud_appbar.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'appbar_event.dart';
import 'appbar_state.dart';

class AppBarCreateBloc extends Bloc<AppBarCreateEvent, AppBarCreateState> {
  final AppBarModel appBarModel;
  final String appId;

  AppBarCreateBloc(this.appId, AppBarModel initialiseWithAppBar, )
      : appBarModel = deepCopy(appId, initialiseWithAppBar), super(AppBarCreateUninitialised());

  @override
  Stream<AppBarCreateState> mapEventToState(AppBarCreateEvent event) async* {
    if (event is AppBarCreateEventValidateEvent) {
      // the updates happen on a (deep) copy
      yield AppBarCreateValidated(deepCopy(appId, event.appBarModel));
    } else if (state is AppBarCreateInitialised) {
      var theState = state as AppBarCreateInitialised;
      if (event is AppBarCreateEventApplyChanges) {
        appBarModel.iconMenu = theState.appBarModel.iconMenu;
        if (event.save) {
          var appBar = await appBarRepository(appId: appBarModel.appId)!
              .get(theState.appBarModel.documentID);
          if (appBar == null) {
            await appBarRepository(appId: appBarModel.appId)!
                .add(theState.appBarModel);
          } else {
            await appBarRepository(appId: appBarModel.appId)!
                .update(theState.appBarModel);
          }

          var menuDef = await menuDefRepository(appId: appBarModel.appId)!
              .get(theState.appBarModel.iconMenu!.documentID);
          if (menuDef == null) {
            await menuDefRepository(appId: appBarModel.appId)!
                .add(theState.appBarModel.iconMenu!);
          } else {
            await menuDefRepository(appId: appBarModel.appId)!
                .update(theState.appBarModel.iconMenu!);
          }
        }
      }
    }
  }
  
  static AppBarModel deepCopy(String appID, AppBarModel from) {
    var documentID = appBarID(appID);
    var iconMenu = copyOrDefault(documentID, from.iconMenu);
    var copyOfAppBarModel = from.copyWith(documentID: documentID, iconMenu: iconMenu, title: from.title);
    return copyOfAppBarModel;
  }
}
