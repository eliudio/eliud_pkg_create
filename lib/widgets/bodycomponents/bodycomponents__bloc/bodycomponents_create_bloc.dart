import 'package:bloc/bloc.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/tools/helpers/list_swap.dart';
import 'package:eliud_core/tools/helpers/list_replace.dart';

import 'bodycomponents_create_event.dart';
import 'bodycomponents_create_state.dart';

class BodyComponentsCreateBloc extends Bloc<BodyComponentsCreateEvent, BodyComponentsCreateState> {
  final AppModel app;
  List<BodyComponentModel> bodyComponentsModel;

  BodyComponentsCreateBloc(this.app, this.bodyComponentsModel, )
      : super(BodyComponentsCreateUninitialised());

  @override
  Stream<BodyComponentsCreateState> mapEventToState(BodyComponentsCreateEvent event) async* {
    if (event is BodyComponentsCreateInitialiseEvent) {
      var appId = app.documentID;
      yield BodyComponentsCreateInitialised(
          bodyComponentModels: event.bodyComponentsModel, pluginWithComponents: retrievePluginsWithComponents(), );
    } else if (state is BodyComponentsCreateInitialised) {
      var appId = app.documentID;
      if (event is BodyComponentsCreateDeleteMenuItem) {
        yield _newStateDeleteItem(event.bodyComponentModel);
        apply();
      } else if (event is BodyComponentsMoveItem) {
        BodyComponentsCreateInitialised theState = state as BodyComponentsCreateInitialised;
        List<BodyComponentModel> _bodyComponentModels = List.of(theState.bodyComponentModels);
        int positionToMove = _bodyComponentModels.indexOf(event.bodyComponentModel);
        if (event.moveItemDirection == MoveItemDirection.Up) {
          if (positionToMove > 0) {
            _bodyComponentModels.swap(positionToMove - 1, positionToMove);
          }
        } else if (event.moveItemDirection == MoveItemDirection.Down) {
          if (positionToMove < _bodyComponentModels.length - 1) {
            _bodyComponentModels.swap(positionToMove + 1, positionToMove);
          }
        }
        yield _newStateWithItems(_bodyComponentModels, currentlySelected: event.bodyComponentModel);
        apply();
      } else if (event is BodyComponentsUpdateItem) {
        BodyComponentsCreateInitialised theState = state as BodyComponentsCreateInitialised;
        List<BodyComponentModel> _bodyComponentModels = List.of(theState.bodyComponentModels);
        int positionToReplace = _bodyComponentModels.indexOf(event.beforeBodyComponentModel);
        _bodyComponentModels.replace(positionToReplace, event.afterBodyComponentModel);
        yield _newStateWithItems(_bodyComponentModels, currentlySelected: event.afterBodyComponentModel);
        apply();
      } else if (event is BodyComponentsCreateAddBodyComponent) {
        BodyComponentsCreateInitialised theState = state as BodyComponentsCreateInitialised;
        List<BodyComponentModel> _bodyComponentModels = List.of(theState.bodyComponentModels);
        _bodyComponentModels.add(event.bodyComponentModel);
        yield _newStateWithItems(_bodyComponentModels, currentlySelected: event.bodyComponentModel);
        apply();
      }
    }
  }

  void apply() {
    BodyComponentsCreateInitialised theState = state as BodyComponentsCreateInitialised;
    bodyComponentsModel.clear();
    bodyComponentsModel.addAll(theState.bodyComponentModels);
  }

  BodyComponentsCreateInitialised _newStateWithItems(List<BodyComponentModel> items,
      {BodyComponentModel? currentlySelected}) {
    var theState = state as BodyComponentsCreateInitialised;
    var newBodyComponentModels = List.of(items);
    var newState = theState.copyWith(
        bodyComponentModels: newBodyComponentModels, currentlySelected: currentlySelected);
    return newState;
  }

  BodyComponentsCreateInitialised _newStateWithNewItem(BodyComponentModel newItem) {
    var theState = state as BodyComponentsCreateInitialised;
    var newBodyComponentModels = List.of(theState.bodyComponentModels);
    newBodyComponentModels.add(newItem);
    return _newStateWithItems(newBodyComponentModels, currentlySelected: newItem);
  }

  BodyComponentsCreateInitialised _newStateDeleteItemFromIndex(int index) {
    var theState = state as BodyComponentsCreateInitialised;
    var newBodyComponentModels = List.of(theState.bodyComponentModels);
    newBodyComponentModels.removeAt(index);
    return _newStateWithItems(newBodyComponentModels);
  }

  BodyComponentsCreateInitialised _newStateDeleteItem(BodyComponentModel bodyItemModel) {
    var theState = state as BodyComponentsCreateInitialised;
    var newBodyComponentModels = List.of(theState.bodyComponentModels);
    newBodyComponentModels.remove(bodyItemModel);
    return _newStateWithItems(newBodyComponentModels);
  }



}
