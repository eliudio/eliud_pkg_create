/*
       _ _           _ 
      | (_)         | |
   ___| |_ _   _  __| |
  / _ \ | | | | |/ _` |
 |  __/ | | |_| | (_| |
  \___|_|_|\__,_|\__,_|
                       
 
 play_store_list_event.dart
                       
 This code is generated. This is read only. Don't touch!

*/

import 'package:eliud_core/tools/query/query_tools.dart';
import 'package:equatable/equatable.dart';
import 'package:eliud_pkg_create/model/play_store_model.dart';

abstract class PlayStoreListEvent extends Equatable {
  const PlayStoreListEvent();
  @override
  List<Object?> get props => [];
}

class LoadPlayStoreList extends PlayStoreListEvent {}

class NewPage extends PlayStoreListEvent {}

class AddPlayStoreList extends PlayStoreListEvent {
  final PlayStoreModel? value;

  const AddPlayStoreList({ this.value });

  @override
  List<Object?> get props => [ value ];

  @override
  String toString() => 'AddPlayStoreList{ value: $value }';
}

class UpdatePlayStoreList extends PlayStoreListEvent {
  final PlayStoreModel? value;

  const UpdatePlayStoreList({ this.value });

  @override
  List<Object?> get props => [ value ];

  @override
  String toString() => 'UpdatePlayStoreList{ value: $value }';
}

class DeletePlayStoreList extends PlayStoreListEvent {
  final PlayStoreModel? value;

  const DeletePlayStoreList({ this.value });

  @override
  List<Object?> get props => [ value ];

  @override
  String toString() => 'DeletePlayStoreList{ value: $value }';
}

class PlayStoreListUpdated extends PlayStoreListEvent {
  final List<PlayStoreModel?>? value;
  final bool? mightHaveMore;

  const PlayStoreListUpdated({ this.value, this.mightHaveMore });

  @override
  List<Object?> get props => [ value, mightHaveMore ];

  @override
  String toString() => 'PlayStoreListUpdated{ value: $value, mightHaveMore: $mightHaveMore }';
}

class PlayStoreChangeQuery extends PlayStoreListEvent {
  final EliudQuery? newQuery;

  const PlayStoreChangeQuery({ required this.newQuery });

  @override
  List<Object?> get props => [ newQuery ];

  @override
  String toString() => 'PlayStoreChangeQuery{ value: $newQuery }';
}

