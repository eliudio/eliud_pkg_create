import 'package:eliud_core/model/abstract_repository_singleton.dart'
    as corerepo;
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/model_export.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/dialog/dialog_builder.dart';
import 'package:eliud_pkg_notifications/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_notifications/model/notification_dashboard_component.dart';
import 'package:eliud_pkg_notifications/model/notification_dashboard_model.dart';

class NotificationDashboardDialogBuilder extends DialogBuilder {
  NotificationDashboardDialogBuilder(AppModel app, String dialogDocumentId) : super(app, dialogDocumentId);

  Future<DialogModel> create() async {
    await _setupDashboard();
    return await _setupDialog();
  }

  Future<DialogModel> _setupDialog() async {
    return await corerepo.AbstractRepositorySingleton.singleton
        .dialogRepository(app.documentID!)!
        .add(_dialog());
  }

  DialogModel _dialog() {
    List<BodyComponentModel> components = [];
    components.add(BodyComponentModel(
        documentID: "1",
        componentName: AbstractNotificationDashboardComponent.componentName,
        componentId: dialogDocumentId));

    return DialogModel(
        documentID: dialogDocumentId,
        appId: app.documentID!,
        title: "Notifications",
        layout: DialogLayout.ListView,
        conditions: StorageConditionsModel(
          privilegeLevelRequired: PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple,
        ),
        bodyComponents: components);
  }

  NotificationDashboardModel _dashboardModel() {
    return NotificationDashboardModel(
        documentID: dialogDocumentId,
        appId: app.documentID!,
        description: "My Notifications",
        conditions: StorageConditionsModel(
          privilegeLevelRequired: PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple
        ),
    );
  }

  Future<NotificationDashboardModel> _setupDashboard() async {
    return await AbstractRepositorySingleton.singleton
        .notificationDashboardRepository(app.documentID!)!
        .add(_dashboardModel());
  }

}
