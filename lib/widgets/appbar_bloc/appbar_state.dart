import 'package:eliud_core/model/app_bar_model.dart';
import 'package:equatable/equatable.dart';

abstract class AppBarCreateState extends Equatable {
  const AppBarCreateState();

  @override
  List<Object?> get props => [];
}

class AppBarCreateUninitialised extends AppBarCreateState {
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppBarCreateUninitialised;

  @override
  int get hashCode => 0;
}

abstract class AppBarCreateInitialised extends AppBarCreateState {
  final AppBarModel appBarModel;

  AppBarCreateInitialised(this.appBarModel);
}

class AppBarCreateValidated extends AppBarCreateInitialised {
  AppBarCreateValidated(super.appBarModel);

  @override
  List<Object?> get props => [appBarModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppBarCreateValidated && appBarModel == other.appBarModel;

  @override
  int get hashCode => appBarModel.hashCode;
}

class AppBarCreateChangesApplied extends AppBarCreateInitialised {
  AppBarCreateChangesApplied(super.appBarModel);

  @override
  List<Object?> get props => [appBarModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppBarCreateChangesApplied && appBarModel == other.appBarModel;

  @override
  int get hashCode => appBarModel.hashCode;
}
