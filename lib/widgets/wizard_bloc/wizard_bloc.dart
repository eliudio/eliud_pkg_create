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

  WizardBloc(this.app, this.accessBloc) : super(NewAppCreateUninitialised()) {
    on<WizardInitialise>((event, emit) {
      emit(WizardAllowEnterDetails(app, event.member));
    });

    //else if ((state is WizardInitialised) && (event is WizardConfirm)) {

    on<WizardConfirm>((event, emit) {
      var theState = state as WizardInitialised;
//      emit(WizardRunning(theState.app, theState.member, event.wizardMessage));
      WizardRunner(
        theState.app,
        theState.member,
        autoPrivileged1: event.autoPrivileged1,
        newAppWizardParameters: event.newAppWizardParameters,
        styleFamily: event.styleFamily,
        styleName: event.styleName,
        accessBloc: accessBloc,
      ).create(accessBloc, this).then((value) => add(WizardFinished(true)));
    });

    on<WizardFinished>((event, emit) {
      var theState = state as WizardRunning;
      emit(WizardCreated(theState.app, theState.member, theState.wizardMessage,
          event.success));
    });

    on<WizardProgressed>((event, emit) {
      var theState = state as WizardRunning;
      emit(WizardCreateInProgress(theState.app, theState.member,
          theState.wizardMessage, event.progress));
    });

    on<WizardCancelled>((event, emit) {
      var theState = state as WizardRunning;
      emit(WizardCreateCancelled(
          theState.app, theState.member, theState.wizardMessage));
    });
  }
}
