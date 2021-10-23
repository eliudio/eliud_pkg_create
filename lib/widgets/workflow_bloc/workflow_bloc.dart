import 'package:bloc/bloc.dart';
import 'package:eliud_pkg_workflow/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_workflow/model/workflow_model.dart';
import 'package:flutter/material.dart';
import 'workflow_event.dart';
import 'workflow_state.dart';

class WorkflowCreateBloc extends Bloc<WorkflowCreateEvent, WorkflowCreateState> {
  final WorkflowModel originalWorkflowModel;
  final WorkflowModel workflowModelCurrentApp;
  final String appId;
  final VoidCallback? callOnAction;

  WorkflowCreateBloc(this.appId, this.workflowModelCurrentApp, this.callOnAction)
      : originalWorkflowModel = deepCopy(workflowModelCurrentApp),
        super(WorkflowCreateUninitialised());

  @override
  Stream<WorkflowCreateState> mapEventToState(WorkflowCreateEvent event) async* {
    if (event is WorkflowCreateEventValidateEvent) {
      yield WorkflowCreateValidated(deepCopy(event.workflowModel));
    } else if (state is WorkflowCreateInitialised) {
      var theState = state as WorkflowCreateInitialised;
      if (event is WorkflowCreateEventApplyChanges) {
        workflowModelCurrentApp.name = theState.workflowModel.name;
        workflowModelCurrentApp.workflowTask = theState.workflowModel.workflowTask;
        if (event.save) {
          var wf = await workflowRepository(appId: appId)!
              .get(theState.workflowModel.documentID);
          if (wf == null) {
            await workflowRepository(appId: appId)!.add(theState.workflowModel);
          } else {
            await workflowRepository(appId: appId)!.update(theState.workflowModel);
          }
        }

        if (callOnAction != null) {
          callOnAction!();
        }
      } else if (event is WorkflowCreateEventRevertChanges) {
        // we could just refresh the app, give we haven't saved anything. However, more efficient is :
        workflowModelCurrentApp.name = originalWorkflowModel.name;
        workflowModelCurrentApp.workflowTask = originalWorkflowModel.workflowTask;
        if (callOnAction != null) {
          callOnAction!();
        }
      }
    }
  }

  static WorkflowModel deepCopy(WorkflowModel from) {
    var copyOfWorkflowModel = from.copyWith();
    return copyOfWorkflowModel;
  }
}
