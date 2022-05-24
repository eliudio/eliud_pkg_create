import 'package:bloc/bloc.dart';
import 'package:eliud_pkg_workflow/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_workflow/model/workflow_model.dart';
import 'package:flutter/material.dart';
import 'workflow_event.dart';
import 'workflow_state.dart';

class WorkflowCreateBloc
    extends Bloc<WorkflowCreateEvent, WorkflowCreateState> {
  final WorkflowModel workflowModel;
  final String appId;
  final VoidCallback? callOnAction;

  WorkflowCreateBloc(
      this.appId, WorkflowModel initialiseWithWorkflowModel, this.callOnAction)
      : workflowModel = deepCopy(initialiseWithWorkflowModel),
        super(WorkflowCreateUninitialised()) {
    on<WorkflowCreateEventValidateEvent>((event, emit) {
      emit(WorkflowCreateValidated(deepCopy(event.workflowModel)));
    });

    on<WorkflowCreateEventApplyChanges>((event, emit) async {
      var theState = state as WorkflowCreateInitialised;
      workflowModel.name = theState.workflowModel.name;
      workflowModel.workflowTask = theState.workflowModel.workflowTask;
      if (event.save) {
        var wf = await workflowRepository(appId: appId)!
            .get(theState.workflowModel.documentID);
        if (wf == null) {
          await workflowRepository(appId: appId)!.add(theState.workflowModel);
        } else {
          await workflowRepository(appId: appId)!
              .update(theState.workflowModel);
        }
      }

      if (callOnAction != null) {
        callOnAction!();
      }
    });
  }

  static WorkflowModel deepCopy(WorkflowModel from) {
    var copyOfWorkflowModel = from.copyWith();
    return copyOfWorkflowModel;
  }
}
