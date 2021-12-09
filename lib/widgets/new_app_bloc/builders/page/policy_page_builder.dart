import 'package:eliud_core/model/abstract_repository_singleton.dart'
    as corerepo;
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/model/platform_medium_model.dart';
import 'package:eliud_core/model/storage_conditions_model.dart';
import 'page_builder.dart';
import 'package:eliud_pkg_etc/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_etc/model/policy_presentation_component.dart';
import 'package:eliud_pkg_etc/model/policy_presentation_model.dart';

class PolicyPageBuilder extends PageBuilder {
  final PlatformMediumModel policy;
  final String title;

  PolicyPageBuilder(
    String pageId,
    String appId,
    String memberId,
    HomeMenuModel theHomeMenu,
    AppBarModel theAppBar,
    DrawerModel leftDrawer,
    DrawerModel rightDrawer,
    this.policy,
    this.title,
  ) : super(pageId, appId, memberId, theHomeMenu, theAppBar, leftDrawer,
            rightDrawer);

  PolicyPresentationModel _getPesentationModel(
      PlatformMediumModel? policyModel) {
    return PolicyPresentationModel(
      documentID: policy.documentID,
      appId: appId,
      description: title,
      policy: policyModel,
      conditions: StorageConditionsModel(
          privilegeLevelRequired:
              PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple),
    );
  }

  Future<PolicyPresentationModel> _createPresentationComponent(
      PlatformMediumModel? policyModel) async {
    return await policyPresentationRepository(appId: appId)!
        .add(_getPesentationModel(policyModel));
  }

  Future<PageModel> _setupPage() async {
    return await corerepo.AbstractRepositorySingleton.singleton
        .pageRepository(appId)!
        .add(_page());
  }

  PageModel _page() {
    List<BodyComponentModel> components = [
      BodyComponentModel(
          documentID: policy.documentID,
          componentName: AbstractPolicyPresentationComponent.componentName,
          componentId: policy.documentID)
    ];

    return PageModel(
        documentID: pageId,
        appId: appId,
        title: title,
        drawer: leftDrawer,
        endDrawer: rightDrawer,
        appBar: theAppBar,
        homeMenu: theHomeMenu,
        layout: PageLayout.ListView,
        conditions: StorageConditionsModel(
          privilegeLevelRequired: PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple,
        ),
        bodyComponents: components);
  }

  Future<PageModel> create() async {
    await _createPresentationComponent(policy);
    return await _setupPage();
  }
}
