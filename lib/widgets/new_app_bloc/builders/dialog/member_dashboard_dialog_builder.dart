import 'package:eliud_core/core_package.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart'
    as corerepo;
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/member_dashboard_component.dart';
import 'package:eliud_core/model/model_export.dart';

import 'dialog_builder.dart';

String updateProfileText = '''
Maintain your personal details here
''';

String retrieveDataText = '''
Retrieve all you account details, every single piece of information that you have shared with us will be made available to you
''';

String deleteDataText = """
Do you want to leave us? Do you want to delete every single detail, every potential photo, video, text, anything?
Then here's where you can do this.
However, be careful: this process cannot be undone and everything you've ever stored here will be removed permanently",
""";

String retrieveDataEmailSubject = """
Your request for retrieving your data...
""";

String deleteDataEmailSubject = """
Your request to destroy your account...
""";

String deleteDataEmailMessage = """
Sorry to see you go. Your account has been destroyed.
""";

class MemberDashboardDialogBuilder extends DialogBuilder {
  MemberDashboardDialogBuilder(String appId, String dialogDocumentId): super(appId, dialogDocumentId);

  Future<DialogModel> _setupDialog() async {
    return await corerepo.AbstractRepositorySingleton.singleton
        .dialogRepository(appId)!
        .add(_dialog());
  }

  DialogModel _dialog() {
    List<BodyComponentModel> components = [];
    components.add(BodyComponentModel(
        documentID: "1",
        componentName: AbstractMemberDashboardComponent.componentName,
        componentId: dialogDocumentId));

    return DialogModel(
        documentID: dialogDocumentId,
        appId: appId,
        title: "Member dashboard",
        layout: DialogLayout.ListView,
        conditions: ConditionsModel(
            privilegeLevelRequired: PrivilegeLevelRequired.NoPrivilegeRequired,
            packageCondition: CorePackage.MUST_BE_LOGGED_ON
        ),
        bodyComponents: components);
  }

  MemberDashboardModel _dashboardModel() {
    return MemberDashboardModel(
        documentID: dialogDocumentId,
        appId: appId,
        description: "Member dashboard",
        updateProfileText: updateProfileText,
        retrieveDataText: retrieveDataText,
        deleteDataText: deleteDataText,
        retrieveDataEmailSubject: retrieveDataEmailSubject,
        deleteDataEmailSubject: deleteDataEmailSubject,
        deleteDataEmailMessage: deleteDataEmailMessage,
        conditions: ConditionsSimpleModel(
            privilegeLevelRequired: PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple
        ),
    );
  }

  Future<MemberDashboardModel> _setupDashboard() async {
    return await corerepo.AbstractRepositorySingleton.singleton
        .memberDashboardRepository(appId)!
        .add(_dashboardModel());
  }

  Future<DialogModel> create() async {
    await _setupDashboard();
    return await _setupDialog();
  }
}
