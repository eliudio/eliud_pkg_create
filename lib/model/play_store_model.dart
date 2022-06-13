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
import 'package:eliud_core/core/base/model_base.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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



class PlayStoreModel implements ModelBase, WithAppId {
  String documentID;
  String appId;
  String? description;
  BackgroundModel? backgroundIcon;
  StorageConditionsModel? conditions;

  PlayStoreModel({required this.documentID, required this.appId, this.description, this.backgroundIcon, this.conditions, })  {
    assert(documentID != null);
  }

  PlayStoreModel copyWith({String? documentID, String? appId, String? description, BackgroundModel? backgroundIcon, StorageConditionsModel? conditions, }) {
    return PlayStoreModel(documentID: documentID ?? this.documentID, appId: appId ?? this.appId, description: description ?? this.description, backgroundIcon: backgroundIcon ?? this.backgroundIcon, conditions: conditions ?? this.conditions, );
  }

  @override
  int get hashCode => documentID.hashCode ^ appId.hashCode ^ description.hashCode ^ backgroundIcon.hashCode ^ conditions.hashCode;

  @override
  bool operator ==(Object other) =>
          identical(this, other) ||
          other is PlayStoreModel &&
          runtimeType == other.runtimeType && 
          documentID == other.documentID &&
          appId == other.appId &&
          description == other.description &&
          backgroundIcon == other.backgroundIcon &&
          conditions == other.conditions;

  @override
  Future<String> toRichJsonString({String? appId}) async {
    var document = toEntity(appId: appId).toDocument();
    document['documentID'] = documentID;
    return jsonEncode(document);
  }

  @override
  String toString() {
    return 'PlayStoreModel{documentID: $documentID, appId: $appId, description: $description, backgroundIcon: $backgroundIcon, conditions: $conditions}';
  }

  PlayStoreEntity toEntity({String? appId}) {
    return PlayStoreEntity(
          appId: (appId != null) ? appId : null, 
          description: (description != null) ? description : null, 
          backgroundIcon: (backgroundIcon != null) ? backgroundIcon!.toEntity(appId: appId) : null, 
          conditions: (conditions != null) ? conditions!.toEntity(appId: appId) : null, 
    );
  }

  static Future<PlayStoreModel?> fromEntity(String documentID, PlayStoreEntity? entity) async {
    if (entity == null) return null;
    var counter = 0;
    return PlayStoreModel(
          documentID: documentID, 
          appId: entity.appId ?? '', 
          description: entity.description, 
          backgroundIcon: 
            await BackgroundModel.fromEntity(entity.backgroundIcon), 
          conditions: 
            await StorageConditionsModel.fromEntity(entity.conditions), 
    );
  }

  static Future<PlayStoreModel?> fromEntityPlus(String documentID, PlayStoreEntity? entity, { String? appId}) async {
    if (entity == null) return null;

    var counter = 0;
    return PlayStoreModel(
          documentID: documentID, 
          appId: entity.appId ?? '', 
          description: entity.description, 
          backgroundIcon: 
            await BackgroundModel.fromEntityPlus(entity.backgroundIcon, appId: appId), 
          conditions: 
            await StorageConditionsModel.fromEntityPlus(entity.conditions, appId: appId), 
    );
  }

}

