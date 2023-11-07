/*
       _ _           _ 
      | (_)         | |
   ___| |_ _   _  __| |
  / _ \ | | | | |/ _` |
 |  __/ | | |_| | (_| |
  \___|_|_|\__,_|\__,_|
                       
 
 play_store_list_bloc.dart
                       
 This code is generated. This is read only. Don't touch!

*/

import 'dart:async';
import 'package:bloc/bloc.dart';

import 'package:eliud_pkg_create/model/play_store_repository.dart';
import 'package:eliud_pkg_create/model/play_store_list_event.dart';
import 'package:eliud_pkg_create/model/play_store_list_state.dart';
import 'package:eliud_core/tools/query/query_tools.dart';

import 'play_store_model.dart';

typedef FilterPlayStoreModels = List<PlayStoreModel?> Function(
    List<PlayStoreModel?> values);

class PlayStoreListBloc extends Bloc<PlayStoreListEvent, PlayStoreListState> {
  final FilterPlayStoreModels? filter;
  final PlayStoreRepository _playStoreRepository;
  StreamSubscription? _playStoresListSubscription;
  EliudQuery? eliudQuery;
  int pages = 1;
  final bool? paged;
  final String? orderBy;
  final bool? descending;
  final bool? detailed;
  final int playStoreLimit;

  PlayStoreListBloc(
      {this.filter,
      this.paged,
      this.orderBy,
      this.descending,
      this.detailed,
      this.eliudQuery,
      required PlayStoreRepository playStoreRepository,
      this.playStoreLimit = 5})
      : _playStoreRepository = playStoreRepository,
        super(PlayStoreListLoading()) {
    on<LoadPlayStoreList>((event, emit) {
      if ((detailed == null) || (!detailed!)) {
        _mapLoadPlayStoreListToState();
      } else {
        _mapLoadPlayStoreListWithDetailsToState();
      }
    });

    on<NewPage>((event, emit) {
      pages = pages +
          1; // it doesn't matter so much if we increase pages beyond the end
      _mapLoadPlayStoreListWithDetailsToState();
    });

    on<PlayStoreChangeQuery>((event, emit) {
      eliudQuery = event.newQuery;
      if ((detailed == null) || (!detailed!)) {
        _mapLoadPlayStoreListToState();
      } else {
        _mapLoadPlayStoreListWithDetailsToState();
      }
    });

    on<AddPlayStoreList>((event, emit) async {
      await _mapAddPlayStoreListToState(event);
    });

    on<UpdatePlayStoreList>((event, emit) async {
      await _mapUpdatePlayStoreListToState(event);
    });

    on<DeletePlayStoreList>((event, emit) async {
      await _mapDeletePlayStoreListToState(event);
    });

    on<PlayStoreListUpdated>((event, emit) {
      emit(_mapPlayStoreListUpdatedToState(event));
    });
  }

  List<PlayStoreModel?> _filter(List<PlayStoreModel?> original) {
    if (filter != null) {
      return filter!(original);
    } else {
      return original;
    }
  }

  Future<void> _mapLoadPlayStoreListToState() async {
    int amountNow = (state is PlayStoreListLoaded)
        ? (state as PlayStoreListLoaded).values!.length
        : 0;
    _playStoresListSubscription?.cancel();
    _playStoresListSubscription = _playStoreRepository.listen(
        (list) => add(PlayStoreListUpdated(
            value: _filter(list), mightHaveMore: amountNow != list.length)),
        orderBy: orderBy,
        descending: descending,
        eliudQuery: eliudQuery,
        limit: ((paged != null) && paged!) ? pages * playStoreLimit : null);
  }

  Future<void> _mapLoadPlayStoreListWithDetailsToState() async {
    int amountNow = (state is PlayStoreListLoaded)
        ? (state as PlayStoreListLoaded).values!.length
        : 0;
    _playStoresListSubscription?.cancel();
    _playStoresListSubscription = _playStoreRepository.listenWithDetails(
        (list) => add(PlayStoreListUpdated(
            value: _filter(list), mightHaveMore: amountNow != list.length)),
        orderBy: orderBy,
        descending: descending,
        eliudQuery: eliudQuery,
        limit: ((paged != null) && paged!) ? pages * playStoreLimit : null);
  }

  Future<void> _mapAddPlayStoreListToState(AddPlayStoreList event) async {
    var value = event.value;
    if (value != null) {
      await _playStoreRepository.add(value);
    }
  }

  Future<void> _mapUpdatePlayStoreListToState(UpdatePlayStoreList event) async {
    var value = event.value;
    if (value != null) {
      await _playStoreRepository.update(value);
    }
  }

  Future<void> _mapDeletePlayStoreListToState(DeletePlayStoreList event) async {
    var value = event.value;
    if (value != null) {
      await _playStoreRepository.delete(value);
    }
  }

  PlayStoreListLoaded _mapPlayStoreListUpdatedToState(
          PlayStoreListUpdated event) =>
      PlayStoreListLoaded(
          values: event.value, mightHaveMore: event.mightHaveMore);

  @override
  Future<void> close() {
    _playStoresListSubscription?.cancel();
    return super.close();
  }
}
