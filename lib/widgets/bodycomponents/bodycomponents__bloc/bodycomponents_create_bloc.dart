import 'package:bloc/bloc.dart';
import 'package:eliud_core_model/model/app_model.dart';
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/tools/helpers/list_swap.dart';
import 'package:eliud_core/tools/helpers/list_replace.dart';

import 'bodycomponents_create_event.dart';
import 'bodycomponents_create_state.dart';

class BodyComponentsCreateBloc
    extends Bloc<BodyComponentsCreateEvent, BodyComponentsCreateState> {
  final AppModel app;
  List<BodyComponentModel> bodyComponentsModel;

  BodyComponentsCreateBloc(
    this.app,
    this.bodyComponentsModel,
  ) : super(BodyComponentsCreateUninitialised()) {
    on<BodyComponentsCreateInitialiseEvent>((event, emit) {
      //var appId = app.documentID;
      emit(BodyComponentsCreateInitialised(
        bodyComponentModels: event.bodyComponentsModel,
        pluginWithComponents: retrievePluginsWithComponents(),
      ));
    });

    on<BodyComponentsCreateDeleteMenuItem>((event, emit) {
      emit(_newStateDeleteItem(event.bodyComponentModel));
      apply();
    });

    on<BodyComponentsMoveItem>((event, emit) {
      BodyComponentsCreateInitialised theState =
          state as BodyComponentsCreateInitialised;
      List<BodyComponentModel> bodyComponentModels =
          List.of(theState.bodyComponentModels);
      int positionToMove =
          bodyComponentModels.indexOf(event.bodyComponentModel);
      if (event.moveItemDirection == MoveItemDirection.up) {
        if (positionToMove > 0) {
          bodyComponentModels.swap(positionToMove - 1, positionToMove);
        }
      } else if (event.moveItemDirection == MoveItemDirection.down) {
        if (positionToMove < bodyComponentModels.length - 1) {
          bodyComponentModels.swap(positionToMove + 1, positionToMove);
        }
      }
      emit(_newStateWithItems(bodyComponentModels,
          currentlySelected: event.bodyComponentModel));
      apply();
    });

    on<BodyComponentsUpdateItem>((event, emit) {
      BodyComponentsCreateInitialised theState =
          state as BodyComponentsCreateInitialised;
      List<BodyComponentModel> bodyComponentModels =
          List.of(theState.bodyComponentModels);
      int positionToReplace =
          bodyComponentModels.indexOf(event.beforeBodyComponentModel);
      bodyComponentModels.replace(
          positionToReplace, event.afterBodyComponentModel);
      emit(_newStateWithItems(bodyComponentModels,
          currentlySelected: event.afterBodyComponentModel));
      apply();
    });

    on<BodyComponentsCreateAddBodyComponent>((event, emit) {
      BodyComponentsCreateInitialised theState =
          state as BodyComponentsCreateInitialised;
      List<BodyComponentModel> bodyComponentModels =
          List.of(theState.bodyComponentModels);
      bodyComponentModels.add(event.bodyComponentModel);
      emit(_newStateWithItems(bodyComponentModels,
          currentlySelected: event.bodyComponentModel));
      apply();
    });
  }

  void apply() {
    BodyComponentsCreateInitialised theState =
        state as BodyComponentsCreateInitialised;
    bodyComponentsModel.clear();
    bodyComponentsModel.addAll(theState.bodyComponentModels);
  }

  BodyComponentsCreateInitialised _newStateWithItems(
      List<BodyComponentModel> items,
      {BodyComponentModel? currentlySelected}) {
    var theState = state as BodyComponentsCreateInitialised;
    var newBodyComponentModels = List.of(items);
    var newState = theState.copyWith(
        bodyComponentModels: newBodyComponentModels,
        currentlySelected: currentlySelected);
    return newState;
  }

  /*
  BodyComponentsCreateInitialised _newStateWithNewItem(
      BodyComponentModel newItem) {
    var theState = state as BodyComponentsCreateInitialised;
    var newBodyComponentModels = List.of(theState.bodyComponentModels);
    newBodyComponentModels.add(newItem);
    return _newStateWithItems(newBodyComponentModels,
        currentlySelected: newItem);
  }

  BodyComponentsCreateInitialised _newStateDeleteItemFromIndex(int index) {
    var theState = state as BodyComponentsCreateInitialised;
    var newBodyComponentModels = List.of(theState.bodyComponentModels);
    newBodyComponentModels.removeAt(index);
    return _newStateWithItems(newBodyComponentModels);
  }
   */

  BodyComponentsCreateInitialised _newStateDeleteItem(
      BodyComponentModel bodyItemModel) {
    var theState = state as BodyComponentsCreateInitialised;
    var newBodyComponentModels = List.of(theState.bodyComponentModels);
    newBodyComponentModels.remove(bodyItemModel);
    return _newStateWithItems(newBodyComponentModels);
  }
}
