/*
       _ _           _ 
      | (_)         | |
   ___| |_ _   _  __| |
  / _ \ | | | | |/ _` |
 |  __/ | | |_| | (_| |
  \___|_|_|\__,_|\__,_|
                       
 
 model/abstract_repository_singleton.dart
                       
 This code is generated. This is read only. Don't touch!

*/

import '../model/play_store_repository.dart';
import 'package:eliud_core/package/package.dart';

PlayStoreRepository? playStoreRepository({ String? appId }) => AbstractRepositorySingleton.singleton.playStoreRepository(appId);

abstract class AbstractRepositorySingleton {
  static List<MemberCollectionInfo> collections = [
  ];
  static late AbstractRepositorySingleton singleton;

  PlayStoreRepository? playStoreRepository(String? appId);

  void flush(String? appId) {
    playStoreRepository(appId)!.flush();
  }
}
