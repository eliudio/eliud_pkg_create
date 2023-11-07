import 'package:eliud_pkg_workflow/model/workflow_task_model.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

abstract class WorkflowTasksCreateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class WorkflowTasksCreateInitialiseEvent extends WorkflowTasksCreateEvent {
  final List<WorkflowTaskModel> workflowTasksModel;

  WorkflowTasksCreateInitialiseEvent(this.workflowTasksModel);

  @override
  List<Object?> get props => [workflowTasksModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkflowTasksCreateInitialiseEvent &&
          ListEquality().equals(workflowTasksModel, other.workflowTasksModel);

  @override
  int get hashCode => workflowTasksModel.hashCode;
}

class WorkflowTasksCreateAddWorkflowTask extends WorkflowTasksCreateEvent {
  final WorkflowTaskModel workflowTaskModel;

  WorkflowTasksCreateAddWorkflowTask(this.workflowTaskModel);

  @override
  List<Object?> get props => [workflowTaskModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkflowTasksCreateAddWorkflowTask &&
          workflowTaskModel == other.workflowTaskModel;

  @override
  int get hashCode => workflowTaskModel.hashCode;
}

class WorkflowTasksCreateDeleteItemFromIndex extends WorkflowTasksCreateEvent {
  final int index;

  WorkflowTasksCreateDeleteItemFromIndex(this.index);
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkflowTasksCreateDeleteItemFromIndex && index == other.index;

  @override
  int get hashCode => index.hashCode;
}

class WorkflowTasksCreateDeleteMenuItem extends WorkflowTasksCreateEvent {
  final WorkflowTaskModel workflowTaskModel;

  WorkflowTasksCreateDeleteMenuItem(this.workflowTaskModel);
  @override
  List<Object?> get props => [workflowTaskModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkflowTasksCreateDeleteMenuItem &&
          workflowTaskModel == other.workflowTaskModel;

  @override
  int get hashCode => workflowTaskModel.hashCode;
}

enum MoveItemDirection { up, down }

class WorkflowTasksMoveItem extends WorkflowTasksCreateEvent {
  final WorkflowTaskModel workflowTaskModel;
  final MoveItemDirection moveItemDirection;

  WorkflowTasksMoveItem(this.workflowTaskModel, this.moveItemDirection);
  @override
  List<Object?> get props => [workflowTaskModel, moveItemDirection];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkflowTasksMoveItem &&
          moveItemDirection == other.moveItemDirection &&
          workflowTaskModel == other.workflowTaskModel;

  @override
  int get hashCode => workflowTaskModel.hashCode ^ moveItemDirection.hashCode;
}

class WorkflowTasksUpdateItem extends WorkflowTasksCreateEvent {
  final WorkflowTaskModel beforeWorkflowTaskModel;
  final WorkflowTaskModel afterWorkflowTaskModel;

  WorkflowTasksUpdateItem(
      this.beforeWorkflowTaskModel, this.afterWorkflowTaskModel);

  @override
  List<Object?> get props => [beforeWorkflowTaskModel, afterWorkflowTaskModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkflowTasksUpdateItem &&
          beforeWorkflowTaskModel == other.beforeWorkflowTaskModel &&
          afterWorkflowTaskModel == other.afterWorkflowTaskModel;

  @override
  int get hashCode =>
      beforeWorkflowTaskModel.hashCode ^ afterWorkflowTaskModel.hashCode;
}
