import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/page_model.dart';
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
}

class DrawerCreateEventApplyChanges extends DrawerCreateEvent {
  final bool save;

  DrawerCreateEventApplyChanges(this.save);

  @override
  List<Object?> get props => [save];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DrawerCreateEventApplyChanges &&
              save == other.save;
}
