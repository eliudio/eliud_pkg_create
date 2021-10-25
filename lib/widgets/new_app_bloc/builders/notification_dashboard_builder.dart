import 'package:eliud_core/model/abstract_repository_singleton.dart'
    as corerepo;
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/model_export.dart';
import 'package:eliud_pkg_notifications/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_notifications/model/notification_dashboard_component.dart';
import 'package:eliud_pkg_notifications/model/notification_dashboard_model.dart';
import 'package:eliud_pkg_notifications/notifications_package.dart';

class NotificationDashboardBuilder {
  String appId;

  NotificationDashboardBuilder(this.appId
      );

  Future<DialogModel> create() async {
    await _setupDashboard();
    return await _setupDialog();
  }

  static String _IDENTIFIER = "notification_dashboard";

  Future<DialogModel> _setupDialog() async {
    return await corerepo.AbstractRepositorySingleton.singleton
        .dialogRepository(appId)!
        .add(_dialog());
  }

  DialogModel _dialog() {
    List<BodyComponentModel> components = [];
    components.add(BodyComponentModel(
        documentID: "1",
        componentName: AbstractNotificationDashboardComponent.componentName,
        componentId: _IDENTIFIER));

    return DialogModel(
        documentID: _IDENTIFIER,
        appId: appId,
        title: "Notifications",
        layout: DialogLayout.ListView,
        conditions: ConditionsModel(
          privilegeLevelRequired: PrivilegeLevelRequired.NoPrivilegeRequired,
          packageCondition:
              NotificationsPackage.CONDITION_MEMBER_HAS_UNREAD_NOTIFICATIONS,
          conditionOverride: ConditionOverride.InclusiveForBlockedMembers // allow blocked members to see
        ),
        bodyComponents: components);
  }

  NotificationDashboardModel _dashboardModel() {
    return NotificationDashboardModel(
        documentID: _IDENTIFIER,
        appId: appId,
        description: "My Notifications",
        conditions: ConditionsSimpleModel(
          privilegeLevelRequired: PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple
        ),
    );
  }

  Future<NotificationDashboardModel> _setupDashboard() async {
    return await AbstractRepositorySingleton.singleton
        .notificationDashboardRepository(appId)!
        .add(_dashboardModel());
  }

}
