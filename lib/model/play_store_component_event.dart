/*
       _ _           _ 
      | (_)         | |
   ___| |_ _   _  __| |
  / _ \ | | | | |/ _` |
 |  __/ | | |_| | (_| |
  \___|_|_|\__,_|\__,_|
                       
 
 play_store_component_event.dart
                       
 This code is generated. This is read only. Don't touch!

*/

import 'package:equatable/equatable.dart';
import 'package:eliud_pkg_create/model/play_store_model.dart';

/*
 * PlayStoreComponentEvent is the base class for events to be used with constructing a PlayStoreComponentBloc 
 */
abstract class PlayStoreComponentEvent extends Equatable {
  @override
  List<Object> get props => [];
}

/*
 * FetchPlayStoreComponent is the event to instruct the bloc to fetch the component
 */
class FetchPlayStoreComponent extends PlayStoreComponentEvent {
  final String? id;

  /*
   * Construct the FetchPlayStoreComponent
   */
  FetchPlayStoreComponent({this.id});
}

/*
 * PlayStoreComponentUpdated is the event to inform the bloc that a component has been updated
 */
class PlayStoreComponentUpdated extends PlayStoreComponentEvent {
  final PlayStoreModel value;

  /*
   * Construct the PlayStoreComponentUpdated
   */
  PlayStoreComponentUpdated({required this.value});
}
