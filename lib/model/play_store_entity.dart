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
import 'package:eliud_core/core/base/entity_base.dart';
import 'package:eliud_core/model/entity_export.dart';

class PlayStoreEntity implements EntityBase {
  final String? appId;
  final String? description;
  final BackgroundEntity? backgroundIcon;
  final StorageConditionsEntity? conditions;

  PlayStoreEntity({required this.appId, this.description, this.backgroundIcon, this.conditions, });

  PlayStoreEntity copyWith({String? documentID, String? appId, String? description, BackgroundEntity? backgroundIcon, StorageConditionsEntity? conditions, }) {
    return PlayStoreEntity(appId : appId ?? this.appId, description : description ?? this.description, backgroundIcon : backgroundIcon ?? this.backgroundIcon, conditions : conditions ?? this.conditions, );
  }
  List<Object?> get props => [appId, description, backgroundIcon, conditions, ];

  @override
  String toString() {
    return 'PlayStoreEntity{appId: $appId, description: $description, backgroundIcon: $backgroundIcon, conditions: $conditions}';
  }

  static PlayStoreEntity? fromMap(Object? o, {Map<String, String>? newDocumentIds}) {
    if (o == null) return null;
    var map = o as Map<String, dynamic>;

    var backgroundIconFromMap;
    backgroundIconFromMap = map['backgroundIcon'];
    if (backgroundIconFromMap != null)
      backgroundIconFromMap = BackgroundEntity.fromMap(backgroundIconFromMap, newDocumentIds: newDocumentIds);
    var conditionsFromMap;
    conditionsFromMap = map['conditions'];
    if (conditionsFromMap != null)
      conditionsFromMap = StorageConditionsEntity.fromMap(conditionsFromMap, newDocumentIds: newDocumentIds);

    return PlayStoreEntity(
      appId: map['appId'], 
      description: map['description'], 
      backgroundIcon: backgroundIconFromMap, 
      conditions: conditionsFromMap, 
    );
  }

  Map<String, Object?> toDocument() {
    final Map<String, dynamic>? backgroundIconMap = backgroundIcon != null 
        ? backgroundIcon!.toDocument()
        : null;
    final Map<String, dynamic>? conditionsMap = conditions != null 
        ? conditions!.toDocument()
        : null;

    Map<String, Object?> theDocument = HashMap();
    if (appId != null) theDocument["appId"] = appId;
      else theDocument["appId"] = null;
    if (description != null) theDocument["description"] = description;
      else theDocument["description"] = null;
    if (backgroundIcon != null) theDocument["backgroundIcon"] = backgroundIconMap;
      else theDocument["backgroundIcon"] = null;
    if (conditions != null) theDocument["conditions"] = conditionsMap;
      else theDocument["conditions"] = null;
    return theDocument;
  }

  @override
  PlayStoreEntity switchAppId({required String newAppId}) {
    var newEntity = copyWith(appId: newAppId);
    return newEntity;
  }

  static PlayStoreEntity? fromJsonString(String json, {Map<String, String>? newDocumentIds}) {
    Map<String, dynamic>? generationSpecificationMap = jsonDecode(json);
    return fromMap(generationSpecificationMap, newDocumentIds: newDocumentIds);
  }

  String toJsonString() {
    return jsonEncode(toDocument());
  }

  Future<Map<String, Object?>> enrichedDocument(Map<String, Object?> theDocument) async {
    return theDocument;
  }

}

