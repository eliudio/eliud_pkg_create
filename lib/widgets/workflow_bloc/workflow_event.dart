import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_pkg_workflow/model/workflow_model.dart';
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
}

class WorkflowCreateEventApplyChanges extends WorkflowCreateEvent {
  final bool save;

  WorkflowCreateEventApplyChanges(this.save);

  @override
  List<Object?> get props => [save];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WorkflowCreateEventApplyChanges &&
              save == other.save;
}
