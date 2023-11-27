import 'package:eliud_pkg_workflow_model/model/workflow_model.dart';
import 'package:equatable/equatable.dart';

abstract class WorkflowCreateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class WorkflowCreateEventValidateEvent extends WorkflowCreateEvent {
  final WorkflowModel workflowModel;

  WorkflowCreateEventValidateEvent(this.workflowModel);

  @override
  List<Object?> get props => [workflowModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkflowCreateEventValidateEvent &&
          workflowModel == other.workflowModel;

  @override
  int get hashCode => workflowModel.hashCode;
}

class WorkflowCreateEventApplyChanges extends WorkflowCreateEvent {
  final bool save;

  WorkflowCreateEventApplyChanges(this.save);

  @override
  List<Object?> get props => [save];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkflowCreateEventApplyChanges && save == other.save;

  @override
  int get hashCode => save.hashCode;
}
