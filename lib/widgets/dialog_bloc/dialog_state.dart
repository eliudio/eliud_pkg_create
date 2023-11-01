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
  bool operator == (Object other) =>
      identical(this, other) ||
          other is DialogCreateUninitialised;
}

abstract class DialogCreateInitialised extends DialogCreateState {
  final DialogModel dialogModel;

  DialogCreateInitialised(this.dialogModel);
}

class DialogCreateValidated extends DialogCreateInitialised {
  DialogCreateValidated(DialogModel dialogModel) : super(dialogModel);

  @override
  List<Object?> get props => [dialogModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DialogCreateValidated &&
              dialogModel == other.dialogModel;
}

class DialogCreateChangesApplied extends DialogCreateInitialised {
  DialogCreateChangesApplied(DialogModel dialogModel) : super(dialogModel);

  @override
  List<Object?> get props => [dialogModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DialogCreateChangesApplied &&
              dialogModel == other.dialogModel;
}

