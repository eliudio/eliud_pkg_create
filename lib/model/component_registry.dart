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
import 'package:eliud_core/tools/component/component_spec.dart';
import 'abstract_repository_singleton.dart';

import '../extensions/play_store_component.dart';
import '../editors/play_store_component_editor.dart';
import 'play_store_component_selector.dart';




class ComponentRegistry {

  void init() {
    Registry.registry()!.addInternalComponents('eliud_pkg_create', ["playStores", ]);

    Registry.registry()!.register(componentName: "eliud_pkg_create_internalWidgets", componentConstructor: ListComponentFactory());
    Registry.registry()!.addDropDownSupporter("playStores", DropdownButtonComponentFactory());
    Registry.registry()!.register(componentName: "playStores", componentConstructor: PlayStoreComponentConstructorDefault());
    Registry.registry()!.addComponentSpec('eliud_pkg_create', 'create', [
      ComponentSpec('playStores', PlayStoreComponentConstructorDefault(), PlayStoreComponentSelector(), PlayStoreComponentEditorConstructor(), ({String? appId}) => playStoreRepository(appId: appId)! ), 
    ]);
      Registry.registry()!.registerRetrieveRepository('eliud_pkg_create', 'playStores', ({String? appId}) => playStoreRepository(appId: appId)!);

  }
}


