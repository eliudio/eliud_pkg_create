/*
       _ _           _ 
      | (_)         | |
   ___| |_ _   _  __| |
  / _ \ | | | | |/ _` |
 |  __/ | | |_| | (_| |
  \___|_|_|\__,_|\__,_|
                       
 
 model/component_registry.dart
                       
 This code is generated. This is read only. Don't touch!

*/

import '../model/internal_component.dart';
import 'package:eliud_core/core/registry.dart';
import 'package:eliud_core_model/tools/component/component_spec.dart';
import 'abstract_repository_singleton.dart';

import '../extensions/play_store_component.dart';
import '../editors/play_store_component_editor.dart';
import 'play_store_component_selector.dart';

/* 
 * Component registry contains a list of components
 */
class ComponentRegistry {
  /* 
   * Initialise the component registry
   */
  void init() {
    Apis.apis().addInternalComponents('eliud_pkg_create', [
      "playStores",
    ]);

    Apis.apis().register(
        componentName: "eliud_pkg_create_internalWidgets",
        componentConstructor: ListComponentFactory());
    Apis.apis()
        .addDropDownSupporter("playStores", DropdownButtonComponentFactory());
    Apis.apis().register(
        componentName: "playStores",
        componentConstructor: PlayStoreComponentConstructorDefault());
    Apis.apis().addComponentSpec('eliud_pkg_create', 'create', [
      ComponentSpec(
          'playStores',
          PlayStoreComponentConstructorDefault(),
          PlayStoreComponentSelector(),
          PlayStoreComponentEditorConstructor(),
          ({String? appId}) => playStoreRepository(appId: appId)!),
    ]);
    Apis.apis().registerRetrieveRepository('eliud_pkg_create',
        'playStores', ({String? appId}) => playStoreRepository(appId: appId)!);
  }
}
