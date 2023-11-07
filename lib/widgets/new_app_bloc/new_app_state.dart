import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:equatable/equatable.dart';

abstract class NewAppCreateState extends Equatable {
  const NewAppCreateState();

  @override
  List<Object?> get props => [];
}

class NewAppShouldClose extends NewAppCreateState {
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NewAppShouldClose;

  @override
  int get hashCode => 0;
}

class NewAppCreateUninitialised extends NewAppCreateState {
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NewAppCreateUninitialised;

  @override
  int get hashCode => 0;
}

abstract class NewAppCreateInitialised extends NewAppCreateState {
  final AppModel appToBeCreated;
  final MemberModel member;

  NewAppCreateInitialised(
    this.appToBeCreated,
    this.member,
  );
}

class NewAppCreateAllowEnterDetails extends NewAppCreateInitialised {
  NewAppCreateAllowEnterDetails(
    super.appToBeCreated,
    super.member,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewAppCreateAllowEnterDetails &&
          appToBeCreated == other.appToBeCreated &&
          member == other.member;

  @override
  int get hashCode => appToBeCreated.hashCode ^ member.hashCode;
}

class NewAppCreateError extends NewAppCreateInitialised {
  final String error;

  NewAppCreateError(
    super.appToBeCreated,
    super.member,
    this.error,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewAppCreateError &&
          appToBeCreated == other.appToBeCreated &&
          member == other.member &&
          error == other.error;

  @override
  int get hashCode =>
      appToBeCreated.hashCode ^ member.hashCode ^ error.hashCode;
}

class NewAppCreateCreateInProgress extends NewAppCreateInitialised {
  final double progress;

  NewAppCreateCreateInProgress(
      super.appToBeCreated, super.member, this.progress);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewAppCreateCreateInProgress &&
          appToBeCreated == other.appToBeCreated &&
          member == other.member &&
          progress == other.progress;

  @override
  int get hashCode =>
      appToBeCreated.hashCode ^ member.hashCode ^ progress.hashCode;
}

class NewAppCreateCreateCancelled extends NewAppCreateInitialised {
  NewAppCreateCreateCancelled(super.appToBeCreated, super.member);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewAppCreateCreateCancelled &&
          appToBeCreated == other.appToBeCreated &&
          member == other.member;

  @override
  int get hashCode => appToBeCreated.hashCode ^ member.hashCode;
}

class SwitchApp extends NewAppCreateInitialised {
  SwitchApp(super.appToBeCreated, super.member);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SwitchApp &&
          appToBeCreated == other.appToBeCreated &&
          member == other.member;

  @override
  int get hashCode => appToBeCreated.hashCode ^ member.hashCode;
}
