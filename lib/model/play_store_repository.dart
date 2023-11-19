/*
       _ _           _ 
      | (_)         | |
   ___| |_ _   _  __| |
  / _ \ | | | | |/ _` |
 |  __/ | | |_| | (_| |
  \___|_|_|\__,_|\__,_|
                       
 
 play_store_repository.dart
                       
 This code is generated. This is read only. Don't touch!

*/

import 'package:eliud_pkg_create/model/model_export.dart';
import 'package:eliud_pkg_create/model/entity_export.dart';

import 'dart:async';
import 'package:eliud_core_model/tools/query/query_tools.dart';
import 'package:eliud_core/tools/common_tools.dart';
import 'package:eliud_core/core/base/repository_base.dart';

typedef PlayStoreModelTrigger = Function(List<PlayStoreModel?> list);
typedef PlayStoreChanged = Function(PlayStoreModel? value);
typedef PlayStoreErrorHandler = Function(dynamic o, dynamic e);

abstract class PlayStoreRepository
    extends RepositoryBase<PlayStoreModel, PlayStoreEntity> {
  @override
  Future<PlayStoreEntity> addEntity(String documentID, PlayStoreEntity value);
  @override
  Future<PlayStoreEntity> updateEntity(
      String documentID, PlayStoreEntity value);
  @override
  Future<PlayStoreModel> add(PlayStoreModel value);
  @override
  Future<void> delete(PlayStoreModel value);
  @override
  Future<PlayStoreModel?> get(String? id, {Function(Exception)? onError});
  @override
  Future<PlayStoreModel> update(PlayStoreModel value);

  @override
  Stream<List<PlayStoreModel?>> values(
      {String? orderBy,
      bool? descending,
      Object? startAfter,
      int? limit,
      SetLastDoc? setLastDoc,
      int? privilegeLevel,
      EliudQuery? eliudQuery});
  @override
  Stream<List<PlayStoreModel?>> valuesWithDetails(
      {String? orderBy,
      bool? descending,
      Object? startAfter,
      int? limit,
      SetLastDoc? setLastDoc,
      int? privilegeLevel,
      EliudQuery? eliudQuery});
  @override
  Future<List<PlayStoreModel?>> valuesList(
      {String? orderBy,
      bool? descending,
      Object? startAfter,
      int? limit,
      SetLastDoc? setLastDoc,
      int? privilegeLevel,
      EliudQuery? eliudQuery});
  @override
  Future<List<PlayStoreModel?>> valuesListWithDetails(
      {String? orderBy,
      bool? descending,
      Object? startAfter,
      int? limit,
      SetLastDoc? setLastDoc,
      int? privilegeLevel,
      EliudQuery? eliudQuery});

  @override
  StreamSubscription<List<PlayStoreModel?>> listen(
      PlayStoreModelTrigger trigger,
      {String? orderBy,
      bool? descending,
      Object? startAfter,
      int? limit,
      int? privilegeLevel,
      EliudQuery? eliudQuery});
  @override
  StreamSubscription<List<PlayStoreModel?>> listenWithDetails(
      PlayStoreModelTrigger trigger,
      {String? orderBy,
      bool? descending,
      Object? startAfter,
      int? limit,
      int? privilegeLevel,
      EliudQuery? eliudQuery});
  @override
  StreamSubscription<PlayStoreModel?> listenTo(
      String documentId, PlayStoreChanged changed,
      {PlayStoreErrorHandler? errorHandler});
  @override
  void flush();

  @override
  String? timeStampToString(dynamic timeStamp);

  @override
  dynamic getSubCollection(String documentId, String name);
  @override
  Future<PlayStoreModel?> changeValue(
      String documentId, String fieldName, num changeByThisValue);

  @override
  Future<void> deleteAll();
}
