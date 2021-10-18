import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:equatable/equatable.dart';

abstract class BottomNavBarCreateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BottomNavBarCreateEventValidateEvent extends BottomNavBarCreateEvent {
  final HomeMenuModel homeMenuModel;

  BottomNavBarCreateEventValidateEvent(this.homeMenuModel);

  @override
  List<Object?> get props => [homeMenuModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BottomNavBarCreateEventValidateEvent &&
              homeMenuModel == other.homeMenuModel;
}

class BottomNavBarCreateEventApplyChanges extends BottomNavBarCreateEvent {
  final bool save;

  BottomNavBarCreateEventApplyChanges(this.save);

  @override
  List<Object?> get props => [save];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BottomNavBarCreateEventApplyChanges &&
              save == other.save;
}

class BottomNavBarCreateEventRevertChanges extends BottomNavBarCreateEvent {
  BottomNavBarCreateEventRevertChanges();

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BottomNavBarCreateEventRevertChanges;
}

