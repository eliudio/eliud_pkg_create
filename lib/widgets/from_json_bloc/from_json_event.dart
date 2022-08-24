import 'package:eliud_core/core/blocs/access/state/logged_in.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/member_medium_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:equatable/equatable.dart';

abstract class FromJsonEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FromJsonInitialise extends FromJsonEvent {
  FromJsonInitialise();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FromJsonInitialise;
}

class NewFromJsonWithUrl extends FromJsonEvent {
  final LoggedIn loggedIn;
  String url; // if null then from memberMediumModel or clipboard

  NewFromJsonWithUrl(this.loggedIn, this.url);

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NewFromJsonWithUrl &&
              url == other.url;
}

class NewFromJsonWithModel extends FromJsonEvent {
  final LoggedIn loggedIn;
  MemberMediumModel memberMediumModel; // if null then from clipboard or url

  NewFromJsonWithModel(this.loggedIn, this.memberMediumModel);

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NewFromJsonWithModel &&
              memberMediumModel == other.memberMediumModel;
}

class NewFromJsonWithClipboard extends FromJsonEvent {
  NewFromJsonWithClipboard();

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NewFromJsonWithClipboard;
}

