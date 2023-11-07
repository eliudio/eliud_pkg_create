import 'package:bloc/bloc.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/tools/helpers/list_swap.dart';
import 'package:eliud_core/tools/helpers/list_replace.dart';
import 'package:eliud_pkg_workflow/model/workflow_task_model.dart';

import 'workflowtasks_create_event.dart';
import 'workflowtasks_create_state.dart';

class WorkflowTasksCreateBloc
    extends Bloc<WorkflowTasksCreateEvent, WorkflowTasksCreateState> {
  final AppModel app;
  List<WorkflowTaskModel> workflowTasksModel;

  WorkflowTasksCreateBloc(
    this.app,
    this.workflowTasksModel,
  ) : super(WorkflowTasksCreateUninitialised()) {
    on<WorkflowTasksCreateInitialiseEvent>((event, emit) {
      //var appId = app.documentID;
      emit(WorkflowTasksCreateInitialised(
          workflowTaskModels: event.workflowTasksModel));
    });

    on<WorkflowTasksCreateDeleteMenuItem>((event, emit) {
      emit(_newStateDeleteItem(event.workflowTaskModel));
      apply();
    });

    on<WorkflowTasksMoveItem>((event, emit) {
      WorkflowTasksCreateInitialised theState =
          state as WorkflowTasksCreateInitialised;
      List<WorkflowTaskModel> workflowTaskModels =
          List.of(theState.workflowTaskModels);
      int positionToMove = workflowTaskModels.indexOf(event.workflowTaskModel);
      if (event.moveItemDirection == MoveItemDirection.up) {
        if (positionToMove > 0) {
          workflowTaskModels.swap(positionToMove - 1, positionToMove);
        }
      } else if (event.moveItemDirection == MoveItemDirection.down) {
        if (positionToMove < workflowTaskModels.length - 1) {
          workflowTaskModels.swap(positionToMove + 1, positionToMove);
        }
      }
      _renumber(workflowTaskModels);
      emit(_newStateWithItems(workflowTaskModels,
          currentlySelected: event.workflowTaskModel));
      apply();
    });

    on<WorkflowTasksUpdateItem>((event, emit) {
      WorkflowTasksCreateInitialised theState =
          state as WorkflowTasksCreateInitialised;
      List<WorkflowTaskModel> workflowTaskModels =
          List.of(theState.workflowTaskModels);
      int positionToReplace =
          workflowTaskModels.indexOf(event.beforeWorkflowTaskModel);
      workflowTaskModels.replace(
          positionToReplace, event.afterWorkflowTaskModel);
      emit(_newStateWithItems(workflowTaskModels,
          currentlySelected: event.afterWorkflowTaskModel));
      apply();
    });

    on<WorkflowTasksCreateAddWorkflowTask>((event, emit) {
      WorkflowTasksCreateInitialised theState =
          state as WorkflowTasksCreateInitialised;
      List<WorkflowTaskModel> workflowTaskModels =
          List.of(theState.workflowTaskModels);
      workflowTaskModels.add(event.workflowTaskModel);
      _renumber(workflowTaskModels);
      emit(_newStateWithItems(workflowTaskModels,
          currentlySelected: event.workflowTaskModel));
      apply();
    });
  }

  void _renumber(List<WorkflowTaskModel> workflowTaskModels) {
    int i = 1;
    for (var theWorkflowTaskModel in workflowTaskModels) {
      theWorkflowTaskModel.seqNumber = i;
      i++;
    }
  }

  void apply() {
    WorkflowTasksCreateInitialised theState =
        state as WorkflowTasksCreateInitialised;
    workflowTasksModel.clear();
    workflowTasksModel.addAll(theState.workflowTaskModels);
  }

  WorkflowTasksCreateInitialised _newStateWithItems(
      List<WorkflowTaskModel> items,
      {WorkflowTaskModel? currentlySelected}) {
    var theState = state as WorkflowTasksCreateInitialised;
    var newWorkflowTaskModels = List.of(items);
    var newState = theState.copyWith(
        workflowTaskModels: newWorkflowTaskModels,
        currentlySelected: currentlySelected);
    return newState;
  }

/*
  WorkflowTasksCreateInitialised _newStateWithNewItem(
      WorkflowTaskModel newItem) {
    var theState = state as WorkflowTasksCreateInitialised;
    var newWorkflowTaskModels = List.of(theState.workflowTaskModels);
    newWorkflowTaskModels.add(newItem);
    return _newStateWithItems(newWorkflowTaskModels,
        currentlySelected: newItem);
  }

  WorkflowTasksCreateInitialised _newStateDeleteItemFromIndex(int index) {
    var theState = state as WorkflowTasksCreateInitialised;
    var newWorkflowTaskModels = List.of(theState.workflowTaskModels);
    newWorkflowTaskModels.removeAt(index);
    return _newStateWithItems(newWorkflowTaskModels);
  }

*/
  WorkflowTasksCreateInitialised _newStateDeleteItem(
      WorkflowTaskModel bodyItemModel) {
    var theState = state as WorkflowTasksCreateInitialised;
    var newWorkflowTaskModels = List.of(theState.workflowTaskModels);
    newWorkflowTaskModels.remove(bodyItemModel);
    return _newStateWithItems(newWorkflowTaskModels);
  }
}
