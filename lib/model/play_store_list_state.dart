/*
       _ _           _ 
      | (_)         | |
   ___| |_ _   _  __| |
  / _ \ | | | | |/ _` |
 |  __/ | | |_| | (_| |
  \___|_|_|\__,_|\__,_|
                       
 
 play_store_list_state.dart
                       
 This code is generated. This is read only. Don't touch!

*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:eliud_pkg_create/model/play_store_model.dart';

abstract class PlayStoreListState extends Equatable {
  const PlayStoreListState();

  @override
  List<Object?> get props => [];
}

class PlayStoreListLoading extends PlayStoreListState {}

class PlayStoreListLoaded extends PlayStoreListState {
  final List<PlayStoreModel?>? values;
  final bool? mightHaveMore;

  const PlayStoreListLoaded({this.mightHaveMore, this.values = const []});

  @override
  List<Object?> get props => [values, mightHaveMore];

  @override
  String toString() => 'PlayStoreListLoaded { values: $values }';

  @override
  bool operator ==(Object other) =>
      other is PlayStoreListLoaded &&
      runtimeType == other.runtimeType &&
      ListEquality().equals(values, other.values) &&
      mightHaveMore == other.mightHaveMore;

  @override
  int get hashCode => values.hashCode ^ mightHaveMore.hashCode;
}

class PlayStoreNotLoaded extends PlayStoreListState {}
