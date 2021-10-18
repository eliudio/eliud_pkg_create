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

abstract class PlayStoreComponentEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchPlayStoreComponent extends PlayStoreComponentEvent {
  final String? id;

  FetchPlayStoreComponent({ this.id });
}

class PlayStoreComponentUpdated extends PlayStoreComponentEvent {
  final PlayStoreModel value;

  PlayStoreComponentUpdated({ required this.value });
}


