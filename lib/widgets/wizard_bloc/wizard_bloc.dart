import 'package:bloc/bloc.dart';
import 'package:eliud_core/access/access_bloc.dart';
import 'package:eliud_pkg_create/widgets/wizard_bloc/wizard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core_main/model/app_model.dart';
import 'builders/wizard_runner.dart';
import 'wizard_event.dart';

class WizardBloc extends Bloc<WizardEvent, WizardState> {
  final AppModel app;
  final AccessBloc accessBloc;

  WizardBloc(this.app, this.accessBloc) : super(NewAppCreateUninitialised()) {
    on<WizardInitialise>((event, emit) {
      emit(WizardAllowEnterDetails(event.member));
    });

    //else if ((state is WizardInitialised) && (event is WizardConfirm)) {

    on<WizardConfirm>((event, emit) {
      if (state is WizardInitialised) {
        var theState = state as WizardInitialised;
        //      emit(WizardRunning(theState.app, theState.member, ));
        WizardRunner(
          app,
          theState.member,
          autoPrivileged1: event.autoPrivileged1,
          newAppWizardParameters: event.newAppWizardParameters,
          styleFamily: event.styleFamily,
          styleName: event.styleName,
          accessBloc: accessBloc,
        ).create(accessBloc, this).then((value) => add(WizardFinished(
              true,
            )));
      }
    });

    on<WizardFinished>((event, emit) {
      if (state is WizardInitialised) {
        var theState = state as WizardInitialised;
        emit(WizardCreated(theState.member, event.success));
      }
    });

    on<WizardProgressed>((event, emit) {
      if (state is WizardInitialised) {
        var theState = state as WizardInitialised;
        emit(WizardCreateInProgress(theState.member, event.progress));
      }
    });

    on<WizardCancelled>((event, emit) {
      if (state is WizardInitialised) {
        var theState = state as WizardInitialised;
        emit(WizardCreateCancelled(
          theState.member,
        ));
      }
    });
  }
}
