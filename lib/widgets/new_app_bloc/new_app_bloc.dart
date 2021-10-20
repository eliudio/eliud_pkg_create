import 'package:bloc/bloc.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/tools/helpers/progress_manager.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/tools/app_bar_helper.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/tools/dialog/chat_dialog_helper.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/tools/home_menu_helper.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/tools/left_drawer_helper.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/tools/member_dashboard_helper.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/tools/page/policy_page_helper.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/tools/page/welcome_page_helper.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/tools/policy/policy_medium_helper.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/tools/right_drawer_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/model/app_home_page_references_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/style/_default/default_style_family.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'new_app_event.dart';
import 'new_app_state.dart';
import 'tools/policy/app_policy_helper.dart';

class NewAppCreateBloc extends Bloc<NewAppCreateEvent, NewAppCreateState> {
  NewAppCreateBloc() : super(NewAppCreateUninitialised());

  @override
  Stream<NewAppCreateState> mapEventToState(NewAppCreateEvent event) async* {
    if (event is NewAppCreateEventInitialise) {
      var appToBeCreated = AppModel(
          documentID: event.initialAppIdToBeCreated,
          ownerID: event.member.documentID!);
      yield NewAppCreateAllowEnterDetails(appToBeCreated, event.member);
    } else if (state is NewAppCreateInitialised) {
      var theState = state as NewAppCreateInitialised;
      if (event is NewAppCreateConfirm) {
        createNewApp(theState.appToBeCreated, theState.member,
            logo: theState.appToBeCreated.logo,
            includeWelcome: event.includeWelcome,
            includeShop: event.includeShop,
            includeChat: event.includeChat,
            includeFeed: event.includeFeed,
            includeMemberDashboard: event.includeMemberDashboard,
            includeExamplePolicy: event.includeExamplePolicy,
            includeSignoutButton: event.includeSignoutButton,
            includeFlushButton: event.includeFlushButton,
        );
      } else if (event is NewAppSwitchAppEvent) {
        yield SwitchApp(theState.appToBeCreated, theState.member);
      } else if (event is NewAppCreateProgressed) {
        yield NewAppCreateCreateInProgress(
            theState.appToBeCreated, theState.member, event.progress);
      } else if (event is NewAppCancelled) {
        yield NewAppCreateCreateCancelled(
          theState.appToBeCreated,
          theState.member,
        );
      }
    }
  }

  Future<void> createNewApp(
    AppModel newApp,
    MemberModel member, {
    PublicMediumModel? logo,
    bool? includeWelcome,
    bool? includeShop,
    bool? includeChat,
    bool? includeFeed,
    bool? includeMemberDashboard,
    bool? includeExamplePolicy,
    bool? includeSignoutButton,
    bool? includeFlushButton
  }) async {
    var shopPageId = (includeShop ?? false) ? 'shop' : null;
    var feedPageId = (includeFeed ?? false) ? 'feed' : null;
    var policyPageId = (includeExamplePolicy ?? false) ? 'policy' : null;
    var welcomePageId = (includeWelcome ?? false) ? 'welcome' : null;

    var progressManager = ProgressManager(
        9, (progress) => add(NewAppCreateProgressed(progress)),
        weightedSteps: {6: 10});
    var newAppId = newApp.documentID!;
    var memberId = member.documentID!;

    // chat
    var chatDialogs = await ChatDialogHelper(newApp).create();

    // member dashboard
    var memberDashboard = null;
    if (includeMemberDashboard ?? false) {
      memberDashboard = await MemberDashboardHelper(newAppId).create();
    }

    // feed

    // shop

    // home menu
    var theHomeMenu = await HomeMenuHelper(newAppId, welcomePageId: welcomePageId, feedPageId: feedPageId, shopPageId: shopPageId).create();

    // app bar
    var theAppBar = await AppBarHelper(newAppId, chatDialogs: chatDialogs).create();

    // left drawer
    var leftDrawer = await LeftDrawerHelper(
      newAppId,
      logo: logo,
      welcomePageId: welcomePageId,
      policyPageId: policyPageId,
      feedPageId: feedPageId,
      shopPageId: shopPageId,
    ).create();

    // Right drawer
    var rightDrawer =
        await RightDrawerHelper(newAppId, memberDashboard: memberDashboard, withSignOut: includeSignoutButton ?? false, withFlush: includeFlushButton ?? false)
            .create();

    // policy
    var policyMedium;
    var policyModel;
    if (includeExamplePolicy ?? false) {
      // policy medium
      policyMedium =
          await PolicyMediumHelper((value) => {}, newAppId, memberId).create();

      // policy
      policyModel =
          await AppPolicyHelper(newAppId, memberId, policyMedium).create();

      // policy page
      await PolicyPageHelper(
              policyPageId!,
              newApp,
              member,
              theHomeMenu,
              theAppBar,
              leftDrawer,
              rightDrawer,
              policyMedium,
              'Policy')
          .create();
    }

    // welcome page
    var homePage = await WelcomePageHelper(welcomePageId!, newApp, member,
            theHomeMenu, theAppBar, leftDrawer, rightDrawer)
        .create();
    progressManager.progressedNextStep(); // step 5
    if (state is NewAppCreateCreateCancelled) return;

    // app
    await appRepository()!.add(AppModel(
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
    progressManager.progressedNextStep(); // step 8
    // if (state is NewAppCreateCreateCancelled) return;  if the cancel happened AFTER creating the app, then too bad, we switch to it
    add(NewAppSwitchAppEvent());
  }
}
