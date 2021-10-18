
import 'package:eliud_core/core/registry.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/tools/component/component_spec.dart';
import 'package:flutter/material.dart';

Future<void> updateComponent(BuildContext context, String? componentName, String? componentId, EditorFeedback editorFeedback) async {
  if (componentName == null) {
    openErrorDialog(context, title: 'Problem', errorMessage: 'Component name is null');
  } else {
    var component = await Registry.registry()!.getComponentSpecs(componentName);
    if (component == null) {
      openErrorDialog(context, title: 'Problem', errorMessage: 'Component specs for $componentName not found');
    } else {
      if (componentId == null) {
        openErrorDialog(context, title: 'Problem', errorMessage: 'Component $componentName with ID $componentId does not exist');
      } else {
        component.editor.updateComponentWithID(context, componentId, editorFeedback);
      }
    }
  }
}
