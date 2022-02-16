import 'package:bloc/bloc.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/tools/helpers/progress_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/model/app_home_page_references_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/style/_default/default_style_family.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'builders/app_builder.dart';
import 'new_app_event.dart';
import 'new_app_state.dart';

class NewAppCreateBloc extends Bloc<NewAppCreateEvent, NewAppCreateState> {
  NewAppCreateBloc() : super(NewAppCreateUninitialised());

  @override
  Stream<NewAppCreateState> mapEventToState(NewAppCreateEvent event) async* {
    if (event is NewAppCreateEventInitialise) {
      var appToBeCreated = AppModel(
          documentID: event.initialAppIdToBeCreated,
          appStatus: AppStatus.Offline,
          ownerID: event.member.documentID!);
      yield NewAppCreateAllowEnterDetails(appToBeCreated, event.member);
    } else if (state is NewAppCreateInitialised) {
      var theState = state as NewAppCreateInitialised;
      if (event is NewAppCreateConfirm) {
        add(NewAppCreateProgressed(0));
        AppBuilder(
          theState.appToBeCreated,
          theState.member,
          logo: theState.appToBeCreated.logo,
          newAppWizardParameters: event.newAppWizardParameters,
          signinButton: event.includeSigninButton,
          signoutButton: event.includeSignoutButton,
          flushButton: event.includeFlushButton,
        ).create(this);
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
