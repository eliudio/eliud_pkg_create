import 'package:eliud_core/model/member_model.dart';
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
      identical(this, other) || other is ModelsJsonInitialiseEvent;
}

typedef ModelsJsonTask = Future<void> Function();

typedef RetrieveModelJsonTasks = Future<List<ModelsJsonTask>> Function();

abstract class ModelsJsonConstructJsonEvent extends ModelsJsonEvent {
  final RetrieveModelJsonTasks retrieveTasks;
  final List<AbstractModelWithInformation> dataContainer;

  ModelsJsonConstructJsonEvent(this.retrieveTasks, this.dataContainer);
}

class ModelsJsonConstructJsonEventToClipboard extends ModelsJsonConstructJsonEvent {

  ModelsJsonConstructJsonEventToClipboard(RetrieveModelJsonTasks retrieveTasks,  List<AbstractModelWithInformation> dataContainer):
      super(retrieveTasks, dataContainer);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ModelsJsonConstructJsonEventToClipboard &&
              retrieveTasks == other.retrieveTasks &&
              ListEquality().equals(dataContainer, other.dataContainer);
}

class ModelsJsonConstructJsonEventToMemberMediumModel extends ModelsJsonConstructJsonEvent {
  final MemberModel member;
  final String baseName;

  ModelsJsonConstructJsonEventToMemberMediumModel(RetrieveModelJsonTasks retrieveTasks,  List<AbstractModelWithInformation> dataContainer, this.member, this.baseName):
        super(retrieveTasks, dataContainer);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ModelsJsonConstructJsonEventToMemberMediumModel &&
              retrieveTasks == other.retrieveTasks &&
              member == other.member &&
              baseName == other.baseName &&
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
