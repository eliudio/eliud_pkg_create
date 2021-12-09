import 'package:bloc/bloc.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/display_conditions_model.dart';
import 'package:eliud_core/model/storage_conditions_model.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'dialog_event.dart';
import 'dialog_state.dart';

class DialogCreateBloc extends Bloc<DialogCreateEvent, DialogCreateState> {
  final DialogModel dialogModel;
  final String appId;

  DialogCreateBloc(this.appId, DialogModel initialiseWithDialog)
      : dialogModel = deepCopy(initialiseWithDialog),
        super(DialogCreateUninitialised());

  @override
  Stream<DialogCreateState> mapEventToState(DialogCreateEvent event) async* {
    if (event is DialogCreateEventValidateEvent) {
      // convention is that the ID of the appBar, drawers and home menu are the same ID as that of the app
      var _homeMenuId = homeMenuID(appId);

      event.dialogModel.conditions ??= StorageConditionsModel(
          privilegeLevelRequired: PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple);
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
      }
    }
  }

  static DialogModel deepCopy(DialogModel from) {
    var copyOfDialogModel = from.copyWith();
    return copyOfDialogModel;
  }
}
