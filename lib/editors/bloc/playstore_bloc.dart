import 'package:eliud_core/model/storage_conditions_model.dart';
import 'package:eliud_core/tools/component/component_spec.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_core/core/editor/editor_base_bloc/editor_base_bloc.dart';
import 'package:eliud_pkg_create/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_create/model/play_store_model.dart';

class PlayStoreBloc extends EditorBaseBloc<PlayStoreModel> {
  PlayStoreBloc(String appId, EditorFeedback feedback)
      : super(appId, playStoreRepository(appId: appId)!, feedback);

  @override
  PlayStoreModel newInstance(StorageConditionsModel conditions) {
    return PlayStoreModel(
        appId: appId,
        documentID: newRandomKey(),
        conditions: conditions,
        description: 'new play store');
  }

  @override
  PlayStoreModel setDefaultValues(
      PlayStoreModel t, StorageConditionsModel conditions) {
    return t.copyWith(conditions: t.conditions ?? conditions);
  }
}
