import 'package:equatable/equatable.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'models_json_bloc.dart';


abstract class ModelsJsonEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ModelsJsonInitialiseEvent extends ModelsJsonEvent {

  ModelsJsonInitialiseEvent();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ModelsJsonInitialiseEvent;
}

typedef ModelsJsonTask = Future<void> Function();

typedef RetrieveModelJsonTasks = Future<List<ModelsJsonTask>> Function();

class ModelsJsonConstructJsonEvent extends ModelsJsonEvent {
  List<AbstractModelWithInformation> dataContainer;
  RetrieveModelJsonTasks retrieveTasks;

  ModelsJsonConstructJsonEvent(this.retrieveTasks, this.dataContainer);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ModelsJsonConstructJsonEvent &&
              retrieveTasks == other.retrieveTasks &&
              ListEquality().equals(dataContainer, other.dataContainer);
}

class ModelsJsonProgressedEvent extends ModelsJsonEvent {
  List<AbstractModelWithInformation> dataContainer = [];
  final double progress;

  ModelsJsonProgressedEvent(this.progress);

  @override
  List<Object?> get props => [progress];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ModelsJsonProgressedEvent &&
              progress == other.progress &&
              ListEquality().equals(dataContainer, other.dataContainer);
}

