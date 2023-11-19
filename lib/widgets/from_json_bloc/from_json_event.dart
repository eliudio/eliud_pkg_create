import 'package:eliud_core/core/blocs/access/state/logged_in.dart';
import 'package:eliud_core_model/model/member_medium_model.dart';
import 'package:equatable/equatable.dart';

typedef PostCreationAction = void Function(String? key, String? documentId);

abstract class FromJsonEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FromJsonInitialise extends FromJsonEvent {
  FromJsonInitialise() : super();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FromJsonInitialise;

  @override
  int get hashCode => 0;
}

abstract class FromJsonAction extends FromJsonEvent {
  // Also re-upload (with new documentID) the media (PlatformMedium, MemberMedium or PublicMedium) referenced or reference the same image as the one being created?
  final bool includeMedia;
  final PostCreationAction postCreationAction;

  FromJsonAction(this.includeMedia, this.postCreationAction);
}

class NewFromJsonWithUrl extends FromJsonAction {
  final LoggedIn loggedIn;
  final String url;

  NewFromJsonWithUrl(this.loggedIn, this.url, bool includeMedia,
      PostCreationAction postCreationAction)
      : super(
          includeMedia,
          postCreationAction,
        );

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewFromJsonWithUrl &&
          includeMedia == other.includeMedia &&
          url == other.url;

  @override
  int get hashCode => includeMedia.hashCode ^ url.hashCode;
}

class NewFromJsonWithModel extends FromJsonAction {
  final LoggedIn loggedIn;
  final MemberMediumModel
      memberMediumModel; // if null then from clipboard or url

  NewFromJsonWithModel(this.loggedIn, this.memberMediumModel, bool includeMedia,
      PostCreationAction postCreationAction)
      : super(includeMedia, postCreationAction);

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewFromJsonWithModel &&
          includeMedia == other.includeMedia &&
          memberMediumModel == other.memberMediumModel;

  @override
  int get hashCode =>
      includeMedia.hashCode ^ loggedIn.hashCode ^ memberMediumModel.hashCode;
}

class NewFromJsonWithClipboard extends FromJsonAction {
  NewFromJsonWithClipboard(super.includeMedia, super.postCreationAction);

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewFromJsonWithClipboard && includeMedia == other.includeMedia;

  @override
  // TODO: implement hashCode
  int get hashCode => includeMedia.hashCode;
}

class NewFromJsonCancelAction extends FromJsonEvent {
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NewFromJsonCancelAction;

  @override
  int get hashCode => 0;
}

class FromJsonProgressEvent extends FromJsonEvent {
  final double progress;

  FromJsonProgressEvent(this.progress);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FromJsonProgressEvent && other.progress == progress;

  @override
  int get hashCode => progress.hashCode;
}
