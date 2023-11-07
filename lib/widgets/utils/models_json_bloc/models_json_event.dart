import 'package:eliud_core/model/member_medium_model.dart';
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

  @override
  int get hashCode => 0;
}

typedef ModelsJsonTask = Future<void> Function();

typedef RetrieveModelJsonTasks = Future<List<ModelsJsonTask>> Function();

abstract class ModelsJsonConstructJsonEvent extends ModelsJsonEvent {
  final RetrieveModelJsonTasks retrieveTasks;
  final List<AbstractModelWithInformation> dataContainer;

  ModelsJsonConstructJsonEvent(this.retrieveTasks, this.dataContainer);
}

class ModelsJsonConstructJsonEventToClipboard
    extends ModelsJsonConstructJsonEvent {
  ModelsJsonConstructJsonEventToClipboard(
      super.retrieveTasks, super.dataContainer);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelsJsonConstructJsonEventToClipboard &&
          retrieveTasks == other.retrieveTasks &&
          ListEquality().equals(dataContainer, other.dataContainer);

  @override
  int get hashCode => retrieveTasks.hashCode;
}

class ModelsJsonConstructJsonEventToMemberMediumModel
    extends ModelsJsonConstructJsonEvent {
  final MemberModel member;
  final String baseName;

  ModelsJsonConstructJsonEventToMemberMediumModel(
      super.retrieveTasks, super.dataContainer, this.member, this.baseName);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelsJsonConstructJsonEventToMemberMediumModel &&
          retrieveTasks == other.retrieveTasks &&
          member == other.member &&
          baseName == other.baseName &&
          ListEquality().equals(dataContainer, other.dataContainer);

  @override
  int get hashCode => member.hashCode ^ baseName.hashCode;
}

class ModelsJsonProgressedEvent extends ModelsJsonEvent {
  final List<AbstractModelWithInformation> dataContainer = [];
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

  @override
  int get hashCode => dataContainer.hashCode ^ progress.hashCode;
}

class ModelsAndJsonAvailableInClipboardEvent extends ModelsJsonEvent {
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ModelsAndJsonAvailableInClipboardEvent;

  @override
  int get hashCode => 0;
}

class ModelsAndJsonErrorEvent extends ModelsJsonEvent {
  final String message;

  ModelsAndJsonErrorEvent(this.message);

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ModelsAndJsonAvailableInClipboardEvent;

  @override
  int get hashCode => message.hashCode;
}

class ModelsAndJsonAvailableAsMemberMediumEvent extends ModelsJsonEvent {
  final MemberMediumModel memberMediumModel;

  ModelsAndJsonAvailableAsMemberMediumEvent(this.memberMediumModel);

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) &&
      other is ModelsAndJsonAvailableAsMemberMediumEvent &&
      memberMediumModel == other.memberMediumModel;

  @override
  int get hashCode => memberMediumModel.hashCode;
}
