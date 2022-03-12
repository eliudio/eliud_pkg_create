import 'package:bloc/bloc.dart';
import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_pkg_create/widgets/wizard_bloc/wizard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/model/app_model.dart';
import 'builders/wizard_runner.dart';
import 'wizard_event.dart';

class WizardBloc extends Bloc<WizardEvent, WizardState> {
  final AppModel app;
  final AccessBloc accessBloc;

  WizardBloc(this.app, this.accessBloc) : super(NewAppCreateUninitialised());

  @override
  Stream<WizardState> mapEventToState(WizardEvent event) async* {
    if (event is WizardInitialise) {
      yield WizardAllowEnterDetails(app, event.member);
    } else if ((state is WizardInitialised) && (event is WizardConfirm)) {
      var theState = state as WizardInitialised;
      yield WizardRunning(theState.app, theState.member, event.wizardMessage);
      WizardRunner(
        theState.app,
        theState.member,
        autoPrivileged1: event.autoPrivileged1,
        newAppWizardParameters: event.newAppWizardParameters,
        styleFamily: event.styleFamily,
        styleName: event.styleName,
        accessBloc: accessBloc,
      ).create(accessBloc, this).then((value) => add(WizardFinished(true)));
    } else if (state is WizardRunning) {
      var theState = state as WizardRunning;
      if (event is WizardFinished) {
        yield WizardCreated(theState.app, theState.member,
            theState.wizardMessage, event.success);
      } else if (event is WizardProgressed) {
        var theState = state as WizardRunning;
        yield WizardCreateInProgress(theState.app, theState.member,
            theState.wizardMessage, event.progress);
      } else if (event is WizardCancelled) {
        yield WizardCreateCancelled(
            theState.app, theState.member, theState.wizardMessage);
      }
    }
  }
}
