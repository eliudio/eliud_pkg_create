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

class WizardCreateInProgress extends WizardInitialised {
  final double progress;

  WizardCreateInProgress(
      AppModel app, MemberModel member, this.progress)
      : super(app, member);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WizardCreateInProgress &&
              app == other.app &&
              member == other.member &&
              progress == other.progress;
}

class WizardCreateCancelled extends WizardInitialised {
  WizardCreateCancelled(
      AppModel app, MemberModel member)
      : super(app, member);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WizardCreateCancelled &&
              app == other.app &&
              member == other.member;
}

class WizardSwitchApp extends WizardInitialised {
  WizardSwitchApp(AppModel app, MemberModel member)
      : super(app, member);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WizardSwitchApp &&
              app == other.app &&
              member == other.member;
}