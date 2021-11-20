import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:equatable/equatable.dart';

abstract class AppBarCreateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppBarCreateEventValidateEvent extends AppBarCreateEvent {
  final AppBarModel appBarModel;

  AppBarCreateEventValidateEvent(this.appBarModel);

  @override
  List<Object?> get props => [appBarModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppBarCreateEventValidateEvent &&
              appBarModel == other.appBarModel;
}

class AppBarCreateEventApplyChanges extends AppBarCreateEvent {
  final bool save;

  AppBarCreateEventApplyChanges(this.save);

  @override
  List<Object?> get props => [save];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppBarCreateEventApplyChanges &&
              save == other.save;
}
