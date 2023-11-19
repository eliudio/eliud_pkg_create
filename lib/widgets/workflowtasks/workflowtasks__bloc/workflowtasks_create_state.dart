import 'package:eliud_core/core/registry.dart';
import 'package:eliud_core_model/tools/component/component_spec.dart';
import 'package:eliud_pkg_workflow/model/workflow_task_model.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

abstract class WorkflowTasksCreateState extends Equatable {
  const WorkflowTasksCreateState();

  @override
  List<Object?> get props => [];
}

class WorkflowTasksCreateUninitialised extends WorkflowTasksCreateState {}

class WorkflowTasksCreateInitialised extends WorkflowTasksCreateState {
  final List<WorkflowTaskModel> workflowTaskModels;
  final WorkflowTaskModel? currentlySelected;

  WorkflowTasksCreateInitialised(
      {required this.workflowTaskModels, this.currentlySelected});

  @override
  List<Object?> get props => [workflowTaskModels, currentlySelected];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkflowTasksCreateInitialised &&
          ListEquality().equals(workflowTaskModels, other.workflowTaskModels) &&
          currentlySelected == other.currentlySelected;

  WorkflowTasksCreateInitialised copyWith(
      {List<WorkflowTaskModel>? workflowTaskModels,
      List<PluginWithComponents>? pluginWithComponents,
      WorkflowTaskModel? currentlySelected}) {
    return WorkflowTasksCreateInitialised(
        workflowTaskModels: workflowTaskModels ?? this.workflowTaskModels,
        currentlySelected: currentlySelected);
  }

  @override
  int get hashCode => workflowTaskModels.hashCode ^ currentlySelected.hashCode;
}

List<PluginWithComponents> retrievePluginsWithComponents() =>
    Apis.apis()
        .componentSpecMap()
        .entries
        .map((entry) => PluginWithComponents(entry.key, entry.value))
        .toList();

class PluginWithComponents {
  final String name;
  final List<ComponentSpec> componentSpec;

  PluginWithComponents(this.name, this.componentSpec);
}
