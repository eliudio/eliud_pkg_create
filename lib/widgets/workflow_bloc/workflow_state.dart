import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_pkg_workflow/model/workflow_model.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

abstract class WorkflowCreateState extends Equatable {
  const WorkflowCreateState();

  @override
  List<Object?> get props => [];
}

class WorkflowCreateUninitialised extends WorkflowCreateState {
  @override
  List<Object?> get props => [];

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
          other is WorkflowCreateUninitialised;
}

abstract class WorkflowCreateInitialised extends WorkflowCreateState {
  final WorkflowModel workflowModel;

  WorkflowCreateInitialised(this.workflowModel);
}

class WorkflowCreateValidated extends WorkflowCreateInitialised {
  WorkflowCreateValidated(WorkflowModel workflowModel) : super(workflowModel);

  @override
  List<Object?> get props => [workflowModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WorkflowCreateValidated &&
              workflowModel == other.workflowModel;
}

class WorkflowCreateChangesApplied extends WorkflowCreateInitialised {
  WorkflowCreateChangesApplied(WorkflowModel workflowModel) : super(workflowModel);

  @override
  List<Object?> get props => [workflowModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WorkflowCreateChangesApplied &&
              workflowModel == other.workflowModel;
}

