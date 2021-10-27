import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:equatable/equatable.dart';

import 'action_specification.dart';

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
  final ActionSpecification includeChat;
  final ActionSpecification includeFeed;
  final ActionSpecification includeMemberDashboard;
  final ActionSpecification includeExamplePolicy;
  final ActionSpecification includeSignoutButton;
  final ActionSpecification includeFlushButton;
  final JoinActionSpecifications includeJoinAction;
  final ActionSpecification membershipDashboardDialogSpecifications;
  final ActionSpecification notificationDashboardDialogSpecifications;
  final ActionSpecification assignmentDashboardDialogSpecifications;
  final ActionSpecification aboutPageSpecifications;

  NewAppCreateConfirm({
    required this.logo,
    required this.includeShop,
    required this.includeWelcome,
    required this.includeChat,
    required this.includeFeed,
    required this.includeMemberDashboard,
    required this.includeExamplePolicy,
    required this.includeSignoutButton,
    required this.includeFlushButton,
    required this.includeJoinAction,
    required this.membershipDashboardDialogSpecifications,
    required this.notificationDashboardDialogSpecifications,
    required this.assignmentDashboardDialogSpecifications,
    required this.aboutPageSpecifications,
  });

  @override
  List<Object?> get props => [
        logo,
        includeShop,
        includeWelcome,
        includeChat,
        includeFeed,
        includeMemberDashboard,
        includeExamplePolicy,
        includeSignoutButton,
        includeFlushButton,
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewAppCreateConfirm &&
          logo == other.logo &&
          includeShop == other.includeShop &&
          includeChat == other.includeChat &&
          includeFeed == other.includeFeed &&
          includeMemberDashboard == other.includeMemberDashboard &&
          includeExamplePolicy == other.includeExamplePolicy &&
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
