import 'package:eliud_core/model/drawer_model.dart';
import 'package:equatable/equatable.dart';

abstract class DrawerCreateState extends Equatable {
  const DrawerCreateState();

  @override
  List<Object?> get props => [];
}

class DrawerCreateUninitialised extends DrawerCreateState {
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DrawerCreateUninitialised;

  @override
  int get hashCode => 0;
}

abstract class DrawerCreateInitialised extends DrawerCreateState {
  final DrawerModel drawerModel;

  DrawerCreateInitialised(this.drawerModel);
}

class DrawerCreateValidated extends DrawerCreateInitialised {
  DrawerCreateValidated(super.drawerModel);

  @override
  List<Object?> get props => [drawerModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawerCreateValidated && drawerModel == other.drawerModel;

  @override
  int get hashCode => drawerModel.hashCode;
}

class DrawerCreateChangesApplied extends DrawerCreateInitialised {
  DrawerCreateChangesApplied(super.drawerModel);

  @override
  List<Object?> get props => [drawerModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawerCreateChangesApplied && drawerModel == other.drawerModel;

  @override
  int get hashCode => drawerModel.hashCode;
}
