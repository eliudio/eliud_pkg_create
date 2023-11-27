import 'package:eliud_core_main/model/member_model.dart';
import 'package:equatable/equatable.dart';

abstract class WizardState extends Equatable {
  const WizardState();

  @override
  List<Object?> get props => [];
}

class NewAppShouldClose extends WizardState {
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NewAppShouldClose;

  @override
  int get hashCode => 0;
}

class NewAppCreateUninitialised extends WizardState {
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NewAppCreateUninitialised;

  @override
  int get hashCode => 0;
}

abstract class WizardInitialised extends WizardState {
  final MemberModel member;

  WizardInitialised(
    this.member,
  );
}

class WizardAllowEnterDetails extends WizardInitialised {
  WizardAllowEnterDetails(
    super.member,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WizardAllowEnterDetails && member == other.member;

  @override
  int get hashCode => member.hashCode;
}

class WizardRunning extends WizardInitialised {
  WizardRunning(
    super.member,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WizardRunning && member == other.member;

  @override
  int get hashCode => member.hashCode;
}

class WizardCreateInProgress extends WizardRunning {
  final double progress;

  WizardCreateInProgress(super.member, this.progress);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WizardCreateInProgress &&
          member == other.member &&
          progress == other.progress;

  @override
  int get hashCode => progress.hashCode;
}

class WizardCreateCancelled extends WizardRunning {
  WizardCreateCancelled(super.member);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WizardCreateCancelled && member == other.member;

  @override
  int get hashCode => member.hashCode;
}

class WizardCreated extends WizardRunning {
  final bool success;
  WizardCreated(super.member, this.success);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WizardCreated &&
          member == other.member &&
          success == other.success;

  @override
  int get hashCode => success.hashCode;
}
