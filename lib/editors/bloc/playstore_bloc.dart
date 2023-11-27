import 'package:eliud_core_main/model/background_model.dart';
import 'package:eliud_core_main/model/storage_conditions_model.dart';
import 'package:eliud_core_main/apis/registryapi/component/component_spec.dart';
import 'package:eliud_core_helpers/etc/random.dart';
import 'package:eliud_core_main/editor/editor_base_bloc/editor_base_bloc.dart';
import 'package:eliud_pkg_create_model/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_create_model/model/play_store_entity.dart';
import 'package:eliud_pkg_create_model/model/play_store_model.dart';

class PlayStoreBloc extends EditorBaseBloc<PlayStoreModel, PlayStoreEntity> {
  PlayStoreBloc(String appId, EditorFeedback feedback)
      : super(appId, playStoreRepository(appId: appId)!, feedback);

  @override
  PlayStoreModel newInstance(StorageConditionsModel conditions) {
    return PlayStoreModel(
        appId: appId,
        documentID: newRandomKey(),
        backgroundIcon: BackgroundModel(),
        conditions: conditions,
        description: 'new play store');
  }

  @override
  PlayStoreModel setDefaultValues(
      PlayStoreModel t, StorageConditionsModel conditions) {
    return t.copyWith(
        conditions: t.conditions ?? conditions,
        backgroundIcon: t.backgroundIcon ?? BackgroundModel());
  }
}
