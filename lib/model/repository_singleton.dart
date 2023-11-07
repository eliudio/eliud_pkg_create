/*
       _ _           _ 
      | (_)         | |
   ___| |_ _   _  __| |
  / _ \ | | | | |/ _` |
 |  __/ | | |_| | (_| |
  \___|_|_|\__,_|\__,_|
                       
 
 model/repository_singleton.dart
                       
 This code is generated. This is read only. Don't touch!

*/

import 'abstract_repository_singleton.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import 'dart:collection';
import '../model/play_store_firestore.dart';
import '../model/play_store_repository.dart';
import '../model/play_store_cache.dart';

class RepositorySingleton extends AbstractRepositorySingleton {
  final _playStoreRepository = HashMap<String, PlayStoreRepository>();

  @override
  PlayStoreRepository? playStoreRepository(String? appId) {
    if ((appId != null) && (_playStoreRepository[appId] == null)) {
      _playStoreRepository[appId] = PlayStoreCache(PlayStoreFirestore(
          () => appRepository()!.getSubCollection(appId, 'playstore'), appId));
    }
    return _playStoreRepository[appId];
  }
}
