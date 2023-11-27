import 'package:eliud_pkg_workflow_model/model/workflow_model.dart';
import 'package:equatable/equatable.dart';

abstract class WorkflowCreateState extends Equatable {
  const WorkflowCreateState();

  @override
  List<Object?> get props => [];
}

class WorkflowCreateUninitialised extends WorkflowCreateState {
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WorkflowCreateUninitialised;

  @override
  int get hashCode => 0;
}

abstract class WorkflowCreateInitialised extends WorkflowCreateState {
  final WorkflowModel workflowModel;

  WorkflowCreateInitialised(this.workflowModel);
}

class WorkflowCreateValidated extends WorkflowCreateInitialised {
  WorkflowCreateValidated(super.workflowModel);

  @override
  List<Object?> get props => [workflowModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkflowCreateValidated && workflowModel == other.workflowModel;

  @override
  int get hashCode => workflowModel.hashCode;
}

class WorkflowCreateChangesApplied extends WorkflowCreateInitialised {
  WorkflowCreateChangesApplied(super.workflowModel);

  @override
  List<Object?> get props => [workflowModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkflowCreateChangesApplied &&
          workflowModel == other.workflowModel;

  @override
  int get hashCode => workflowModel.hashCode;
}
