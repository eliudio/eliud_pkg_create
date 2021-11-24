/*
       _ _           _ 
      | (_)         | |
   ___| |_ _   _  __| |
  / _ \ | | | | |/ _` |
 |  __/ | | |_| | (_| |
  \___|_|_|\__,_|\__,_|
                       
 
 play_store_component_state.dart
                       
 This code is generated. This is read only. Don't touch!

*/

import 'package:equatable/equatable.dart';
import 'package:eliud_pkg_create/model/play_store_model.dart';

abstract class PlayStoreComponentState extends Equatable {
  const PlayStoreComponentState();

  @override
  List<Object?> get props => [];
}

class PlayStoreComponentUninitialized extends PlayStoreComponentState {}

class PlayStoreComponentError extends PlayStoreComponentState {
  final String? message;
  PlayStoreComponentError({ this.message });
}

class PlayStoreComponentPermissionDenied extends PlayStoreComponentState {
  PlayStoreComponentPermissionDenied();
}

class PlayStoreComponentLoaded extends PlayStoreComponentState {
  final PlayStoreModel value;

  const PlayStoreComponentLoaded({ required this.value });

  PlayStoreComponentLoaded copyWith({ PlayStoreModel? copyThis }) {
    return PlayStoreComponentLoaded(value: copyThis ?? this.value);
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'PlayStoreComponentLoaded { value: $value }';
}

