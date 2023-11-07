/*
       _ _           _ 
      | (_)         | |
   ___| |_ _   _  __| |
  / _ \ | | | | |/ _` |
 |  __/ | | |_| | (_| |
  \___|_|_|\__,_|\__,_|
                       
 
 play_store_firestore.dart
                       
 This code is generated. This is read only. Don't touch!

*/

import 'package:eliud_pkg_create/model/play_store_repository.dart';

import 'package:eliud_pkg_create/model/repository_export.dart';
import 'package:eliud_pkg_create/model/model_export.dart';
import 'package:eliud_pkg_create/model/entity_export.dart';

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eliud_core/tools/query/query_tools.dart';
import 'package:eliud_core/tools/firestore/firestore_tools.dart';
import 'package:eliud_core/tools/common_tools.dart';

class PlayStoreFirestore implements PlayStoreRepository {
  @override
  PlayStoreEntity? fromMap(Object? o, {Map<String, String>? newDocumentIds}) {
    return PlayStoreEntity.fromMap(o, newDocumentIds: newDocumentIds);
  }

  @override
  Future<PlayStoreEntity> addEntity(String documentID, PlayStoreEntity value) {
    return playStoreCollection
        .doc(documentID)
        .set(value.toDocument())
        .then((_) => value);
  }

  @override
  Future<PlayStoreEntity> updateEntity(
      String documentID, PlayStoreEntity value) {
    return playStoreCollection
        .doc(documentID)
        .update(value.toDocument())
        .then((_) => value);
  }

  @override
  Future<PlayStoreModel> add(PlayStoreModel value) {
    return playStoreCollection
        .doc(value.documentID)
        .set(value.toEntity(appId: appId).toDocument())
        .then((_) => value);
  }

  @override
  Future<void> delete(PlayStoreModel value) {
    return playStoreCollection.doc(value.documentID).delete();
  }

  @override
  Future<PlayStoreModel> update(PlayStoreModel value) {
    return playStoreCollection
        .doc(value.documentID)
        .update(value.toEntity(appId: appId).toDocument())
        .then((_) => value);
  }

  Future<PlayStoreModel?> _populateDoc(DocumentSnapshot value) async {
    return PlayStoreModel.fromEntity(
        value.id, PlayStoreEntity.fromMap(value.data()));
  }

  Future<PlayStoreModel?> _populateDocPlus(DocumentSnapshot value) async {
    return PlayStoreModel.fromEntityPlus(
        value.id, PlayStoreEntity.fromMap(value.data()),
        appId: appId);
  }

  @override
  Future<PlayStoreEntity?> getEntity(String? id,
      {Function(Exception)? onError}) async {
    try {
      var collection = playStoreCollection.doc(id);
      var doc = await collection.get();
      return PlayStoreEntity.fromMap(doc.data());
    } on Exception catch (e) {
      if (onError != null) {
        onError(e);
      } else {
        print("Error whilst retrieving PlayStore with id $id");
        print("Exceptoin: $e");
      }
    }
    return null;
  }

  @override
  Future<PlayStoreModel?> get(String? id,
      {Function(Exception)? onError}) async {
    try {
      var collection = playStoreCollection.doc(id);
      var doc = await collection.get();
      return await _populateDocPlus(doc);
    } on Exception catch (e) {
      if (onError != null) {
        onError(e);
      } else {
        print("Error whilst retrieving PlayStore with id $id");
        print("Exceptoin: $e");
      }
    }
    return null;
  }

  @override
  StreamSubscription<List<PlayStoreModel?>> listen(
      PlayStoreModelTrigger trigger,
      {String? orderBy,
      bool? descending,
      Object? startAfter,
      int? limit,
      int? privilegeLevel,
      EliudQuery? eliudQuery}) {
    Stream<List<PlayStoreModel?>> stream;
    stream = getQuery(getCollection(),
            orderBy: orderBy,
            descending: descending,
            startAfter: startAfter as DocumentSnapshot?,
            limit: limit,
            privilegeLevel: privilegeLevel,
            eliudQuery: eliudQuery,
            appId: appId)!
        .snapshots()
//  see comment listen(...) above
//  stream = getQuery(playStoreCollection, orderBy: orderBy,  descending: descending,  startAfter: startAfter as DocumentSnapshot?,  limit: limit, privilegeLevel: privilegeLevel, eliudQuery: eliudQuery, appId: appId)!.snapshots()
        .asyncMap((data) async {
      return await Future.wait(
          data.docs.map((doc) => _populateDoc(doc)).toList());
    });

    return stream.listen((listOfPlayStoreModels) {
      trigger(listOfPlayStoreModels);
    });
  }

  @override
  StreamSubscription<List<PlayStoreModel?>> listenWithDetails(
      PlayStoreModelTrigger trigger,
      {String? orderBy,
      bool? descending,
      Object? startAfter,
      int? limit,
      int? privilegeLevel,
      EliudQuery? eliudQuery}) {
    Stream<List<PlayStoreModel?>> stream;
    stream = getQuery(getCollection(),
            orderBy: orderBy,
            descending: descending,
            startAfter: startAfter as DocumentSnapshot?,
            limit: limit,
            privilegeLevel: privilegeLevel,
            eliudQuery: eliudQuery,
            appId: appId)!
        .snapshots()
//  see comment listen(...) above
//  stream = getQuery(playStoreCollection, orderBy: orderBy,  descending: descending,  startAfter: startAfter as DocumentSnapshot?,  limit: limit, privilegeLevel: privilegeLevel, eliudQuery: eliudQuery, appId: appId)!.snapshots()
        .asyncMap((data) async {
      return await Future.wait(
          data.docs.map((doc) => _populateDocPlus(doc)).toList());
    });

    return stream.listen((listOfPlayStoreModels) {
      trigger(listOfPlayStoreModels);
    });
  }

