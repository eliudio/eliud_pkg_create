import 'package:eliud_core_main/model/dialog_model.dart';
import 'package:equatable/equatable.dart';

abstract class DialogCreateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DialogCreateEventValidateEvent extends DialogCreateEvent {
  final DialogModel dialogModel;

  DialogCreateEventValidateEvent(this.dialogModel);

  @override
  List<Object?> get props => [dialogModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DialogCreateEventValidateEvent &&
          dialogModel == other.dialogModel;

  @override
  int get hashCode => dialogModel.hashCode;
}

class DialogCreateEventApplyChanges extends DialogCreateEvent {
  final bool save;

  DialogCreateEventApplyChanges(this.save);

  @override
  List<Object?> get props => [save];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DialogCreateEventApplyChanges && save == other.save;

  @override
  int get hashCode => save.hashCode;
}
