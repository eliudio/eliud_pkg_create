import 'dart:io';

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
}

class ModelsJsonProgressed extends ModelsJsonState /*with HasDataContainer */{
  List<AbstractModelWithInformation> dataContainer;
  final double progress;

  ModelsJsonProgressed(this.progress, this.dataContainer) : super( );

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ModelsJsonProgressed && progress == other.progress &&
              ListEquality().equals(dataContainer, other.dataContainer) ;

/*
  @override
  List<AbstractModelWithInformation> getDataContainer() => dataContainer;
*/
}

class ModelsAndJsonAvailable extends ModelsJsonState /*with HasDataContainer*/ {
  final List<AbstractModelWithInformation> dataContainer;
  final String jsonString;

  ModelsAndJsonAvailable(this.dataContainer, this.jsonString) : super();

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ModelsAndJsonAvailable &&
              jsonString == other.jsonString &&
              ListEquality().equals(dataContainer, other.dataContainer) ;

/*
  @override
  List<AbstractModelWithInformation> getDataContainer() => dataContainer;
*/
}

