import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_pkg_workflow/model/workflow_model.dart';
import 'package:equatable/equatable.dart';

abstract class MenuDefCreateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class MenuDefCreateInitialiseEvent extends MenuDefCreateEvent {
  final MenuDefModel menuDefModel;

  MenuDefCreateInitialiseEvent(this.menuDefModel);

  @override
  List<Object?> get props => [menuDefModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuDefCreateInitialiseEvent &&
          menuDefModel == other.menuDefModel;

  @override
  int get hashCode => menuDefModel.hashCode;
}

class MenuDefCreateAddMenuItemForPage extends MenuDefCreateEvent {
  final PageModel pageModel;

  MenuDefCreateAddMenuItemForPage(this.pageModel);

  @override
  List<Object?> get props => [pageModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuDefCreateAddMenuItemForPage && pageModel == other.pageModel;

  @override
  int get hashCode => pageModel.hashCode;
}

class MenuDefCreateAddMenuItemForDialog extends MenuDefCreateEvent {
  final DialogModel dialogModel;

  MenuDefCreateAddMenuItemForDialog(this.dialogModel);

  @override
  List<Object?> get props => [dialogModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuDefCreateAddMenuItemForDialog &&
          dialogModel == other.dialogModel;

  @override
  int get hashCode => dialogModel.hashCode;
}

class MenuDefCreateAddMenuItemForWorkflow extends MenuDefCreateEvent {
  final WorkflowModel workflowModel;

  MenuDefCreateAddMenuItemForWorkflow(this.workflowModel);

  @override
  List<Object?> get props => [workflowModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuDefCreateAddMenuItemForWorkflow &&
          workflowModel == other.workflowModel;

  @override
  int get hashCode => workflowModel.hashCode;
}

class MenuDefCreateAddLogin extends MenuDefCreateEvent {
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => 0;
}

class MenuDefCreateAddLogout extends MenuDefCreateEvent {
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => 0;
}

class MenuDefCreateAddOtherApps extends MenuDefCreateEvent {
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => 0;
}

class MenuDefCreateAddGoHome extends MenuDefCreateEvent {
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => 0;
}

class MenuDefCreateDeleteMenuItemFromIndex extends MenuDefCreateEvent {
  final int index;

  MenuDefCreateDeleteMenuItemFromIndex(this.index);
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuDefCreateDeleteMenuItemFromIndex && index == other.index;

  @override
  int get hashCode => index.hashCode;
}

class MenuDefCreateDeleteMenuItem extends MenuDefCreateEvent {
  final MenuItemModel menuItemModel;

  MenuDefCreateDeleteMenuItem(this.menuItemModel);
  @override
  List<Object?> get props => [menuItemModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuDefCreateDeleteMenuItem &&
          menuItemModel == other.menuItemModel;

  @override
  int get hashCode => menuItemModel.hashCode;
}

enum MoveMenuItemDirection { up, down }

class MenuDefMoveMenuItem extends MenuDefCreateEvent {
  final MenuItemModel menuItemModel;
  final MoveMenuItemDirection moveMenuItemDirection;

  MenuDefMoveMenuItem(this.menuItemModel, this.moveMenuItemDirection);
  @override
  List<Object?> get props => [menuItemModel, moveMenuItemDirection];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuDefMoveMenuItem &&
          moveMenuItemDirection == other.moveMenuItemDirection &&
          menuItemModel == other.menuItemModel;

  @override
  int get hashCode => menuItemModel.hashCode ^ moveMenuItemDirection.hashCode;
}

class MenuDefUpdateMenuItem extends MenuDefCreateEvent {
  final MenuItemModel beforeMenuItemModel;
  final MenuItemModel afterMenuItemModel;

  MenuDefUpdateMenuItem(this.beforeMenuItemModel, this.afterMenuItemModel);

  @override
  List<Object?> get props => [beforeMenuItemModel, afterMenuItemModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuDefUpdateMenuItem &&
          beforeMenuItemModel == other.beforeMenuItemModel &&
          afterMenuItemModel == other.afterMenuItemModel;

  @override
  int get hashCode =>
      beforeMenuItemModel.hashCode ^ afterMenuItemModel.hashCode;
}
