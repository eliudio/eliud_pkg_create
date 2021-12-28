/*
       _ _           _ 
      | (_)         | |
   ___| |_ _   _  __| |
  / _ \ | | | | |/ _` |
 |  __/ | | |_| | (_| |
  \___|_|_|\__,_|\__,_|
                       
 
 play_store_model.dart
                       
 This code is generated. This is read only. Don't touch!

*/

import 'package:eliud_core/tools/common_tools.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:eliud_core/model/repository_export.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import 'package:eliud_pkg_create/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_create/model/repository_export.dart';
import 'package:eliud_core/model/model_export.dart';
import '../tools/bespoke_models.dart';
import 'package:eliud_pkg_create/model/model_export.dart';
import 'package:eliud_core/model/entity_export.dart';
import '../tools/bespoke_entities.dart';
import 'package:eliud_pkg_create/model/entity_export.dart';


import 'package:eliud_pkg_create/model/play_store_entity.dart';

import 'package:eliud_core/tools/random.dart';



class PlayStoreModel {
  String? documentID;
  String? appId;
  String? description;
  BackgroundModel? itemBackground;
  StorageConditionsModel? conditions;

  PlayStoreModel({this.documentID, this.appId, this.description, this.itemBackground, this.conditions, })  {
    assert(documentID != null);
  }

  PlayStoreModel copyWith({String? documentID, String? appId, String? description, BackgroundModel? itemBackground, StorageConditionsModel? conditions, }) {
    return PlayStoreModel(documentID: documentID ?? this.documentID, appId: appId ?? this.appId, description: description ?? this.description, itemBackground: itemBackground ?? this.itemBackground, conditions: conditions ?? this.conditions, );
  }

  @override
  int get hashCode => documentID.hashCode ^ appId.hashCode ^ description.hashCode ^ itemBackground.hashCode ^ conditions.hashCode;

  @override
  bool operator ==(Object other) =>
          identical(this, other) ||
          other is PlayStoreModel &&
          runtimeType == other.runtimeType && 
          documentID == other.documentID &&
          appId == other.appId &&
          description == other.description &&
          itemBackground == other.itemBackground &&
          conditions == other.conditions;

  @override
  String toString() {
    return 'PlayStoreModel{documentID: $documentID, appId: $appId, description: $description, itemBackground: $itemBackground, conditions: $conditions}';
  }

  PlayStoreEntity toEntity({String? appId}) {
    return PlayStoreEntity(
          appId: (appId != null) ? appId : null, 
          description: (description != null) ? description : null, 
          itemBackgroundId: (itemBackground != null) ? itemBackground!.documentID : null, 
          conditions: (conditions != null) ? conditions!.toEntity(appId: appId) : null, 
    );
  }

  static Future<PlayStoreModel?> fromEntity(String documentID, PlayStoreEntity? entity) async {
    if (entity == null) return null;
    var counter = 0;
    return PlayStoreModel(
          documentID: documentID, 
          appId: entity.appId, 
          description: entity.description, 
          conditions: 
            await StorageConditionsModel.fromEntity(entity.conditions), 
    );
  }

  static Future<PlayStoreModel?> fromEntityPlus(String documentID, PlayStoreEntity? entity, { String? appId}) async {
    if (entity == null) return null;

    BackgroundModel? itemBackgroundHolder;
    if (entity.itemBackgroundId != null) {
      try {
          itemBackgroundHolder = await backgroundRepository(appId: appId)!.get(entity.itemBackgroundId);
      } on Exception catch(e) {
        print('Error whilst trying to initialise itemBackground');
        print('Error whilst retrieving background with id ${entity.itemBackgroundId}');
        print('Exception: $e');
      }
    }

    var counter = 0;
    return PlayStoreModel(
          documentID: documentID, 
          appId: entity.appId, 
          description: entity.description, 
          itemBackground: itemBackgroundHolder, 
          conditions: 
            await StorageConditionsModel.fromEntityPlus(entity.conditions, appId: appId), 
    );
  }

}

