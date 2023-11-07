import 'package:eliud_core/model/home_menu_model.dart';
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

  @override
  int get hashCode => homeMenuModel.hashCode;
}

class BottomNavBarCreateEventApplyChanges extends BottomNavBarCreateEvent {
  final bool save;

  BottomNavBarCreateEventApplyChanges(this.save);

  @override
  List<Object?> get props => [save];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BottomNavBarCreateEventApplyChanges && save == other.save;

  @override
  int get hashCode => save.hashCode;
}
