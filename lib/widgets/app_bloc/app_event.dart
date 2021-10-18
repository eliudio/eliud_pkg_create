import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:equatable/equatable.dart';

abstract class AppCreateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppCreateEventValidateEvent extends AppCreateEvent {
  final AppModel appModel;

  AppCreateEventValidateEvent(this.appModel);

  @override
  List<Object?> get props => [appModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppCreateEventValidateEvent &&
              appModel == other.appModel;
}

class AppCreateEventApplyChanges extends AppCreateEvent {
  final bool save;

  AppCreateEventApplyChanges(this.save);

  @override
  List<Object?> get props => [save];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppCreateEventApplyChanges &&
              save == other.save;
}

class AppCreateEventRevertChanges extends AppCreateEvent {
  AppCreateEventRevertChanges();

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppCreateEventRevertChanges;
}

