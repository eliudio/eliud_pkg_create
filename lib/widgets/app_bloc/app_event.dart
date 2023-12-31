import 'package:eliud_core_main/model/app_model.dart';
import 'package:eliud_core_main/model/dialog_model.dart';
import 'package:eliud_core_main/model/page_model.dart';
import 'package:eliud_core_main/model/platform_medium_model.dart';
import 'package:eliud_core_model/model/app_policy_model.dart';
import 'package:eliud_pkg_workflow_model/model/workflow_model.dart';
import 'package:equatable/equatable.dart';

abstract class AppCreateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppCreateEventValidateEvent extends AppCreateEvent {
  final AppModel appModel;

  AppCreateEventValidateEvent(this.appModel);

  @override
  List<Object?> get props => [appModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppCreateEventValidateEvent && appModel == other.appModel;

  @override
  int get hashCode => appModel.hashCode;
}

class AppCreateEventApplyChanges extends AppCreateEvent {
  final bool save;

  AppCreateEventApplyChanges(this.save);

  @override
  List<Object?> get props => [save];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppCreateEventApplyChanges && save == other.save;

  @override
  int get hashCode => save.hashCode;
}

class AppCreateEventClose extends AppCreateEvent {}

class AppCreateDeletePage extends AppCreateEvent {
  final PageModel deleteThis;

  AppCreateDeletePage(this.deleteThis);

  @override
  List<Object?> get props => [deleteThis];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppCreateDeletePage && deleteThis == other.deleteThis;

  @override
  int get hashCode => deleteThis.hashCode;
}

class AppCreateDeleteDialog extends AppCreateEvent {
  final DialogModel deleteThis;

  AppCreateDeleteDialog(this.deleteThis);

  @override
  List<Object?> get props => [deleteThis];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppCreateDeleteDialog && deleteThis == other.deleteThis;

  @override
  int get hashCode => deleteThis.hashCode;
}

class AppCreateDeleteWorkflow extends AppCreateEvent {
  final WorkflowModel deleteThis;

  AppCreateDeleteWorkflow(this.deleteThis);

  @override
  List<Object?> get props => [deleteThis];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppCreateDeleteWorkflow && deleteThis == other.deleteThis;

  @override
  int get hashCode => deleteThis.hashCode;
}

class AppCreateDeletePolicy extends AppCreateEvent {
  final AppPolicyModel deleteThis;

  AppCreateDeletePolicy(this.deleteThis);

  @override
  List<Object?> get props => [deleteThis];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppCreateDeletePolicy && deleteThis == other.deleteThis;

  @override
  int get hashCode => deleteThis.hashCode;
}

class AppCreateAddPolicy extends AppCreateEvent {
  final PlatformMediumModel addThis;

  AppCreateAddPolicy(this.addThis);

  @override
  List<Object?> get props => [addThis];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppCreateAddPolicy && addThis == other.addThis;

  @override
  int get hashCode => addThis.hashCode;
}

class PagesUpdated extends AppCreateEvent {
  final List<PageModel> pages;

  PagesUpdated(this.pages);
}

class DialogsUpdated extends AppCreateEvent {
  final List<DialogModel> dialogs;

  DialogsUpdated(this.dialogs);
}

class WorkflowsUpdated extends AppCreateEvent {
  final List<WorkflowModel> workflows;

  WorkflowsUpdated(this.workflows);
}

class PoliciesUpdated extends AppCreateEvent {
  final List<AppPolicyModel> policies;

  PoliciesUpdated(this.policies);
}
