import 'package:eliud_core/core/wizards/registry/registry.dart';
import 'package:eliud_core/model/member_model.dart';
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
      other is WizardInitialise && member == other.member;
}

class WizardConfirm extends WizardEvent {
  final bool autoPrivileged1;
  final String? styleFamily;
  final String? styleName;

  // map newAppWizardName >> ActionSpecifications
  final Map<String, NewAppWizardParameters> newAppWizardParameters;

  WizardConfirm({
    required this.newAppWizardParameters,
    required this.autoPrivileged1,
    required this.styleFamily,
    required this.styleName,
  });

  @override
  List<Object?> get props => [
        newAppWizardParameters,
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WizardConfirm &&
          autoPrivileged1 == other.autoPrivileged1 &&
          mapEquals(newAppWizardParameters, other.newAppWizardParameters);
}

class WizardProgressed extends WizardEvent {
  final double progress;

  WizardProgressed(this.progress, );

  @override
  List<Object?> get props => [progress];

  @override
  bool operator ==(Object other) =>
      false ||
      identical(this, other) ||
      other is WizardProgressed && progress == other.progress;
}

class WizardCancelled extends WizardEvent {

  WizardCancelled();

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      other is WizardCancelled &&
      identical(this, other);
}

class WizardFinished extends WizardEvent {
  final bool success;

  WizardFinished(this.success, );

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) &&
      other is WizardFinished &&
      success == other.success;
}
