import 'package:bloc/bloc.dart';
import 'package:eliud_core_main/model/abstract_repository_singleton.dart';
import 'package:eliud_core_main/model/app_bar_model.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'appbar_event.dart';
import 'appbar_state.dart';

class AppBarCreateBloc extends Bloc<AppBarCreateEvent, AppBarCreateState> {
  final AppBarModel appBarModel;
  final String appId;

  AppBarCreateBloc(
    this.appId,
    AppBarModel initialiseWithAppBar,
  )   : appBarModel = deepCopy(appId, initialiseWithAppBar),
        super(AppBarCreateUninitialised()) {
    on<AppBarCreateEventValidateEvent>((event, emit) {
      // the updates happen on a (deep) copy
      emit(AppBarCreateValidated(deepCopy(appId, event.appBarModel)));
    });

    on<AppBarCreateEventApplyChanges>((event, emit) async {
      var theState = state as AppBarCreateInitialised;
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
    });
  }

  static AppBarModel deepCopy(String appID, AppBarModel from) {
    var documentID = appBarID(appID);
    var iconMenu = copyOrDefault(appID, documentID, from.iconMenu);
    var copyOfAppBarModel = from.copyWith(
        documentID: documentID, iconMenu: iconMenu, title: from.title);
    return copyOfAppBarModel;
  }
}
