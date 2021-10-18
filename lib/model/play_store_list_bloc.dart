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
import 'package:meta/meta.dart';

import 'package:eliud_pkg_create/model/play_store_repository.dart';
import 'package:eliud_pkg_create/model/play_store_list_event.dart';
import 'package:eliud_pkg_create/model/play_store_list_state.dart';
import 'package:eliud_core/tools/query/query_tools.dart';



class PlayStoreListBloc extends Bloc<PlayStoreListEvent, PlayStoreListState> {
  final PlayStoreRepository _playStoreRepository;
  StreamSubscription? _playStoresListSubscription;
  final EliudQuery? eliudQuery;
  int pages = 1;
  final bool? paged;
  final String? orderBy;
  final bool? descending;
  final bool? detailed;
  final int playStoreLimit;

  PlayStoreListBloc({this.paged, this.orderBy, this.descending, this.detailed, this.eliudQuery, required PlayStoreRepository playStoreRepository, this.playStoreLimit = 5})
      : assert(playStoreRepository != null),
        _playStoreRepository = playStoreRepository,
        super(PlayStoreListLoading());

  Stream<PlayStoreListState> _mapLoadPlayStoreListToState() async* {
    int amountNow =  (state is PlayStoreListLoaded) ? (state as PlayStoreListLoaded).values!.length : 0;
    _playStoresListSubscription?.cancel();
    _playStoresListSubscription = _playStoreRepository.listen(
          (list) => add(PlayStoreListUpdated(value: list, mightHaveMore: amountNow != list.length)),
      orderBy: orderBy,
      descending: descending,
      eliudQuery: eliudQuery,
      limit: ((paged != null) && paged!) ? pages * playStoreLimit : null
    );
  }

  Stream<PlayStoreListState> _mapLoadPlayStoreListWithDetailsToState() async* {
    int amountNow =  (state is PlayStoreListLoaded) ? (state as PlayStoreListLoaded).values!.length : 0;
    _playStoresListSubscription?.cancel();
    _playStoresListSubscription = _playStoreRepository.listenWithDetails(
            (list) => add(PlayStoreListUpdated(value: list, mightHaveMore: amountNow != list.length)),
        orderBy: orderBy,
        descending: descending,
        eliudQuery: eliudQuery,
        limit: ((paged != null) && paged!) ? pages * playStoreLimit : null
    );
  }

  Stream<PlayStoreListState> _mapAddPlayStoreListToState(AddPlayStoreList event) async* {
    var value = event.value;
    if (value != null) 
      _playStoreRepository.add(value);
  }

  Stream<PlayStoreListState> _mapUpdatePlayStoreListToState(UpdatePlayStoreList event) async* {
    var value = event.value;
    if (value != null) 
      _playStoreRepository.update(value);
  }

  Stream<PlayStoreListState> _mapDeletePlayStoreListToState(DeletePlayStoreList event) async* {
    var value = event.value;
    if (value != null) 
      _playStoreRepository.delete(value);
  }

  Stream<PlayStoreListState> _mapPlayStoreListUpdatedToState(
      PlayStoreListUpdated event) async* {
    yield PlayStoreListLoaded(values: event.value, mightHaveMore: event.mightHaveMore);
  }

  @override
  Stream<PlayStoreListState> mapEventToState(PlayStoreListEvent event) async* {
    if (event is LoadPlayStoreList) {
      if ((detailed == null) || (!detailed!)) {
        yield* _mapLoadPlayStoreListToState();
      } else {
        yield* _mapLoadPlayStoreListWithDetailsToState();
      }
    }
    if (event is NewPage) {
      pages = pages + 1; // it doesn't matter so much if we increase pages beyond the end
      yield* _mapLoadPlayStoreListWithDetailsToState();
    } else if (event is AddPlayStoreList) {
      yield* _mapAddPlayStoreListToState(event);
    } else if (event is UpdatePlayStoreList) {
      yield* _mapUpdatePlayStoreListToState(event);
    } else if (event is DeletePlayStoreList) {
      yield* _mapDeletePlayStoreListToState(event);
    } else if (event is PlayStoreListUpdated) {
      yield* _mapPlayStoreListUpdatedToState(event);
    }
  }

  @override
  Future<void> close() {
    _playStoresListSubscription?.cancel();
    return super.close();
  }
}


