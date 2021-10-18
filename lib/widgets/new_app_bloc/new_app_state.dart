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

abstract class NewAppCreateState extends Equatable {
  const NewAppCreateState();

  @override
  List<Object?> get props => [];
}

class NewAppShouldClose extends NewAppCreateState {
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NewAppShouldClose;
}

class NewAppCreateUninitialised extends NewAppCreateState {
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NewAppCreateUninitialised;
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
    AppModel appToBeCreated,
    MemberModel member,
  ) : super(appToBeCreated, member);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewAppCreateAllowEnterDetails &&
          appToBeCreated == other.appToBeCreated &&
          member == other.member;
}

class NewAppCreateCreateInProgress extends NewAppCreateInitialised {
  final double progress;

  NewAppCreateCreateInProgress(
      AppModel appToBeCreated, MemberModel member, this.progress)
      : super(appToBeCreated, member);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NewAppCreateCreateInProgress &&
              appToBeCreated == other.appToBeCreated &&
              member == other.member &&
              progress == other.progress;
}

class NewAppCreateCreateCancelled extends NewAppCreateInitialised {
  NewAppCreateCreateCancelled(
      AppModel appToBeCreated, MemberModel member)
      : super(appToBeCreated, member);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NewAppCreateCreateCancelled &&
              appToBeCreated == other.appToBeCreated &&
              member == other.member;
}

class SwitchApp extends NewAppCreateInitialised {
  SwitchApp(AppModel appToBeCreated, MemberModel member)
      : super(appToBeCreated, member);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SwitchApp &&
              appToBeCreated == other.appToBeCreated &&
              member == other.member;
}