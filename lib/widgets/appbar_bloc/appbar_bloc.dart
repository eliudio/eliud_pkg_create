import 'package:bloc/bloc.dart';
import 'package:eliud_core/core/components/page_constructors/eliud_appbar.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:eliud_pkg_etc/widgets/decorator/can_refresh.dart';
import 'appbar_event.dart';
import 'appbar_state.dart';

class AppBarCreateBloc extends Bloc<AppBarCreateEvent, AppBarCreateState> {
  final AppBarModel originalAppBarModel;
  final AppBarModel appBarModelCurrentApp;
  final String appId;
  final CanRefresh? canRefresh;

  AppBarCreateBloc(this.appId, this.appBarModelCurrentApp, this.canRefresh)
      : originalAppBarModel = deepCopy(appId, appBarModelCurrentApp), super(AppBarCreateUninitialised());

  @override
  Stream<AppBarCreateState> mapEventToState(AppBarCreateEvent event) async* {
    if (event is AppBarCreateEventValidateEvent) {
      // the updates happen on a (deep) copy
      yield AppBarCreateValidated(deepCopy(appId, event.appBarModel));
    } else if (state is AppBarCreateInitialised) {
      var theState = state as AppBarCreateInitialised;
      if (event is AppBarCreateEventApplyChanges) {
        appBarModelCurrentApp.iconMenu = theState.appBarModel.iconMenu;
        if (event.save) {
          var appBar = await appBarRepository(appId: appBarModelCurrentApp.appId)!
              .get(theState.appBarModel.documentID);
          if (appBar == null) {
            await appBarRepository(appId: appBarModelCurrentApp.appId)!
                .add(theState.appBarModel);
          } else {
            await appBarRepository(appId: appBarModelCurrentApp.appId)!
                .update(theState.appBarModel);
          }

          var menuDef = await menuDefRepository(appId: appBarModelCurrentApp.appId)!
              .get(theState.appBarModel.iconMenu!.documentID);
          if (menuDef == null) {
            await menuDefRepository(appId: appBarModelCurrentApp.appId)!
                .add(theState.appBarModel.iconMenu!);
          } else {
            await menuDefRepository(appId: appBarModelCurrentApp.appId)!
                .update(theState.appBarModel.iconMenu!);
          }
        }
        if (canRefresh != null) {
          canRefresh!.refresh();
        }
      } else if (event is AppBarCreateEventRevertChanges) {
        // we could just refresh the app, give we haven't saved anything. However, more efficient is :
        appBarModelCurrentApp.iconMenu = originalAppBarModel.iconMenu;
        appBarModelCurrentApp.title = originalAppBarModel.title;
        if (canRefresh != null) {
          canRefresh!.refresh();
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
