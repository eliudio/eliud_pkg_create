import 'package:eliud_core/model/dialog_model.dart';
import 'package:equatable/equatable.dart';

abstract class DialogCreateState extends Equatable {
  const DialogCreateState();

  @override
  List<Object?> get props => [];
}

class DialogCreateUninitialised extends DialogCreateState {
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DialogCreateUninitialised;

  @override
  int get hashCode => 0;
}

abstract class DialogCreateInitialised extends DialogCreateState {
  final DialogModel dialogModel;

  DialogCreateInitialised(this.dialogModel);
}

class DialogCreateValidated extends DialogCreateInitialised {
  DialogCreateValidated(super.dialogModel);

  @override
  List<Object?> get props => [dialogModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DialogCreateValidated && dialogModel == other.dialogModel;

  @override
  int get hashCode => dialogModel.hashCode;
}

class DialogCreateChangesApplied extends DialogCreateInitialised {
  DialogCreateChangesApplied(super.dialogModel);

  @override
  List<Object?> get props => [dialogModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DialogCreateChangesApplied && dialogModel == other.dialogModel;

  @override
  int get hashCode => dialogModel.hashCode;
}
