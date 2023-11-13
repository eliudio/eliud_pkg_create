/*
       _ _           _ 
      | (_)         | |
   ___| |_ _   _  __| |
  / _ \ | | | | |/ _` |
 |  __/ | | |_| | (_| |
  \___|_|_|\__,_|\__,_|
                       
 
 play_store_component_bloc.dart
                       
 This code is generated. This is read only. Don't touch!

*/

import 'dart:async';
import 'package:bloc/bloc.dart';

import 'package:eliud_pkg_create/model/play_store_component_event.dart';
import 'package:eliud_pkg_create/model/play_store_component_state.dart';
import 'package:eliud_pkg_create/model/play_store_repository.dart';

class PlayStoreComponentBloc
    extends Bloc<PlayStoreComponentEvent, PlayStoreComponentState> {
  final PlayStoreRepository? playStoreRepository;
  StreamSubscription? _playStoreSubscription;

  void _mapLoadPlayStoreComponentUpdateToState(String documentId) {
    _playStoreSubscription?.cancel();
    _playStoreSubscription = playStoreRepository!.listenTo(documentId, (value) {
      if (value != null) {
        add(PlayStoreComponentUpdated(value: value));
      }
    });
  }

  /*
   * Construct PlayStoreComponentBloc
   */
  PlayStoreComponentBloc({this.playStoreRepository})
      : super(PlayStoreComponentUninitialized()) {
    on<FetchPlayStoreComponent>((event, emit) {
      _mapLoadPlayStoreComponentUpdateToState(event.id!);
    });
    on<PlayStoreComponentUpdated>((event, emit) {
      emit(PlayStoreComponentLoaded(value: event.value));
    });
  }

  /*
   * Close the PlayStoreComponentBloc
   */
  @override
  Future<void> close() {
    _playStoreSubscription?.cancel();
    return super.close();
  }
}
