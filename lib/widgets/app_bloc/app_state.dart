import 'package:eliud_core_main/model/app_bar_model.dart';
import 'package:eliud_core_main/model/app_model.dart';
import 'package:eliud_core_main/model/dialog_model.dart';
import 'package:eliud_core_main/model/drawer_model.dart';
import 'package:eliud_core_main/model/home_menu_model.dart';
import 'package:eliud_core_main/model/page_model.dart';
import 'package:eliud_core_model/model/app_policy_model.dart';
import 'package:eliud_pkg_workflow_model/model/workflow_model.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

abstract class AppCreateState extends Equatable {
  const AppCreateState();

  @override
  List<Object?> get props => [];
}

class AppCreateUninitialised extends AppCreateState {
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppCreateUninitialised;

  @override
  int get hashCode => 0;
}

abstract class AppCreateInitialised extends AppCreateState {
  final AppModel appModel;
  final List<PageModel> pages;
  final List<DialogModel> dialogs;
  final List<AppPolicyModel> policies;
  final List<WorkflowModel> workflows;
  final HomeMenuModel homeMenuModel;
  final AppBarModel appBarModel;
  final DrawerModel leftDrawerModel;
  final DrawerModel rightDrawerModel;

  AppCreateInitialised(
    this.appModel,
    this.pages,
    this.dialogs,
    this.workflows,
    this.policies,
    this.homeMenuModel,
    this.appBarModel,
    this.leftDrawerModel,
    this.rightDrawerModel,
  );
}

class AppCreateValidated extends AppCreateInitialised {
  AppCreateValidated(
      super.appModel,
      super.pages,
      super.dialogs,
      super.workflows,
      super.policies,
      super.homeMenuModel,
      super.appBarModel,
      super.leftDrawerModel,
      super.rightDrawerModel);

  @override
  List<Object?> get props => [
        appModel,
        pages,
        dialogs,
        policies,
        workflows,
        homeMenuModel,
        appBarModel,
        leftDrawerModel,
        rightDrawerModel
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppCreateValidated &&
          appModel == other.appModel &&
          ListEquality().equals(pages, other.pages) &&
          ListEquality().equals(dialogs, other.dialogs) &&
          ListEquality().equals(workflows, other.workflows) &&
          ListEquality().equals(policies, other.policies) &&
          homeMenuModel == other.homeMenuModel &&
          appBarModel == other.appBarModel &&
          leftDrawerModel == other.leftDrawerModel &&
          rightDrawerModel == other.rightDrawerModel;

  @override
  int get hashCode =>
      appModel.hashCode ^
      pages.hashCode ^
      dialogs.hashCode ^
      workflows.hashCode ^
      policies.hashCode ^
      homeMenuModel.hashCode ^
      appBarModel.hashCode ^
      leftDrawerModel.hashCode ^
      rightDrawerModel.hashCode;
}

class AppCreateChangesApplied extends AppCreateInitialised {
  AppCreateChangesApplied(
      super.appModel,
      super.pages,
      super.dialogs,
      super.workflows,
      super.policies,
      super.homeMenuModel,
      super.appBarModel,
      super.leftDrawerModel,
      super.rightDrawerModel);

  @override
  List<Object?> get props => [appModel];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppCreateChangesApplied &&
          appModel == other.appModel &&
          appModel == other.appModel &&
          ListEquality().equals(pages, other.pages) &&
          ListEquality().equals(dialogs, other.dialogs) &&
          ListEquality().equals(workflows, other.workflows) &&
          ListEquality().equals(policies, other.policies) &&
          homeMenuModel == other.homeMenuModel &&
          appBarModel == other.appBarModel &&
          leftDrawerModel == other.leftDrawerModel &&
          rightDrawerModel == other.rightDrawerModel;

  @override
  int get hashCode =>
      appModel.hashCode ^
      pages.hashCode ^
      dialogs.hashCode ^
      workflows.hashCode ^
      policies.hashCode ^
      homeMenuModel.hashCode ^
      appBarModel.hashCode ^
      leftDrawerModel.hashCode ^
      rightDrawerModel.hashCode;
}
