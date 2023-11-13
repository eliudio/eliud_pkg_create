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

/* 
 * PlayStoreComponentState is the base class for state for PlayStoreComponentBloc
 */
abstract class PlayStoreComponentState extends Equatable {
  const PlayStoreComponentState();

  @override
  List<Object?> get props => [];
}

/* 
 * PlayStoreComponentUninitialized is the uninitialized state of the PlayStoreComponentBloc 
 */
class PlayStoreComponentUninitialized extends PlayStoreComponentState {}

/* 
 * PlayStoreComponentError is the error state of the PlayStoreComponentBloc 
 */
class PlayStoreComponentError extends PlayStoreComponentState {
  final String? message;
  PlayStoreComponentError({this.message});
}

/* 
 * PlayStoreComponentPermissionDenied is to indicate permission denied state of the PlayStoreComponentBloc 
 */
class PlayStoreComponentPermissionDenied extends PlayStoreComponentState {
  PlayStoreComponentPermissionDenied();
}

/* 
 * PlayStoreComponentLoaded is used to set the state of the PlayStoreComponentBloc to the loaded state
 */
class PlayStoreComponentLoaded extends PlayStoreComponentState {
  final PlayStoreModel value;

  /* 
   * construct PlayStoreComponentLoaded
   */
  const PlayStoreComponentLoaded({required this.value});

  /* 
   * copy method
   */
  PlayStoreComponentLoaded copyWith({PlayStoreModel? copyThis}) {
    return PlayStoreComponentLoaded(value: copyThis ?? value);
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'PlayStoreComponentLoaded { value: $value }';
}
