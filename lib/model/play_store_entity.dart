/*
       _ _           _ 
      | (_)         | |
   ___| |_ _   _  __| |
  / _ \ | | | | |/ _` |
 |  __/ | | |_| | (_| |
  \___|_|_|\__,_|\__,_|
                       
 
 play_store_entity.dart
                       
 This code is generated. This is read only. Don't touch!

*/

import 'dart:collection';
import 'dart:convert';
import 'abstract_repository_singleton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eliud_core/model/entity_export.dart';
import '../tools/bespoke_entities.dart';
import 'package:eliud_pkg_create/model/entity_export.dart';

import 'package:eliud_core/tools/common_tools.dart';
class PlayStoreEntity {
  final String? appId;
  final String? description;
  final BackgroundEntity? itemBackground;
  final StorageConditionsEntity? conditions;

  PlayStoreEntity({this.appId, this.description, this.itemBackground, this.conditions, });


  List<Object?> get props => [appId, description, itemBackground, conditions, ];

  @override
  String toString() {
    return 'PlayStoreEntity{appId: $appId, description: $description, itemBackground: $itemBackground, conditions: $conditions}';
  }

  static PlayStoreEntity? fromMap(Object? o) {
    if (o == null) return null;
    var map = o as Map<String, dynamic>;

    var itemBackgroundFromMap;
    itemBackgroundFromMap = map['itemBackground'];
    if (itemBackgroundFromMap != null)
      itemBackgroundFromMap = BackgroundEntity.fromMap(itemBackgroundFromMap);
    var conditionsFromMap;
    conditionsFromMap = map['conditions'];
    if (conditionsFromMap != null)
      conditionsFromMap = StorageConditionsEntity.fromMap(conditionsFromMap);

    return PlayStoreEntity(
      appId: map['appId'], 
      description: map['description'], 
      itemBackground: itemBackgroundFromMap, 
      conditions: conditionsFromMap, 
    );
  }

  Map<String, Object?> toDocument() {
    final Map<String, dynamic>? itemBackgroundMap = itemBackground != null 
        ? itemBackground!.toDocument()
        : null;
    final Map<String, dynamic>? conditionsMap = conditions != null 
        ? conditions!.toDocument()
        : null;

    Map<String, Object?> theDocument = HashMap();
    if (appId != null) theDocument["appId"] = appId;
      else theDocument["appId"] = null;
    if (description != null) theDocument["description"] = description;
      else theDocument["description"] = null;
    if (itemBackground != null) theDocument["itemBackground"] = itemBackgroundMap;
      else theDocument["itemBackground"] = null;
    if (conditions != null) theDocument["conditions"] = conditionsMap;
      else theDocument["conditions"] = null;
    return theDocument;
  }

  static PlayStoreEntity? fromJsonString(String json) {
    Map<String, dynamic>? generationSpecificationMap = jsonDecode(json);
    return fromMap(generationSpecificationMap);
  }

  String toJsonString() {
    return jsonEncode(toDocument());
  }

}