  @override
  StreamSubscription<PlayStoreModel?> listenTo(
      String documentId, PlayStoreChanged changed,
      {PlayStoreErrorHandler? errorHandler}) {
    var stream =
        playStoreCollection.doc(documentId).snapshots().asyncMap((data) {
      return _populateDocPlus(data);
    });
    var theStream = stream.listen((value) {
      changed(value);
    });
    theStream.onError((theException, theStacktrace) {
      if (errorHandler != null) {
        errorHandler(theException, theStacktrace);
      }
    });
    return theStream;
  }

  @override
  Stream<List<PlayStoreModel?>> values(
      {String? orderBy,
      bool? descending,
      Object? startAfter,
      int? limit,
      SetLastDoc? setLastDoc,
      int? privilegeLevel,
      EliudQuery? eliudQuery}) {
    DocumentSnapshot? lastDoc;
    Stream<List<PlayStoreModel?>> values = getQuery(playStoreCollection,
            orderBy: orderBy,
            descending: descending,
            startAfter: startAfter as DocumentSnapshot?,
            limit: limit,
            privilegeLevel: privilegeLevel,
            eliudQuery: eliudQuery,
            appId: appId)!
        .snapshots()
        .asyncMap((snapshot) {
      return Future.wait(snapshot.docs.map((doc) {
        lastDoc = doc;
        return _populateDoc(doc);
      }).toList());
    });
    if ((setLastDoc != null) && (lastDoc != null)) setLastDoc(lastDoc);
    return values;
  }

  @override
  Stream<List<PlayStoreModel?>> valuesWithDetails(
      {String? orderBy,
      bool? descending,
      Object? startAfter,
      int? limit,
      SetLastDoc? setLastDoc,
      int? privilegeLevel,
      EliudQuery? eliudQuery}) {
    DocumentSnapshot? lastDoc;
    Stream<List<PlayStoreModel?>> values = getQuery(playStoreCollection,
            orderBy: orderBy,
            descending: descending,
            startAfter: startAfter as DocumentSnapshot?,
            limit: limit,
            privilegeLevel: privilegeLevel,
            eliudQuery: eliudQuery,
            appId: appId)!
        .snapshots()
        .asyncMap((snapshot) {
      return Future.wait(snapshot.docs.map((doc) {
        lastDoc = doc;
        return _populateDocPlus(doc);
      }).toList());
    });
    if ((setLastDoc != null) && (lastDoc != null)) setLastDoc(lastDoc);
    return values;
  }

  @override
  Future<List<PlayStoreModel?>> valuesList(
      {String? orderBy,
      bool? descending,
      Object? startAfter,
      int? limit,
      SetLastDoc? setLastDoc,
      int? privilegeLevel,
      EliudQuery? eliudQuery}) async {
    DocumentSnapshot? lastDoc;
    List<PlayStoreModel?> values = await getQuery(playStoreCollection,
            orderBy: orderBy,
            descending: descending,
            startAfter: startAfter as DocumentSnapshot?,
            limit: limit,
            privilegeLevel: privilegeLevel,
            eliudQuery: eliudQuery,
            appId: appId)!
        .get()
        .then((value) {
      var list = value.docs;
      return Future.wait(list.map((doc) {
        lastDoc = doc;
        return _populateDoc(doc);
      }).toList());
    });
    if ((setLastDoc != null) && (lastDoc != null)) setLastDoc(lastDoc);
    return values;
  }

  @override
  Future<List<PlayStoreModel?>> valuesListWithDetails(
      {String? orderBy,
      bool? descending,
      Object? startAfter,
      int? limit,
      SetLastDoc? setLastDoc,
      int? privilegeLevel,
      EliudQuery? eliudQuery}) async {
    DocumentSnapshot? lastDoc;
    List<PlayStoreModel?> values = await getQuery(playStoreCollection,
            orderBy: orderBy,
            descending: descending,
            startAfter: startAfter as DocumentSnapshot?,
            limit: limit,
            privilegeLevel: privilegeLevel,
            eliudQuery: eliudQuery,
            appId: appId)!
        .get()
        .then((value) {
      var list = value.docs;
      return Future.wait(list.map((doc) {
        lastDoc = doc;
        return _populateDocPlus(doc);
      }).toList());
    });
    if ((setLastDoc != null) && (lastDoc != null)) setLastDoc(lastDoc);
    return values;
  }

  @override
  void flush() {}

  @override
  Future<void> deleteAll() {
    return playStoreCollection.get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  @override
  dynamic getSubCollection(String documentId, String name) {
    return playStoreCollection.doc(documentId).collection(name);
  }

  @override
  String? timeStampToString(dynamic timeStamp) {
    return firestoreTimeStampToString(timeStamp);
  }

  @override
  Future<PlayStoreModel?> changeValue(
      String documentId, String fieldName, num changeByThisValue) {
    var change = FieldValue.increment(changeByThisValue);
    return playStoreCollection
        .doc(documentId)
        .update({fieldName: change}).then((v) => get(documentId));
  }

  final String appId;
  PlayStoreFirestore(this.getCollection, this.appId)
      : playStoreCollection = getCollection();

  final CollectionReference playStoreCollection;
  final GetCollection getCollection;
}
