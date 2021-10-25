import 'package:bloc/bloc.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/tools/helpers/progress_manager.dart';
import '../action_specification.dart';
import 'app_bar_helper.dart';
import 'dialog/chat_dialog_helper.dart';
import 'home_menu_helper.dart';
import 'left_drawer_helper.dart';
import 'link_specifications.dart';
import 'member_dashboard_helper.dart';
import 'page/policy_page_helper.dart';
import 'page/welcome_page_helper.dart';
import 'policy/policy_medium_helper.dart';
import 'right_drawer_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/model/app_home_page_references_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/style/_default/default_style_family.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import '../new_app_event.dart';
import '../new_app_state.dart';
import 'policy/app_policy_helper.dart';

class NewAppHelper {
  Future<AppModel> createNewApp(
    AppModel newApp,
    MemberModel member, {
    PublicMediumModel? logo,
    required ActionSpecification includeWelcome,
    required ShopActionSpecifications includeShop,
    required ActionSpecification includeChat,
    required ActionSpecification includeFeed,
    required ActionSpecification includeMemberDashboard,
    required ActionSpecification includeExamplePolicy,
    required ActionSpecification includeSignoutButton,
    required ActionSpecification includeFlushButton,
    required JoinActionSpecifications joinSpecification,
  }) async {
    var newAppId = newApp.documentID!;
    var memberId = member.documentID!;

    move all the stuff from LinkSpecifications in here
    rename helper to builder
    await LinkSpecifications().create();

    // app
    var appModel = await appRepository()!.add(AppModel(
        documentID: newAppId,
        title: 'New application',
        ownerID: member.documentID,
        styleFamily:
            newApp.styleFamily ?? DefaultStyleFamily.defaultStyleFamilyName,
        styleName: newApp.styleName ?? DefaultStyle.defaultStyleName,
        email: member.email,
        policies: policyModel,
        description: 'Your new application',
        logo: logo,
        homePages: AppHomePageReferencesModel(
          homePageBlockedMember: homePage.documentID,
          homePagePublic: homePage.documentID,
          homePageSubscribedMember: homePage.documentID,
          homePageLevel1Member: homePage.documentID,
          homePageLevel2Member: homePage.documentID,
          homePageOwner: homePage.documentID,
        )));
    return appModel;
  }
}
