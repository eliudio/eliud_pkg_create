import 'package:eliud_core/model/abstract_repository_singleton.dart'
    as corerepo;
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/model_export.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/helpers/profile_and_feed_to_action.dart';
import 'package:eliud_pkg_membership/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_membership/model/membership_dashboard_component.dart';
import 'package:eliud_pkg_membership/model/membership_dashboard_model.dart';
import 'dialog_builder.dart';

class MembershipDashboardDialogBuilder extends DialogBuilder {
  final String? profilePageId;
  final String? feedPageId;

  MembershipDashboardDialogBuilder(String appId, String dialogDocumentId, {required this.profilePageId, required this.feedPageId})
      : super(appId, dialogDocumentId);

  Future<DialogModel> _setupDialog() async {
    return await corerepo.AbstractRepositorySingleton.singleton
        .dialogRepository(appId)!
        .add(_dialog());
  }

  DialogModel _dialog() {
    List<BodyComponentModel> components = [];
    components.add(BodyComponentModel(
        documentID: "1",
        componentName: AbstractMembershipDashboardComponent.componentName,
        componentId: dialogDocumentId));

    return DialogModel(
        documentID: dialogDocumentId,
        appId: appId,
        title: "Membership dashboard",
        layout: DialogLayout.ListView,
        conditions: StorageConditionsModel(
          privilegeLevelRequired: PrivilegeLevelRequiredSimple.OwnerPrivilegeRequiredSimple,
        ),
        bodyComponents: components);
  }

  MembershipDashboardModel _dashboardModel() {
    return MembershipDashboardModel(
        documentID: dialogDocumentId,
        appId: appId,
        description: "Members",
        memberActions: ProfileAndFeedToAction.getMemberActionModels(appId, profilePageId, feedPageId),
        conditions: StorageConditionsModel(
            privilegeLevelRequired: PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple
        ),
    );
  }

  Future<MembershipDashboardModel> _setupDashboard() async {
    return await AbstractRepositorySingleton.singleton
        .membershipDashboardRepository(appId)!
        .add(_dashboardModel());
  }

  Future<DialogModel> create() async {
    await _setupDashboard();
    return await _setupDialog();
  }
}
