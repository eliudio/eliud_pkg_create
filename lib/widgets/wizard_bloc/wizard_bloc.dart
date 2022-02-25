import 'package:bloc/bloc.dart';
import 'package:eliud_pkg_create/widgets/wizard_bloc/wizard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/model/app_model.dart';
import 'builders/wizard_runner.dart';
import 'wizard_event.dart';

class WizardBloc extends Bloc<WizardEvent, WizardState> {
  final AppModel app;
  WizardBloc(this.app) : super(NewAppCreateUninitialised());

  @override
  Stream<WizardState> mapEventToState(WizardEvent event) async* {
    if (event is WizardInitialise) {
      yield WizardAllowEnterDetails(app, event.member);
    } else if (state is WizardInitialised) {
      var theState = state as WizardInitialised;
      if (event is WizardConfirm) {
        add(WizardProgressed(0));
        WizardRunner(
          theState.app,
          theState.member,
          logo: theState.app.logo,
          newAppWizardParameters: event.newAppWizardParameters,
          signinButton: event.includeSigninButton,
          signoutButton: event.includeSignoutButton,
        ).create(this);
      } else if (event is WizardSwitchAppEvent) {
        yield WizardSwitchApp(theState.app, theState.member);
      } else if (event is WizardProgressed) {
        yield WizardCreateInProgress(
            theState.app, theState.member, event.progress);
      } else if (event is WizardCancelled) {
        yield WizardCreateCancelled(
          theState.app,
          theState.member,
        );
      }
    }
  }
}
