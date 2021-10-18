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

import 'package:eliud_pkg_create/model/play_store_model.dart';
import 'package:eliud_pkg_create/model/play_store_component_event.dart';
import 'package:eliud_pkg_create/model/play_store_component_state.dart';
import 'package:eliud_pkg_create/model/play_store_repository.dart';
import 'package:flutter/services.dart';


class PlayStoreComponentBloc extends Bloc<PlayStoreComponentEvent, PlayStoreComponentState> {
  final PlayStoreRepository? playStoreRepository;
  StreamSubscription? _playStoreSubscription;

  Stream<PlayStoreComponentState> _mapLoadPlayStoreComponentUpdateToState(String documentId) async* {
    _playStoreSubscription?.cancel();
    _playStoreSubscription = playStoreRepository!.listenTo(documentId, (value) {
      if (value != null) add(PlayStoreComponentUpdated(value: value));
    });
  }

  PlayStoreComponentBloc({ this.playStoreRepository }): super(PlayStoreComponentUninitialized());

  @override
  Stream<PlayStoreComponentState> mapEventToState(PlayStoreComponentEvent event) async* {
    final currentState = state;
    if (event is FetchPlayStoreComponent) {
      yield* _mapLoadPlayStoreComponentUpdateToState(event.id!);
    } else if (event is PlayStoreComponentUpdated) {
      yield PlayStoreComponentLoaded(value: event.value);
    }
  }

  @override
  Future<void> close() {
    _playStoreSubscription?.cancel();
    return super.close();
  }

}

