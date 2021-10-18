import 'package:eliud_core/model/abstract_repository_singleton.dart' as corerepo;
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/conditions_model.dart';
import 'package:eliud_core/model/conditions_simple_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/model/platform_medium_model.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/tools/page/page_helper.dart';
import 'package:eliud_pkg_etc/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_etc/model/policy_presentation_component.dart';
import 'package:eliud_pkg_etc/model/policy_presentation_model.dart';

class PolicyPageHelper extends PageHelper {
  final PlatformMediumModel policy;
  final String title;

  PolicyPageHelper(String pageId, AppModel newApp, MemberModel member, HomeMenuModel theHomeMenu, AppBarModel theAppBar, DrawerModel leftDrawer, DrawerModel rightDrawer, this.policy,
      this.title,
      ) : super(pageId, newApp, member, theHomeMenu, theAppBar, leftDrawer, rightDrawer);


  PolicyPresentationModel _getPesentationModel(PlatformMediumModel? policyModel) {
    return PolicyPresentationModel(
      documentID: policy.documentID,
      appId: newAppId(),
      description: title,
      policy: policyModel,
      conditions: ConditionsSimpleModel(
          privilegeLevelRequired:
          PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple),
    );
  }

  Future<PolicyPresentationModel> _createPresentationComponent(PlatformMediumModel? policyModel) async {
    return await policyPresentationRepository(appId: newAppId())!
        .add(_getPesentationModel(policyModel));
  }

  Future<PageModel> _setupPage() async {
    return await corerepo.AbstractRepositorySingleton.singleton
        .pageRepository(newAppId())!
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
        appId: newAppId(),
        title: title,
        drawer: leftDrawer,
        endDrawer: rightDrawer,
        appBar: theAppBar,
        homeMenu: theHomeMenu,
        layout: PageLayout.ListView,
        conditions: ConditionsModel(
          privilegeLevelRequired: PrivilegeLevelRequired.NoPrivilegeRequired,
        ),
        bodyComponents: components);
  }

  Future<PageModel> create() async {
    await _createPresentationComponent(policy);
    return await _setupPage();
  }
}
