import 'package:eliud_core_main/model/drawer_model.dart';
import 'package:equatable/equatable.dart';

abstract class DrawerCreateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DrawerCreateEventValidateEvent extends DrawerCreateEvent {
  final DrawerModel drawerModel;

  DrawerCreateEventValidateEvent(this.drawerModel);

  @override
  List<Object?> get props => [drawerModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawerCreateEventValidateEvent &&
          drawerModel == other.drawerModel;

  @override
  int get hashCode => drawerModel.hashCode;
}

class DrawerCreateEventApplyChanges extends DrawerCreateEvent {
  final bool save;

  DrawerCreateEventApplyChanges(this.save);

  @override
  List<Object?> get props => [save];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawerCreateEventApplyChanges && save == other.save;

  @override
  int get hashCode => save.hashCode;
}
