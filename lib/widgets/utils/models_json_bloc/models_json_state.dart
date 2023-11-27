import 'package:eliud_core_main/model/member_medium_model.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

import 'models_json_bloc.dart';

abstract class ModelsJsonState extends Equatable {
  const ModelsJsonState();

  @override
  List<Object?> get props => [];
}

class ModelsJsonUninitialised extends ModelsJsonState {
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ModelsJsonUninitialised;

  @override
  int get hashCode => 0;
}
/*

abstract class HasDataContainer {
  List<AbstractModelWithInformation> getDataContainer();
}
*/

class ModelsJsonInitialised extends ModelsJsonState {
  ModelsJsonInitialised() : super();

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ModelsJsonInitialised;

  @override
  int get hashCode => 0;
}

class ModelsJsonProgressed extends ModelsJsonState /*with HasDataContainer */ {
  final List<AbstractModelWithInformation> dataContainer;
  final double progress;

  ModelsJsonProgressed(this.progress, this.dataContainer) : super();

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelsJsonProgressed &&
          progress == other.progress &&
          ListEquality().equals(dataContainer, other.dataContainer);

  @override
  int get hashCode => dataContainer.hashCode ^ progress.hashCode;

/*
  @override
  List<AbstractModelWithInformation> getDataContainer() => dataContainer;
*/
}

/*
abstract class ModelsAndJsonAvailable extends ModelsJsonState */
/*with HasDataContainer*/ /*
 {
  final List<AbstractModelWithInformation> dataContainer;

  ModelsAndJsonAvailable(this.dataContainer, ) : super();

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ModelsAndJsonAvailable &&
              ListEquality().equals(dataContainer, other.dataContainer) ;

*/
/*
  @override
  List<AbstractModelWithInformation> getDataContainer() => dataContainer;
*/ /*

}
*/

class ModelsAndJsonAvailableInClipboard extends ModelsJsonState {}

class ModelsAndJsonError extends ModelsJsonState {
  final String error;

  ModelsAndJsonError(this.error);

  @override
  List<Object?> get props => [error];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelsAndJsonError && error == other.error;

  @override
  int get hashCode => error.hashCode;
}

class ModelsAndJsonAvailableAsMemberMedium extends ModelsJsonState {
  final MemberMediumModel memberMediumModel;

  ModelsAndJsonAvailableAsMemberMedium(this.memberMediumModel);

  @override
  List<Object?> get props => [memberMediumModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelsAndJsonAvailableAsMemberMedium &&
          memberMediumModel == other.memberMediumModel;

  @override
  int get hashCode => memberMediumModel.hashCode;
}
