import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/tools/component/component_spec.dart';
import 'package:flutter/material.dart';
import 'package:eliud_core/core/blocs/access/access_bloc.dart';

class PlayStoreComponentEditorConstructor extends ComponentEditorConstructor {
  @override
  void updateComponent(AppModel app, BuildContext context, model, EditorFeedback feedback) {
    openErrorDialog(app, context, app.documentID! + '/_error', title: 'Problem', errorMessage: 'No editor for this component available yet');
  }

  @override
  void createNewComponent(AppModel app, BuildContext context, EditorFeedback feedback) {
    openErrorDialog(app, context, app.documentID! + '/_error', title: 'Problem', errorMessage: 'No editor for this component available yet');
  }

  @override
  void updateComponentWithID(AppModel app, BuildContext context, String id, EditorFeedback feedback) {
    openErrorDialog(app, context, app.documentID! + '/_error', title: 'Problem', errorMessage: 'No editor for this component available yet');
  }
}
