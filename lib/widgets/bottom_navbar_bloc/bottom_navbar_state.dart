import 'package:eliud_core/model/home_menu_model.dart';
import 'package:equatable/equatable.dart';

abstract class BottomNavBarCreateState extends Equatable {
  const BottomNavBarCreateState();

  @override
  List<Object?> get props => [];
}

class BottomNavBarCreateUninitialised extends BottomNavBarCreateState {
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BottomNavBarCreateUninitialised;

  @override
  int get hashCode => 0;
}

abstract class BottomNavBarCreateInitialised extends BottomNavBarCreateState {
  final HomeMenuModel homeMenuModel;

  BottomNavBarCreateInitialised(this.homeMenuModel);
}

class BottomNavBarCreateValidated extends BottomNavBarCreateInitialised {
  BottomNavBarCreateValidated(super.homeMenuModel);

  @override
  List<Object?> get props => [homeMenuModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BottomNavBarCreateValidated &&
          homeMenuModel == other.homeMenuModel;

  @override
  int get hashCode => homeMenuModel.hashCode;
}

class BottomNavBarCreateChangesApplied extends BottomNavBarCreateInitialised {
  BottomNavBarCreateChangesApplied(super.homeMenuModel);

  @override
  List<Object?> get props => [homeMenuModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BottomNavBarCreateChangesApplied &&
          homeMenuModel == other.homeMenuModel;

  @override
  int get hashCode => homeMenuModel.hashCode;
}
