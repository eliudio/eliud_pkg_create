import 'package:eliud_core_helpers/repository/repository_base.dart';
import 'package:eliud_core_main/apis/apis.dart';
import 'package:eliud_core_main/model/body_component_model.dart';
import 'package:eliud_core_main/apis/registryapi/component/component_spec.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

abstract class BodyComponentsCreateState extends Equatable {
  const BodyComponentsCreateState();

  @override
  List<Object?> get props => [];
}

class BodyComponentsCreateUninitialised extends BodyComponentsCreateState {}

class BodyComponentsCreateInitialised extends BodyComponentsCreateState {
  final List<BodyComponentModel> bodyComponentModels;
  final List<PluginWithComponents> pluginWithComponents;
  final BodyComponentModel? currentlySelected;

  BodyComponentsCreateInitialised(
      {required this.bodyComponentModels,
      required this.pluginWithComponents,
      this.currentlySelected});

  @override
  List<Object?> get props =>
      [bodyComponentModels, pluginWithComponents, currentlySelected];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyComponentsCreateInitialised &&
          ListEquality()
              .equals(bodyComponentModels, other.bodyComponentModels) &&
          currentlySelected == other.currentlySelected;

  BodyComponentsCreateInitialised copyWith(
      {List<BodyComponentModel>? bodyComponentModels,
      List<PluginWithComponents>? pluginWithComponents,
      BodyComponentModel? currentlySelected}) {
    return BodyComponentsCreateInitialised(
        bodyComponentModels: bodyComponentModels ?? this.bodyComponentModels,
        pluginWithComponents: pluginWithComponents ?? this.pluginWithComponents,
        currentlySelected: currentlySelected);
  }

  @override
  int get hashCode =>
      bodyComponentModels.hashCode ^
      pluginWithComponents.hashCode ^
      currentlySelected.hashCode;
}

List<PluginWithComponents> retrievePluginsWithComponents() =>
    Apis.apis().getRegistryApi().componentSpecMap().entries.map((entry) {
      var key = entry.key;
      var friendlyName =
          Apis.apis().getRegistryApi().packageFriendlyNames()[key];
      return PluginWithComponents(key, friendlyName ?? '?', entry.value);
    }).toList();

Future<RepositoryBase?> getRepository(
    String appId, String searchPluginName, String searchComponentName) async {
  var pluginsWithComponents = retrievePluginsWithComponents();
  for (var pluginsWithComponent in pluginsWithComponents) {
    var pluginName = pluginsWithComponent.name;
    for (var componentSpec in pluginsWithComponent.componentSpec) {
      var componentName = componentSpec.name;
      if ((searchPluginName == pluginName) &&
          (searchComponentName == componentName)) {
        return componentSpec.retrieveRepository(appId: appId);
      }
    }
  }
  return null;
}

ComponentSpec getComponentSpec(String pluginName, String componentId) {
  var plugin = Apis.apis().getRegistryApi().componentSpecMap()[pluginName];
  if (plugin != null) {
    for (var component in plugin) {
      if (component.name == componentId) {
        return component;
      }
    }
    throw Exception(
        "Plugin with name '$pluginName' does not contain component with id $componentId");
  } else {
    throw Exception("Plugin with name '$pluginName' does not exist");
  }
}

class PluginWithComponents {
  final String name;
  final String friendlyName;
  final List<ComponentSpec> componentSpec;

  PluginWithComponents(this.name, this.friendlyName, this.componentSpec);
}
