import 'package:eliud_core/core/wizards/registry/action_specification.dart';
import 'package:eliud_core/core/wizards/registry/registry.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class NewAppCreateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NewAppCreateEventInitialise extends NewAppCreateEvent {
  final String initialAppIdToBeCreated;
  final MemberModel member;

  NewAppCreateEventInitialise(this.initialAppIdToBeCreated, this.member);

  @override
  List<Object?> get props => [member];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewAppCreateEventInitialise &&
          initialAppIdToBeCreated == other.initialAppIdToBeCreated &&
          member == other.member;
}

class NewAppCreateConfirm extends NewAppCreateEvent {
  final PublicMediumModel? logo;
  final ActionSpecification includeSigninButton;
  final ActionSpecification includeSignoutButton;
  final ActionSpecification includeFlushButton;

  // map newAppWizardName >> ActionSpecifications
  final Map<String, NewAppWizardParameters> newAppWizardParameters;

  NewAppCreateConfirm({
    required this.logo,
    required this.includeSigninButton,
    required this.includeSignoutButton,
    required this.includeFlushButton,
    required this.newAppWizardParameters,
  });

  @override
  List<Object?> get props => [
        logo,
        includeSignoutButton,
        includeFlushButton,
    newAppWizardParameters,
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewAppCreateConfirm &&
          logo == other.logo &&
          mapEquals(newAppWizardParameters, other.newAppWizardParameters) &&
          includeSignoutButton == other.includeSignoutButton &&
          includeFlushButton == other.includeFlushButton;
}

class NewAppCreateProgressed extends NewAppCreateEvent {
  double progress;
  NewAppCreateProgressed(this.progress);

  @override
  List<Object?> get props => [progress];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewAppCreateProgressed && progress == other.progress;
}

class NewAppSwitchAppEvent extends NewAppCreateEvent {
  NewAppSwitchAppEvent();

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NewAppSwitchAppEvent;
}

class NewAppCancelled extends NewAppCreateEvent {
  NewAppCancelled();

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NewAppCancelled;
}
