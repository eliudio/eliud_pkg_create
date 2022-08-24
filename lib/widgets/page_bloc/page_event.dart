import 'package:eliud_core/core/blocs/access/state/logged_in.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/member_medium_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/page_model.dart';
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
          other is PageCreateEventValidateEvent &&
              pageModel == other.pageModel;
}
class PageCreateEventApplyChanges extends PageCreateEvent {
  final bool save;

  PageCreateEventApplyChanges(this.save);

  @override
  List<Object?> get props => [save];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PageCreateEventApplyChanges &&
              save == other.save;
}
