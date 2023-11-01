
import 'package:eliud_core/core/blocs/access/state/logged_in.dart';
import 'package:eliud_core/model/member_medium_model.dart';
import 'package:equatable/equatable.dart';


typedef void PostCreationAction(String? key, String? documentId);

abstract class FromJsonEvent extends Equatable {
  List<Object?> get props => [];
}

class FromJsonInitialise extends FromJsonEvent {
  FromJsonInitialise(): super();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FromJsonInitialise;
}

abstract class FromJsonAction  extends FromJsonEvent {
  // Also re-upload (with new documentID) the media (PlatformMedium, MemberMedium or PublicMedium) referenced or reference the same image as the one being created?
  final bool includeMedia;
  final PostCreationAction postCreationAction;

  FromJsonAction(this.includeMedia, this.postCreationAction);

}

class NewFromJsonWithUrl extends FromJsonAction {
  final LoggedIn loggedIn;
  final String url;

  NewFromJsonWithUrl(this.loggedIn, this.url, bool includeMedia, PostCreationAction postCreationAction): super(includeMedia, postCreationAction, );

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NewFromJsonWithUrl &&
              this.includeMedia == other.includeMedia
              &&
              url == other.url;
}

class NewFromJsonWithModel extends FromJsonAction {
  final LoggedIn loggedIn;
  MemberMediumModel memberMediumModel; // if null then from clipboard or url

  NewFromJsonWithModel(this.loggedIn, this.memberMediumModel, bool includeMedia, PostCreationAction postCreationAction): super(includeMedia, postCreationAction);

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NewFromJsonWithModel &&
              this.includeMedia == other.includeMedia
              &&
              memberMediumModel == other.memberMediumModel;
}

class NewFromJsonWithClipboard extends FromJsonAction {
  NewFromJsonWithClipboard(bool includeMedia, PostCreationAction postCreationAction): super(includeMedia, postCreationAction);

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NewFromJsonWithClipboard &&
              this.includeMedia == other.includeMedia;
}

class NewFromJsonCancelAction extends FromJsonEvent {

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NewFromJsonCancelAction;
}