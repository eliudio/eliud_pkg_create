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
  final AppModel app;
  final MemberModel member;

  WizardInitialised(
    this.app,
    this.member,
  );
}

class WizardAllowEnterDetails extends WizardInitialised {
  WizardAllowEnterDetails(
    AppModel app,
    MemberModel member,
  ) : super(app, member);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WizardAllowEnterDetails &&
          app == other.app &&
          member == other.member;
}

class WizardRunning extends WizardInitialised {
  final String wizardMessage;

  WizardRunning(
      AppModel app, MemberModel member, this.wizardMessage)
      : super(app, member);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WizardCreateInProgress &&
              app == other.app &&
              member == other.member &&
              wizardMessage == other.wizardMessage;
}

class WizardCreateInProgress extends WizardRunning {
  final double progress;

  WizardCreateInProgress(
      AppModel app, MemberModel member, String wizardMessage, this.progress)
      : super(app, member, wizardMessage);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WizardCreateInProgress &&
              app == other.app &&
              member == other.member &&
              wizardMessage == other.wizardMessage &&
              progress == other.progress;
}

class WizardCreateCancelled extends WizardRunning {
  WizardCreateCancelled(
      AppModel app, MemberModel member, String wizardMessage)
      : super(app, member, wizardMessage);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WizardCreateCancelled &&
              app == other.app &&
              wizardMessage == other.wizardMessage &&
              member == other.member;
}

class WizardCreated extends WizardRunning {
  final bool success;
  WizardCreated(
      AppModel app, MemberModel member, String wizardMessage, this.success)
      : super(app, member, wizardMessage);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WizardCreated &&
              app == other.app &&
              member == other.member &&
              success == other.success &&
              wizardMessage == other.wizardMessage;
}
