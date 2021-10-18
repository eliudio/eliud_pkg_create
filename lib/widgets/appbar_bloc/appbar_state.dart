import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

abstract class AppBarCreateState extends Equatable {
  const AppBarCreateState();

  @override
  List<Object?> get props => [];
}

class AppBarCreateUninitialised extends AppBarCreateState {
  @override
  List<Object?> get props => [];

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
          other is AppBarCreateUninitialised;
}

abstract class AppBarCreateInitialised extends AppBarCreateState {
  final AppBarModel appBarModel;

  AppBarCreateInitialised(this.appBarModel);
}

class AppBarCreateValidated extends AppBarCreateInitialised {
  AppBarCreateValidated(AppBarModel appBarModel) : super(appBarModel);

  @override
  List<Object?> get props => [appBarModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppBarCreateValidated &&
              appBarModel == other.appBarModel;
}

class AppBarCreateChangesApplied extends AppBarCreateInitialised {
  AppBarCreateChangesApplied(AppBarModel appBarModel) : super(appBarModel);

  @override
  List<Object?> get props => [appBarModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppBarCreateChangesApplied &&
              appBarModel == other.appBarModel;
}

