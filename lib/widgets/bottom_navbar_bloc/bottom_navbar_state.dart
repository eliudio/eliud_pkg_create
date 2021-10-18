import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

abstract class BottomNavBarCreateState extends Equatable {
  const BottomNavBarCreateState();

  @override
  List<Object?> get props => [];
}

class BottomNavBarCreateUninitialised extends BottomNavBarCreateState {
  @override
  List<Object?> get props => [];

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
          other is BottomNavBarCreateUninitialised;
}

abstract class BottomNavBarCreateInitialised extends BottomNavBarCreateState {
  final HomeMenuModel homeMenuModel;

  BottomNavBarCreateInitialised(this.homeMenuModel);
}

class BottomNavBarCreateValidated extends BottomNavBarCreateInitialised {
  BottomNavBarCreateValidated(HomeMenuModel homeMenuModel) : super(homeMenuModel);

  @override
  List<Object?> get props => [homeMenuModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BottomNavBarCreateValidated &&
              homeMenuModel == other.homeMenuModel;
}

class BottomNavBarCreateChangesApplied extends BottomNavBarCreateInitialised {
  BottomNavBarCreateChangesApplied(HomeMenuModel homeMenuModel) : super(homeMenuModel);

  @override
  List<Object?> get props => [homeMenuModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BottomNavBarCreateChangesApplied &&
              homeMenuModel == other.homeMenuModel;
}

