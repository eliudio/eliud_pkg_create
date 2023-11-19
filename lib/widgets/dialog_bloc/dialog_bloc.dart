import 'package:bloc/bloc.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core_model/model/storage_conditions_model.dart';
import 'dialog_event.dart';
import 'dialog_state.dart';

class DialogCreateBloc extends Bloc<DialogCreateEvent, DialogCreateState> {
  final DialogModel dialogModel;
  final String appId;

  DialogCreateBloc(this.appId, DialogModel initialiseWithDialog)
      : dialogModel = deepCopy(initialiseWithDialog),
        super(DialogCreateUninitialised()) {
    on<DialogCreateEventValidateEvent>((event, emit) {
      // convention is that the ID of the appBar, drawers and home menu are the same ID as that of the app
      //var homeMenuId = homeMenuID(appId);
      event.dialogModel.conditions ??= StorageConditionsModel(
          privilegeLevelRequired:
              PrivilegeLevelRequiredSimple.noPrivilegeRequiredSimple);
      // the updates happen on a (deep) copy
      emit(DialogCreateValidated(deepCopy(event.dialogModel)));
    });

    on<DialogCreateEventApplyChanges>((event, emit) async {
      var theState = state as DialogCreateInitialised;
      var dialog = await dialogRepository(appId: theState.dialogModel.appId)!
          .get(theState.dialogModel.documentID);
      if (dialog == null) {
        await dialogRepository(appId: theState.dialogModel.appId)!
            .add(theState.dialogModel);
      } else {
        await dialogRepository(appId: theState.dialogModel.appId)!
            .update(theState.dialogModel);
      }
    });
  }

  static DialogModel deepCopy(DialogModel from) {
    var copyOfDialogModel = from.copyWith();
    return copyOfDialogModel;
  }
}
