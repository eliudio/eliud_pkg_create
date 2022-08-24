import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

abstract class PageCreateState extends Equatable {
  const PageCreateState();

  @override
  List<Object?> get props => [];
}

class PageCreateUninitialised extends PageCreateState {
  @override
  List<Object?> get props => [];

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
          other is PageCreateUninitialised;
}

abstract class PageCreateInitialised extends PageCreateState {
  final PageModel pageModel;

  PageCreateInitialised(this.pageModel);
}

class PageCreateFromPageValidated extends PageCreateState {

}

class PageCreateValidated extends PageCreateInitialised {
  PageCreateValidated(PageModel pageModel) : super(pageModel);

  @override
  List<Object?> get props => [pageModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PageCreateValidated &&
              pageModel == other.pageModel;
}

class PageCreateChangesApplied extends PageCreateInitialised {
  PageCreateChangesApplied(PageModel pageModel) : super(pageModel);

  @override
  List<Object?> get props => [pageModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PageCreateChangesApplied &&
              pageModel == other.pageModel;
}

