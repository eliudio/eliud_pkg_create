import 'package:eliud_core/core/wizards/registry/action_specification.dart';
import 'package:eliud_core/core/wizards/registry/registry.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class WizardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class WizardInitialise extends WizardEvent {
  final MemberModel member;

  WizardInitialise(this.member);

  @override
  List<Object?> get props => [member];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WizardInitialise &&
          member == other.member;
}

class WizardConfirm extends WizardEvent {
  final PublicMediumModel? logo;
  final ActionSpecification includeSigninButton;
  final ActionSpecification includeSignoutButton;

  // map newAppWizardName >> ActionSpecifications
  final Map<String, NewAppWizardParameters> newAppWizardParameters;

  WizardConfirm({
    required this.logo,
    required this.includeSigninButton,
    required this.includeSignoutButton,
    required this.newAppWizardParameters,
  });

  @override
  List<Object?> get props => [
        logo,
        includeSignoutButton,
        newAppWizardParameters,
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WizardConfirm &&
          logo == other.logo &&
          mapEquals(newAppWizardParameters, other.newAppWizardParameters) &&
          includeSignoutButton == other.includeSignoutButton;
}

class WizardProgressed extends WizardEvent {
  double progress;
  WizardProgressed(this.progress);

  @override
  List<Object?> get props => [progress];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WizardProgressed && progress == other.progress;
}

class WizardSwitchAppEvent extends WizardEvent {
  WizardSwitchAppEvent();

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WizardSwitchAppEvent;
}

class WizardCancelled extends WizardEvent {
  WizardCancelled();

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WizardCancelled;
}
