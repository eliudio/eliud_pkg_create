import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import 'builders/app_builder.dart';
import 'new_app_event.dart';
import 'new_app_state.dart';

class NewAppCreateBloc extends Bloc<NewAppCreateEvent, NewAppCreateState> {
  NewAppCreateBloc() : super(NewAppCreateUninitialised()) {
    on<NewAppCreateEventInitialise>((event, emit) {
      var appToBeCreated = AppModel(
          documentID: event.initialAppIdToBeCreated,
          appStatus: AppStatus.Offline,
          ownerID: event.member.documentID);
      emit(NewAppCreateAllowEnterDetails(appToBeCreated, event.member));
    });

    on<NewAppCreateConfirm>((event, emit) async {
      var theState = state as NewAppCreateInitialised;
      var appId = theState.appToBeCreated.documentID;
      var app = await appRepository()!.get(appId);
      if (app == null) {
        add(NewAppCreateProgressed(0));
        AppBuilder(
          theState.appToBeCreated,
          theState.member,
        ).create(this, event.fromClipboard);
      } else {
        emit(NewAppCreateError(theState.appToBeCreated, theState.member,
            'App with ID $appId already exists. Choose a unique identifier'));
      }
    });

    on<NewAppSwitchAppEvent>((event, emit) {
      var theState = state as NewAppCreateInitialised;
      emit(SwitchApp(theState.appToBeCreated, theState.member));
    });

    on<NewAppCreateProgressed>((event, emit) {
      var theState = state as NewAppCreateInitialised;
      emit(NewAppCreateCreateInProgress(
          theState.appToBeCreated, theState.member, event.progress));
    });

    on<NewAppCancelled>((event, emit) {
      var theState = state as NewAppCreateInitialised;
      emit(NewAppCreateCreateCancelled(
        theState.appToBeCreated,
        theState.member,
      ));
    });
  }
}
