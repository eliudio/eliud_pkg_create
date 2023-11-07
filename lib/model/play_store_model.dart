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

import 'package:eliud_core/core/base/model_base.dart';

import 'package:eliud_core/model/model_export.dart';
import 'package:eliud_pkg_create/model/entity_export.dart';

import 'package:eliud_pkg_create/model/play_store_entity.dart';

class PlayStoreModel implements ModelBase, WithAppId {
  static const String packageName = 'eliud_pkg_create';
  static const String id = 'playStores';

  @override
  String documentID;
  @override
  String appId;
  String? description;
  BackgroundModel? backgroundIcon;
  StorageConditionsModel? conditions;

  PlayStoreModel({
    required this.documentID,
    required this.appId,
    this.description,
    this.backgroundIcon,
    this.conditions,
  });

  @override
  PlayStoreModel copyWith({
    String? documentID,
    String? appId,
    String? description,
    BackgroundModel? backgroundIcon,
    StorageConditionsModel? conditions,
  }) {
    return PlayStoreModel(
      documentID: documentID ?? this.documentID,
      appId: appId ?? this.appId,
      description: description ?? this.description,
      backgroundIcon: backgroundIcon ?? this.backgroundIcon,
      conditions: conditions ?? this.conditions,
    );
  }

  @override
  int get hashCode =>
      documentID.hashCode ^
      appId.hashCode ^
      description.hashCode ^
      backgroundIcon.hashCode ^
      conditions.hashCode;

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
  String toString() {
    return 'PlayStoreModel{documentID: $documentID, appId: $appId, description: $description, backgroundIcon: $backgroundIcon, conditions: $conditions}';
  }

  @override
  Future<List<ModelReference>> collectReferences({String? appId}) async {
    List<ModelReference> referencesCollector = [];
    if (backgroundIcon != null) {
      referencesCollector
          .addAll(await backgroundIcon!.collectReferences(appId: appId));
    }
    if (conditions != null) {
      referencesCollector
          .addAll(await conditions!.collectReferences(appId: appId));
    }
    return referencesCollector;
  }

  @override
  PlayStoreEntity toEntity({String? appId}) {
    return PlayStoreEntity(
      appId: appId,
      description: (description != null) ? description : null,
      backgroundIcon: (backgroundIcon != null)
          ? backgroundIcon!.toEntity(appId: appId)
          : null,
      conditions:
          (conditions != null) ? conditions!.toEntity(appId: appId) : null,
    );
  }

  static Future<PlayStoreModel?> fromEntity(
      String documentID, PlayStoreEntity? entity) async {
    if (entity == null) return null;
    return PlayStoreModel(
      documentID: documentID,
      appId: entity.appId ?? '',
      description: entity.description,
      backgroundIcon: await BackgroundModel.fromEntity(entity.backgroundIcon),
      conditions: await StorageConditionsModel.fromEntity(entity.conditions),
    );
  }

  static Future<PlayStoreModel?> fromEntityPlus(
      String documentID, PlayStoreEntity? entity,
      {String? appId}) async {
    if (entity == null) return null;

    return PlayStoreModel(
      documentID: documentID,
      appId: entity.appId ?? '',
      description: entity.description,
      backgroundIcon: await BackgroundModel.fromEntityPlus(
          entity.backgroundIcon,
          appId: appId),
      conditions: await StorageConditionsModel.fromEntityPlus(entity.conditions,
          appId: appId),
    );
  }
}
