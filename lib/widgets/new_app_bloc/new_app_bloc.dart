import 'package:bloc/bloc.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/tools/helpers/progress_manager.dart';
import 'builders/app_bar_helper.dart';
import 'builders/dialog/chat_dialog_helper.dart';
import 'builders/home_menu_helper.dart';
import 'builders/left_drawer_helper.dart';
import 'builders/member_dashboard_helper.dart';
import 'builders/new_app_helper.dart';
import 'builders/page/policy_page_helper.dart';
import 'builders/page/welcome_page_helper.dart';
import 'builders/policy/policy_medium_helper.dart';
import 'builders/right_drawer_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/model/app_home_page_references_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/style/_default/default_style_family.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'new_app_event.dart';
import 'new_app_state.dart';
import 'builders/policy/app_policy_helper.dart';

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
        NewAppHelper().createNewApp(theState.appToBeCreated, theState.member,
            logo: theState.appToBeCreated.logo,
            includeWelcome: event.includeWelcome,
            includeShop: event.includeShop,
            includeChat: event.includeChat,
            includeFeed: event.includeFeed,
            includeMemberDashboard: event.includeMemberDashboard,
            includeExamplePolicy: event.includeExamplePolicy,
            includeSignoutButton: event.includeSignoutButton,
            includeFlushButton: event.includeFlushButton,
            includeWorkflowForManuallyPaidMembership: event.includeWorkflowForManuallyPaidMembership,
            includeWorkflowForMembershipPaidByCard: event.includeWorkflowForMembershipPaidByCard,
            includeWorkflowForManualPaymentCart: event.includeWorkflowForManualPaymentCart,
            includeWorkflowForCreditCardPaymentCart: event.includeWorkflowForCreditCardPaymentCart,
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
}
