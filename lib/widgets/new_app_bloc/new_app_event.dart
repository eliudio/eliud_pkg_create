import 'package:eliud_core/core/blocs/access/state/logged_in.dart';
import 'package:eliud_core_model/model/member_medium_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:equatable/equatable.dart';

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

  @override
  int get hashCode => initialAppIdToBeCreated.hashCode ^ member.hashCode;
}

class NewAppCreateConfirm extends NewAppCreateEvent {
  final bool fromExisting;
  final LoggedIn loggedIn;
  final MemberMediumModel?
      memberMediumModel; // if null then from clipboard or url
  final String? url; // if null then from memberMediumModel or clipboard

  NewAppCreateConfirm(
      this.fromExisting, this.loggedIn, this.memberMediumModel, this.url);

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewAppCreateConfirm &&
          fromExisting == other.fromExisting &&
          url == other.url &&
          memberMediumModel == other.memberMediumModel;

  @override
  int get hashCode =>
      fromExisting.hashCode ^
      loggedIn.hashCode ^
      memberMediumModel.hashCode ^
      url.hashCode;
}

class NewAppCreateProgressed extends NewAppCreateEvent {
  final double progress;
  NewAppCreateProgressed(this.progress);

  @override
  List<Object?> get props => [progress];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewAppCreateProgressed && progress == other.progress;

  @override
  int get hashCode => progress.hashCode;
}

class NewAppSwitchAppEvent extends NewAppCreateEvent {
  NewAppSwitchAppEvent();

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NewAppSwitchAppEvent;

  @override
  int get hashCode => 0;
}

class NewAppCancelled extends NewAppCreateEvent {
  NewAppCancelled();

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NewAppCancelled;

  @override
  int get hashCode => 0;
}
