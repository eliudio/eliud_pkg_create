import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

abstract class MenuDefCreateState extends Equatable {
  const MenuDefCreateState();

  @override
  List<Object?> get props => [];
}

class MenuDefCreateUninitialised extends MenuDefCreateState {}

class MenuDefCreateInitialised extends MenuDefCreateState {
  final MenuDefModel menuDefModel;
  final List<PageModel?> pages;
  final List<DialogModel?> dialogs;
  final MenuItemModel? currentlySelected;

  MenuDefCreateInitialised({required this.menuDefModel, required this.pages, required this.dialogs, this.currentlySelected});

  @override
  List<Object?> get props => [ menuDefModel, pages, dialogs];

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
          other is MenuDefCreateInitialised &&
          menuDefModel == other.menuDefModel &&
          ListEquality().equals(pages, other.pages) &&
          ListEquality().equals(dialogs, other.dialogs);

  MenuDefCreateInitialised copyWith({MenuDefModel? menuDefModel, List<PageModel?>? pages, List<DialogModel?>? dialogs, MenuItemModel? currentlySelected }) {
    return MenuDefCreateInitialised(menuDefModel: menuDefModel ?? this.menuDefModel, pages: pages ?? this.pages, dialogs: dialogs ?? this.dialogs, currentlySelected: currentlySelected ?? null );
  }

}
