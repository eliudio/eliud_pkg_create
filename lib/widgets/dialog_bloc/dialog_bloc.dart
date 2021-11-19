import 'package:bloc/bloc.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/background_model.dart';
import 'package:eliud_core/model/conditions_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:flutter/material.dart';
import 'dialog_event.dart';
import 'dialog_state.dart';

class DialogCreateBloc extends Bloc<DialogCreateEvent, DialogCreateState> {
  final DialogModel originalDialogModel;
  final DialogModel dialogModelCurrentApp;
  final String appId;
  final VoidCallback? callOnAction;

  DialogCreateBloc(this.appId, this.dialogModelCurrentApp, this.callOnAction)
      : originalDialogModel = deepCopy(dialogModelCurrentApp),
        super(DialogCreateUninitialised());

  @override
  Stream<DialogCreateState> mapEventToState(DialogCreateEvent event) async* {
    if (event is DialogCreateEventValidateEvent) {
      // convention is that the ID of the appBar, drawers and home menu are the same ID as that of the app
      var _homeMenuId = homeMenuID(appId);

      event.dialogModel.conditions ??= ConditionsModel(
            privilegeLevelRequired: PrivilegeLevelRequired.NoPrivilegeRequired,
            packageCondition: '',
            conditionOverride: null);
      // the updates happen on a (deep) copy
      yield DialogCreateValidated(deepCopy(event.dialogModel));
    } else if (state is DialogCreateInitialised) {
      var theState = state as DialogCreateInitialised;
      if (event is DialogCreateEventApplyChanges) {
        var dialog = await dialogRepository(appId: theState.dialogModel.appId)!
            .get(theState.dialogModel.documentID);
        if (dialog == null) {
          await dialogRepository(appId: theState.dialogModel.appId)!
              .add(theState.dialogModel);
        } else {
          await dialogRepository(appId: theState.dialogModel.appId)!
              .update(theState.dialogModel);
        }

        if (callOnAction != null)
          callOnAction!();
      } else if (event is DialogCreateEventRevertChanges) {
        // we could just refresh the app, give we haven't saved anything. However, more efficient is :
        if (callOnAction != null)
          callOnAction!();
      }
    }
  }

  static DialogModel deepCopy(DialogModel from) {
    var copyOfDialogModel = from.copyWith();
    return copyOfDialogModel;
  }
}
