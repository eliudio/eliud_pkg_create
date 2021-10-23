import 'package:bloc/bloc.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/tools/helpers/list_swap.dart';
import 'package:eliud_core/tools/helpers/list_replace.dart';
import 'package:eliud_pkg_workflow/model/workflow_task_model.dart';

import 'workflowtasks_create_event.dart';
import 'workflowtasks_create_state.dart';

class WorkflowTasksCreateBloc extends Bloc<WorkflowTasksCreateEvent, WorkflowTasksCreateState> {
  final AppModel app;
  List<WorkflowTaskModel> workflowTasksModel;

  WorkflowTasksCreateBloc(this.app, this.workflowTasksModel, )
      : super(WorkflowTasksCreateUninitialised());

  @override
  Stream<WorkflowTasksCreateState> mapEventToState(WorkflowTasksCreateEvent event) async* {
    if (event is WorkflowTasksCreateInitialiseEvent) {
      var appId = app.documentID;
      yield WorkflowTasksCreateInitialised(
          workflowTaskModels: event.workflowTasksModel );
    } else if (state is WorkflowTasksCreateInitialised) {
      var appId = app.documentID;
      if (event is WorkflowTasksCreateDeleteMenuItem) {
        yield _newStateDeleteItem(event.workflowTaskModel);
        apply();
      } else if (event is WorkflowTasksMoveItem) {
        WorkflowTasksCreateInitialised theState = state as WorkflowTasksCreateInitialised;
        List<WorkflowTaskModel> _workflowTaskModels = List.of(theState.workflowTaskModels);
        int positionToMove = _workflowTaskModels.indexOf(event.workflowTaskModel);
        if (event.moveItemDirection == MoveItemDirection.Up) {
          if (positionToMove > 0) {
            _workflowTaskModels.swap(positionToMove - 1, positionToMove);
          }
        } else if (event.moveItemDirection == MoveItemDirection.Down) {
          if (positionToMove < _workflowTaskModels.length - 1) {
            _workflowTaskModels.swap(positionToMove + 1, positionToMove);
          }
        }
        _renumber(_workflowTaskModels);
        yield _newStateWithItems(_workflowTaskModels, currentlySelected: event.workflowTaskModel);
        apply();
      } else if (event is WorkflowTasksUpdateItem) {
        WorkflowTasksCreateInitialised theState = state as WorkflowTasksCreateInitialised;
        List<WorkflowTaskModel> _workflowTaskModels = List.of(theState.workflowTaskModels);
        int positionToReplace = _workflowTaskModels.indexOf(event.beforeWorkflowTaskModel);
        _workflowTaskModels.replace(positionToReplace, event.afterWorkflowTaskModel);
        yield _newStateWithItems(_workflowTaskModels, currentlySelected: event.afterWorkflowTaskModel);
        apply();
      } else if (event is WorkflowTasksCreateAddWorkflowTask) {
        WorkflowTasksCreateInitialised theState = state as WorkflowTasksCreateInitialised;
        List<WorkflowTaskModel> _workflowTaskModels = List.of(theState.workflowTaskModels);
        _workflowTaskModels.add(event.workflowTaskModel);
        _renumber(_workflowTaskModels);
        yield _newStateWithItems(_workflowTaskModels, currentlySelected: event.workflowTaskModel);
        apply();
      }
    }
  }

  void _renumber(List<WorkflowTaskModel> _workflowTaskModels) {
    int i = 1;
    for (var _workflowTaskModel in _workflowTaskModels) {
      _workflowTaskModel.seqNumber = i;
      i++;
    }
  }

  void apply() {
    WorkflowTasksCreateInitialised theState = state as WorkflowTasksCreateInitialised;
    workflowTasksModel.clear();
    workflowTasksModel.addAll(theState.workflowTaskModels);
  }

  WorkflowTasksCreateInitialised _newStateWithItems(List<WorkflowTaskModel> items,
      {WorkflowTaskModel? currentlySelected}) {
    var theState = state as WorkflowTasksCreateInitialised;
    var newWorkflowTaskModels = List.of(items);
    var newState = theState.copyWith(
        workflowTaskModels: newWorkflowTaskModels, currentlySelected: currentlySelected);
    return newState;
  }

  WorkflowTasksCreateInitialised _newStateWithNewItem(WorkflowTaskModel newItem) {
    var theState = state as WorkflowTasksCreateInitialised;
    var newWorkflowTaskModels = List.of(theState.workflowTaskModels);
    newWorkflowTaskModels.add(newItem);
    return _newStateWithItems(newWorkflowTaskModels, currentlySelected: newItem);
  }

  WorkflowTasksCreateInitialised _newStateDeleteItemFromIndex(int index) {
    var theState = state as WorkflowTasksCreateInitialised;
    var newWorkflowTaskModels = List.of(theState.workflowTaskModels);
    newWorkflowTaskModels.removeAt(index);
    return _newStateWithItems(newWorkflowTaskModels);
  }

  WorkflowTasksCreateInitialised _newStateDeleteItem(WorkflowTaskModel bodyItemModel) {
    var theState = state as WorkflowTasksCreateInitialised;
    var newWorkflowTaskModels = List.of(theState.workflowTaskModels);
    newWorkflowTaskModels.remove(bodyItemModel);
    return _newStateWithItems(newWorkflowTaskModels);
  }



}
