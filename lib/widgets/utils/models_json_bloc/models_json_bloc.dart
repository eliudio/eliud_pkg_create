import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:eliud_core/core/base/entity_base.dart';
import 'package:eliud_core/core/base/model_base.dart';
import 'package:eliud_core/core/base/repository_base.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/tools/helpers/progress_manager.dart';
import 'models_json_event.dart';
import 'models_json_state.dart';

abstract class AbstractModelWithInformation {
  final String label;

  AbstractModelWithInformation(this.label);

  Future<dynamic> toRichMap({required String appId, required List<ModelBase> referencedModels});
}

class ModelWithInformation extends AbstractModelWithInformation {
  final ModelBase model;

  ModelWithInformation(String label, this.model) : super(label);

  Future<Map<String, dynamic>> toRichMap({required String appId, required List<ModelBase> referencedModels}) async {
    return await model.toEntity(appId: appId, referencesCollector: referencedModels).toDocument();
  }

}

class ModelsWithInformation extends AbstractModelWithInformation {
  final List<ModelBase> models;

  ModelsWithInformation(String label, this.models) : super(label);

  Future<List<dynamic>> toRichMap({required String appId, required List<ModelBase> referencedModels}) async {
    List<dynamic> list = [];
    for (var model in models) {
      list.add(await model.toEntity(appId: appId, referencesCollector: referencedModels).toDocument());
    }
    return list;
  }
}

class ModelDocumentIDsWithInformation extends AbstractModelWithInformation {
  final RepositoryBase<ModelBase, EntityBase> repository;
  final List<String> documentIDs;

  ModelDocumentIDsWithInformation(this.repository, String label, this.documentIDs) : super(label);

  Future<List<dynamic>> toRichMap({required String appId, required List<ModelBase> referencedModels}) async {
    List<dynamic> list = [];
    for (var documentID in documentIDs) {
      var model = await repository.get(documentID);
      if (model != null) {
        list.add(await model.toEntity(appId: appId, referencesCollector: referencedModels).toDocument());
      } else {
        print('Model not found for documentID $documentID');
      }
    }
    return list;
  }
}

class ModelsJsonBloc extends Bloc<ModelsJsonEvent, ModelsJsonState> {
  final AppModel app;

  ModelsJsonBloc(this.app,
  ): super(ModelsJsonUninitialised()) {
    on<ModelsJsonInitialiseEvent>((event, emit) async {
      emit(ModelsJsonInitialised());
    });

    on<ModelsJsonConstructJsonEvent>((event, emit) async {
      if (state is ModelsJsonInitialised) {
        var theState = state as ModelsJsonInitialised;
        // Now run all tasks
        var tasks = await event.retrieveTasks();
        var progressManager = ProgressManager(tasks.length,
                (progress) => add(ModelsJsonProgressedEvent(progress)));

        int i = 0;
        for (var task in tasks) {
          i++;
          try {
            await task();
          } catch (e) {
            print('Exception running task ' +
                i.toString() +
                ', error: ' +
                e.toString());
          }
          progressManager.progressedNextStep();
        }
        var jsonString = await modelsToJson(app, event.dataContainer);
        emit(ModelsAndJsonAvailable(event.dataContainer, jsonString, ));
      }
    });

    on<ModelsJsonProgressedEvent>((event, emit) async {
      emit(ModelsJsonProgressed(event.progress, event.dataContainer, ));
    });
  }

  Future<Map<String, dynamic>> modelsToRichMap(AppModel app, List<AbstractModelWithInformation> modelsWithInformation, ) async {
    List<ModelBase> referencedModels = [];
    var appId = app.documentID;
    final Map<String, dynamic> theMap = {};
    for (var modelWithInformation in modelsWithInformation) {
      theMap[modelWithInformation.label] = await modelWithInformation.toRichMap(appId: appId, referencedModels: referencedModels);
    }
    int i = 0;
    i++;
    // now also add the referencedModels
    return theMap;
  }

  Future<String> modelsToJson(AppModel app,List<AbstractModelWithInformation> modelsWithInformation) async {
    return jsonEncode(await modelsToRichMap(app, modelsWithInformation));
  }
}
