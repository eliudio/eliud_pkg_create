import 'package:eliud_core_main/model/page_model.dart';
import 'package:equatable/equatable.dart';

abstract class PageCreateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PageCreateEventValidateEvent extends PageCreateEvent {
  final PageModel pageModel;

  PageCreateEventValidateEvent(this.pageModel);

  @override
  List<Object?> get props => [pageModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageCreateEventValidateEvent && pageModel == other.pageModel;

  @override
  int get hashCode => pageModel.hashCode;
}

class PageCreateEventApplyChanges extends PageCreateEvent {
  final bool save;

  PageCreateEventApplyChanges(this.save);

  @override
  List<Object?> get props => [save];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageCreateEventApplyChanges && save == other.save;

  @override
  int get hashCode => save.hashCode;
}
