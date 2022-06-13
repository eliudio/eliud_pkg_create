import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

abstract class WizardState extends Equatable {
  const WizardState();

  @override
  List<Object?> get props => [];
}

class NewAppShouldClose extends WizardState {
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NewAppShouldClose;
}

class NewAppCreateUninitialised extends WizardState {
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NewAppCreateUninitialised;
}

abstract class WizardInitialised extends WizardState {
  final MemberModel member;

  WizardInitialised(
    this.member,
  );
}

class WizardAllowEnterDetails extends WizardInitialised {
  WizardAllowEnterDetails(
    MemberModel member,
  ) : super(member);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WizardAllowEnterDetails &&
          member == other.member;
}

class WizardRunning extends WizardInitialised {

  WizardRunning(MemberModel member, )
      : super(member);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WizardRunning &&
              member == other.member;
}

class WizardCreateInProgress extends WizardRunning {
  final double progress;

  WizardCreateInProgress(
      MemberModel member, this.progress)
      : super(member);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WizardCreateInProgress &&
              member == other.member &&
              progress == other.progress;
}

class WizardCreateCancelled extends WizardRunning {
  WizardCreateCancelled(
      MemberModel member)
      : super(member, );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WizardCreateCancelled &&
              member == other.member;
}

class WizardCreated extends WizardRunning {
  final bool success;
  WizardCreated(
      MemberModel member, this.success)
      : super(member, );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WizardCreated &&
              member == other.member &&
              success == other.success ;
}
