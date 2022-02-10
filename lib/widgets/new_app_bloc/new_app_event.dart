import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_pkg_create/registry/registry.dart';
import 'package:equatable/equatable.dart';
import 'action_specification.dart';
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
  final ShopActionSpecifications includeShop;
  final ActionSpecification includeWelcome;
  final ActionSpecification includeblocked;
  final ActionSpecification includeChat;
  final ActionSpecification includeMemberDashboard;
  final ActionSpecification includeSigninButton;
  final ActionSpecification includeSignoutButton;
  final ActionSpecification includeFlushButton;
  final JoinActionSpecifications includeJoinAction;
  final ActionSpecification notificationDashboardDialogSpecifications;
  final ActionSpecification assignmentDashboardDialogSpecifications;
  final ActionSpecification aboutPageSpecifications;
  final ActionSpecification albumPageSpecifications;

  // map newAppWizardName >> ActionSpecifications
  final Map<String, NewAppWizardParameters> newAppWizardParameters;

  NewAppCreateConfirm({
    required this.logo,
    required this.includeShop,
    required this.includeWelcome,
    required this.includeblocked,
    required this.includeChat,
    required this.includeMemberDashboard,
    //required this.includeExamplePolicy,
    required this.includeSigninButton,
    required this.includeSignoutButton,
    required this.includeFlushButton,
    required this.includeJoinAction,
    required this.notificationDashboardDialogSpecifications,
    required this.assignmentDashboardDialogSpecifications,
    required this.aboutPageSpecifications,
    required this.albumPageSpecifications,
    required this.newAppWizardParameters,
  });

  @override
  List<Object?> get props => [
        logo,
        includeShop,
        includeWelcome,
        includeChat,
        includeMemberDashboard,
        includeSignoutButton,
        includeFlushButton,
    newAppWizardParameters,
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewAppCreateConfirm &&
          logo == other.logo &&
          includeShop == other.includeShop &&
          includeChat == other.includeChat &&
          includeMemberDashboard == other.includeMemberDashboard &&
          mapEquals(newAppWizardParameters, other.newAppWizardParameters) &&
          //includeExamplePolicy == other.includeExamplePolicy &&
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
