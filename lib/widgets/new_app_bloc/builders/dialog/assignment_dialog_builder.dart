import 'package:eliud_core/model/abstract_repository_singleton.dart' as corerepo;
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/model_export.dart';
import 'package:eliud_pkg_workflow/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_workflow/model/assignment_view_component.dart';
import 'package:eliud_pkg_workflow/model/assignment_view_model.dart';
import 'package:eliud_pkg_workflow/workflow_package.dart';

import 'dialog_builder.dart';

class AssignmentDialogBuilder  extends DialogBuilder {
  AssignmentDialogBuilder(String appId, String dialogDocumentId) : super(appId, dialogDocumentId);

  Future<DialogModel> _setupDialog() async {
    return await corerepo.AbstractRepositorySingleton.singleton.dialogRepository(appId)!.add(_dialog());
  }

  DialogModel _dialog() {
    List<BodyComponentModel> components = [];
    components.add(BodyComponentModel(
        documentID: "1", componentName: AbstractAssignmentViewComponent.componentName, componentId: dialogDocumentId));

    return DialogModel(
        documentID: dialogDocumentId,
        appId: appId,
        title: "Assignments",
        layout: DialogLayout.ListView,
        conditions: StorageConditionsModel(
            privilegeLevelRequired: PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple,
        ),
        bodyComponents: components);
  }

  AssignmentViewModel _assignmentViewModel() {
    return AssignmentViewModel(
        documentID: dialogDocumentId,
        appId: appId,
        description: "My Assignments",
        conditions: StorageConditionsModel(
          privilegeLevelRequired: PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple
        ),
    );
  }

  Future<AssignmentViewModel> _setupAssignmentView() async {
    return await AbstractRepositorySingleton.singleton.assignmentViewRepository(appId)!.add(_assignmentViewModel());
  }

  Future<DialogModel> create() async {
    await _setupAssignmentView();
    return await _setupDialog();
  }
}
