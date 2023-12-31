import 'package:eliud_core_main/model/body_component_model.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

abstract class BodyComponentsCreateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BodyComponentsCreateInitialiseEvent extends BodyComponentsCreateEvent {
  final List<BodyComponentModel> bodyComponentsModel;

  BodyComponentsCreateInitialiseEvent(this.bodyComponentsModel);

  @override
  List<Object?> get props => [bodyComponentsModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyComponentsCreateInitialiseEvent &&
          ListEquality().equals(bodyComponentsModel, other.bodyComponentsModel);

  @override
  int get hashCode => bodyComponentsModel.hashCode;
}

class BodyComponentsCreateAddBodyComponent extends BodyComponentsCreateEvent {
  final BodyComponentModel bodyComponentModel;

  BodyComponentsCreateAddBodyComponent(this.bodyComponentModel);

  @override
  List<Object?> get props => [bodyComponentModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyComponentsCreateAddBodyComponent &&
          bodyComponentModel == other.bodyComponentModel;

  @override
  int get hashCode => bodyComponentModel.hashCode;
}

class BodyComponentsCreateDeleteItemFromIndex
    extends BodyComponentsCreateEvent {
  final int index;

  BodyComponentsCreateDeleteItemFromIndex(this.index);
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyComponentsCreateDeleteItemFromIndex && index == other.index;

  @override
  int get hashCode => index.hashCode;
}

class BodyComponentsCreateDeleteMenuItem extends BodyComponentsCreateEvent {
  final BodyComponentModel bodyComponentModel;

  BodyComponentsCreateDeleteMenuItem(this.bodyComponentModel);
  @override
  List<Object?> get props => [bodyComponentModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyComponentsCreateDeleteMenuItem &&
          bodyComponentModel == other.bodyComponentModel;

  @override
  int get hashCode => bodyComponentModel.hashCode;
}

enum MoveItemDirection { up, down }

class BodyComponentsMoveItem extends BodyComponentsCreateEvent {
  final BodyComponentModel bodyComponentModel;
  final MoveItemDirection moveItemDirection;

  BodyComponentsMoveItem(this.bodyComponentModel, this.moveItemDirection);
  @override
  List<Object?> get props => [bodyComponentModel, moveItemDirection];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyComponentsMoveItem &&
          moveItemDirection == other.moveItemDirection &&
          bodyComponentModel == other.bodyComponentModel;

  @override
  int get hashCode => bodyComponentModel.hashCode ^ moveItemDirection.hashCode;
}

class BodyComponentsUpdateItem extends BodyComponentsCreateEvent {
  final BodyComponentModel beforeBodyComponentModel;
  final BodyComponentModel afterBodyComponentModel;

  BodyComponentsUpdateItem(
      this.beforeBodyComponentModel, this.afterBodyComponentModel);

  @override
  List<Object?> get props =>
      [beforeBodyComponentModel, afterBodyComponentModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyComponentsUpdateItem &&
          beforeBodyComponentModel == other.beforeBodyComponentModel &&
          afterBodyComponentModel == other.afterBodyComponentModel;

  @override
  int get hashCode =>
      beforeBodyComponentModel.hashCode ^ afterBodyComponentModel.hashCode;
}
