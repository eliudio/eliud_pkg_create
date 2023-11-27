import 'package:eliud_core_main/model/page_model.dart';
import 'package:equatable/equatable.dart';

abstract class PageCreateState extends Equatable {
  const PageCreateState();

  @override
  List<Object?> get props => [];
}

class PageCreateUninitialised extends PageCreateState {
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PageCreateUninitialised;

  @override
  int get hashCode => 0;
}

abstract class PageCreateInitialised extends PageCreateState {
  final PageModel pageModel;

  PageCreateInitialised(this.pageModel);
}

class PageCreateFromPageValidated extends PageCreateState {}

class PageCreateValidated extends PageCreateInitialised {
  PageCreateValidated(super.pageModel);

  @override
  List<Object?> get props => [pageModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageCreateValidated && pageModel == other.pageModel;

  @override
  int get hashCode => pageModel.hashCode;
}

class PageCreateChangesApplied extends PageCreateInitialised {
  PageCreateChangesApplied(super.pageModel);

  @override
  List<Object?> get props => [pageModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageCreateChangesApplied && pageModel == other.pageModel;

  @override
  int get hashCode => pageModel.hashCode;
}
