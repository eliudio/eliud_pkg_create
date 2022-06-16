import 'package:bloc/bloc.dart';
import 'package:eliud_core/core/base/model_base.dart';
import 'package:eliud_core/core/base/repository_base.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/tools/helpers/progress_manager.dart';
import 'models_json_event.dart';
import 'models_json_state.dart';

abstract class AbstractModelWithInformation {
  final String label;

  AbstractModelWithInformation(this.label);

  Future<String> toRichJsonString({required String appId});
}

class ModelWithInformation extends AbstractModelWithInformation {
  final ModelBase model;

  ModelWithInformation(String label, this.model) : super(label);

  Future<String> toRichJsonString({required String appId}) {
    return model.toRichJsonString(appId: appId);
  }
}


class ModelsWithInformation extends AbstractModelWithInformation {
  final List<ModelBase> models;

  ModelsWithInformation(String label, this.models) : super(label);

  Future<String> toRichJsonString({required String appId}) async {
    var jsonString = "[";
    int i = 0;
    int size = models.length;
    for (var model in models) {
      var modelJson = await model.toRichJsonString(appId: appId);
      jsonString = jsonString + modelJson;
      i++;
      if (i != size) {
        jsonString = jsonString + ",";
      }
    }
    jsonString = jsonString + "]";
    return jsonString;
  }
}

class ModelDocumentIDsWithInformation extends AbstractModelWithInformation {
  final RepositoryBase<ModelBase> repository;
  final List<String> documentIDs;

  ModelDocumentIDsWithInformation(this.repository, String label, this.documentIDs) : super(label);

  Future<String> toRichJsonString({required String appId}) async {
    var jsonString = "[";
    int i = 0;
    int size = documentIDs.length;
    for (var documentID in documentIDs) {
      var model = await repository.get(documentID);
      if (model != null) {
        var modelJson = await model.toRichJsonString(appId: appId);
        jsonString = jsonString + modelJson;
        i++;
        if (i != size) {
          jsonString = jsonString + ",";
        }
      } else {
        print('Model not found for documentID $documentID');
      }
    }
    jsonString = jsonString + "]";
    return jsonString;
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

  Future<String> modelsToJson(AppModel app,List<AbstractModelWithInformation> modelsWithInformation) async {
    var appId = app.documentID;
    var jsonString = "{";
    for (var modelWithInformation in modelsWithInformation) {
      var modelJson = await modelWithInformation.toRichJsonString(appId: appId );
      jsonString = jsonString + "\"" + modelWithInformation.label + "\":" + modelJson;
      if (modelsWithInformation.last != modelWithInformation) {
        jsonString = jsonString + ",";
      }
    }
    jsonString = jsonString + "}";
    return jsonString;
  }

}
