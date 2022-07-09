import 'dart:collection';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:eliud_core/core/base/entity_base.dart';
import 'package:eliud_core/core/base/model_base.dart';
import 'package:eliud_core/core/base/repository_base.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/member_medium_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/tools/helpers/progress_manager.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_core/tools/storage/member_medium_helper.dart';
import 'package:flutter/services.dart';
import 'models_json_event.dart';
import 'models_json_state.dart';

abstract class AbstractModelWithInformation {
  final String label;

  AbstractModelWithInformation(this.label);

  Future<dynamic> toRichMap(
      {required String appId, required List<ModelReference> referencedModels});
}

class ModelWithInformation extends AbstractModelWithInformation {
  final ModelBase model;

  ModelWithInformation(String label, this.model) : super(label);

  Future<Map<String, dynamic>> toRichMap(
      {required String appId,
      required List<ModelReference> referencedModels}) async {
//    var entity = await model.toEntity(appId: appId, referencesCollector: referencedModels);
    var entity = await retrieveAndRecursivelyFindReferences(
        appId, model, referencedModels);
    var doc = entity.toDocument();
    await entity.enrichedDocument(doc);
    doc['documentID'] = model.documentID;
    return doc;
  }
}

Future<EntityBase> retrieveAndRecursivelyFindReferences(String appId,
    ModelBase model, List<ModelReference> referencedModels) async {
  List<ModelReference> newReferences = [];
  var entity =
      await model.toEntity(appId: appId, referencesCollector: newReferences);
  List<ModelReference> newReferences2 = [];
  for (var newReferencedModel in newReferences) {
    await retrieveAndRecursivelyFindReferences(
        appId, newReferencedModel.referenced, newReferences2);
  }
  referencedModels.addAll(newReferences);
  referencedModels.addAll(newReferences2);
  return entity;
}

class ModelsWithInformation extends AbstractModelWithInformation {
  final List<ModelBase> models;

  ModelsWithInformation(String label, this.models) : super(label);

  Future<List<dynamic>> toRichMap(
      {required String appId,
      required List<ModelReference> referencedModels}) async {
    List<dynamic> list = [];
    for (var model in models) {
      var entity = await retrieveAndRecursivelyFindReferences(
          appId, model, referencedModels);
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

  ModelDocumentIDsWithInformation(
      this.repository, String label, this.documentIDs)
      : super(label);

  Future<List<dynamic>> toRichMap(
      {required String appId,
      required List<ModelReference> referencedModels}) async {
    List<dynamic> list = [];
    for (var documentID in documentIDs) {
      var model = await repository.get(documentID);
      if (model != null) {
        var entity = await retrieveAndRecursivelyFindReferences(
            appId, model, referencedModels);
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

  ModelsJsonBloc(
    this.app,
  ) : super(ModelsJsonUninitialised()) {
    on<ModelsJsonInitialiseEvent>((event, emit) async {
      emit(ModelsJsonInitialised());
    });

    on<ModelsJsonConstructJsonEvent>((event, emit) async {
      emit(ModelsJsonInitialised());
      // Now run all tasks
      var tasks = await event.retrieveTasks();
      addTasks(tasks, app, event);

      var progressManager = ProgressManager(
          tasks.length, (progress) => add(ModelsJsonProgressedEvent(progress)));

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
    });

    on<ModelsJsonProgressedEvent>((event, emit) async {
      if (state is ModelsAndJsonAvailableAsMemberMedium) return;
      if (state is ModelsAndJsonAvailableInClipboard) return;
      if (state is ModelsAndJsonError) return;
      emit(ModelsJsonProgressed(
        event.progress,
        event.dataContainer,
      ));
    });
  }

  Future<void> addTasks(List<ModelsJsonTask> tasks, AppModel app,
      ModelsJsonConstructJsonEvent event) async {
    List<AbstractModelWithInformation> modelsWithInformation =
        event.dataContainer;
    List<ModelReference> referencedModels = [];
    var appId = app.documentID;
    final Map<String, dynamic> theMap = {};
    tasks.add(() async {
      for (var modelWithInformation in modelsWithInformation) {
        theMap[modelWithInformation.label] = await modelWithInformation
            .toRichMap(appId: appId, referencedModels: referencedModels);
      }
    });

    tasks.add(() async {
      Set<String> referencedModels2 = Set<String>();
      referencedModels
          .retainWhere((element) => referencedModels2.add(element.key()));
      for (var referencedModel in referencedModels) {
        var fullName =
            referencedModel.packageName + "-" + referencedModel.componentName;
        var map = theMap[fullName];
        if (map == null) {
          theMap[fullName] = [];
        }
        var entity = referencedModel.referenced
            .toEntity(appId: appId /*, referencesCollector: referencedModels*/);
        var doc = entity.toDocument();
        doc['documentID'] = referencedModel.referenced.documentID;
        await entity.enrichedDocument(doc);
        theMap[fullName].add(doc);
      }
    });

    tasks.add(() async {
      var _jsonEncoded = jsonEncode(theMap);
      if (event is ModelsJsonConstructJsonEventToClipboard) {
        try {
          await Clipboard.setData(ClipboardData(text: _jsonEncoded));
          emit(ModelsAndJsonAvailableInClipboard());
        } catch (e) {
          emit(ModelsAndJsonError(
              "Couldn't copy the json to clipboard. It's likely too large"));
        }
      } else if (event is ModelsJsonConstructJsonEventToMemberMediumModel) {
        String docID = newRandomKey();
        var memberMedium = await MemberMediumHelper(
                app, event.member.documentID, MemberMediumAccessibleByGroup.Me)
            .uploadTextData(docID, _jsonEncoded, event.baseName);
        await Clipboard.setData(ClipboardData(text: memberMedium.url));
        emit(ModelsAndJsonAvailableAsMemberMedium(memberMedium));
      }
    });
  }
}
