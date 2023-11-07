import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:equatable/equatable.dart';

abstract class MenuDefCreateState extends Equatable {
  const MenuDefCreateState();

  @override
  List<Object?> get props => [];
}

class MenuDefCreateUninitialised extends MenuDefCreateState {}

class MenuDefCreateInitialised extends MenuDefCreateState {
  final MenuDefModel menuDefModel;
  final MenuItemModel? currentlySelected;

  const MenuDefCreateInitialised(
      {required this.menuDefModel, this.currentlySelected});

  @override
  List<Object?> get props => [
        menuDefModel,
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuDefCreateInitialised && menuDefModel == other.menuDefModel;

  MenuDefCreateInitialised copyWith(
      {MenuDefModel? menuDefModel, MenuItemModel? currentlySelected}) {
    return MenuDefCreateInitialised(
        menuDefModel: menuDefModel ?? this.menuDefModel,
        currentlySelected: currentlySelected);
  }

  @override
  int get hashCode => menuDefModel.hashCode ^ currentlySelected.hashCode;
}
