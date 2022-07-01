import 'dart:collection';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:eliud_core/core/base/entity_base.dart';
import 'package:eliud_core/core/base/model_base.dart';
import 'package:eliud_core/core/base/repository_base.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/tools/helpers/progress_manager.dart';
import 'models_json_event.dart';
import 'models_json_state.dart';

abstract class AbstractModelWithInformation {
  final String label;

  AbstractModelWithInformation(this.label);

  Future<dynamic> toRichMap({required String appId, required Set<ModelReference> referencedModels});
}

class ModelWithInformation extends AbstractModelWithInformation {
  final ModelBase model;

  ModelWithInformation(String label, this.model) : super(label);

  Future<Map<String, dynamic>> toRichMap({required String appId, required Set<ModelReference> referencedModels}) async {
    var entity = await model.toEntity(appId: appId, referencesCollector: referencedModels);
    var doc = entity.toDocument();
    await entity.enrichedDocument(doc);
    doc['documentID'] = model.documentID;
    return doc;
  }

}

class ModelsWithInformation extends AbstractModelWithInformation {
  final Set<ModelBase> models;

  ModelsWithInformation(String label, this.models) : super(label);

  Future<List<dynamic>> toRichMap({required String appId, required Set<ModelReference> referencedModels}) async {
    List<dynamic> list = [];
    for (var model in models) {
      var entity = await model.toEntity(appId: appId, referencesCollector: referencedModels);
      var doc = entity.toDocument();
      await entity.enrichedDocument(doc);
      doc['documentID'] = model.documentID;
      list.add(doc);
    }
    return list;
  }
}

class ModelDocumentIDsWithInformation extends AbstractModelWithInformation {
  final RepositoryBase<ModelBase, EntityBase> repository;
  final List<String> documentIDs;

  ModelDocumentIDsWithInformation(this.repository, String label, this.documentIDs) : super(label);

  Future<List<dynamic>> toRichMap({required String appId, required Set<ModelReference> referencedModels}) async {
    List<dynamic> list = [];
    for (var documentID in documentIDs) {
      var model = await repository.get(documentID);
      if (model != null) {
        var entity = await model.toEntity(appId: appId, referencesCollector: referencedModels);
        var doc = entity.toDocument();
        await entity.enrichedDocument(doc);
        doc['documentID'] = model.documentID;
        list.add(doc);
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
        var jsonString = await modelsToJson(progressManager, app, event.dataContainer);
        emit(ModelsAndJsonAvailable(event.dataContainer, jsonString, ));
      }
    });

    on<ModelsJsonProgressedEvent>((event, emit) async {
      emit(ModelsJsonProgressed(event.progress, event.dataContainer, ));
    });
  }

  Future<Map<String, dynamic>> modelsToRichMap(ProgressManager progressManager, AppModel app, List<AbstractModelWithInformation> modelsWithInformation, ) async {
    Set<ModelReference> referencedModels = LinkedHashSet<ModelReference>();
    var appId = app.documentID;
    final Map<String, dynamic> theMap = {};
    for (var modelWithInformation in modelsWithInformation) {
      theMap[modelWithInformation.label] = await modelWithInformation.toRichMap(appId: appId, referencedModels: referencedModels);
    }

    //    progressManager.addAmountOfSteps(size);
    Set<String> referencedModels2 = Set<String>();
    referencedModels.retainWhere((element) => referencedModels2.add(element.key()));
    int size = referencedModels.length;
    for (var referencedModel in referencedModels ) {
      var fullName = referencedModel.packageName + "-" + referencedModel.componentName;
      var map = theMap[fullName];
      if (map == null) {
        theMap[fullName] = [];
      }
      var entity = referencedModel.referenced.toEntity(appId: appId);
      var doc = entity.toDocument();
      doc['documentID'] = referencedModel.referenced.documentID;
      await entity.enrichedDocument(doc);
      theMap[fullName].add(doc);
//      progressManager.progressedNextStep();
    }

    return theMap;
  }

  Future<String> modelsToJson(ProgressManager progressManager, AppModel app, List<AbstractModelWithInformation> modelsWithInformation) async {
    return jsonEncode(await modelsToRichMap(progressManager, app, modelsWithInformation));
  }
}
