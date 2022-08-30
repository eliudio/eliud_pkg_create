import 'package:bloc/bloc.dart';
import 'package:eliud_core/core/wizards/registry/registry.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/model/storage_conditions_model.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_core/tools/helpers/progress_manager.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../jsontomodeltojson/jsontomodelhelper.dart';
import 'from_json_event.dart';
import 'from_json_state.dart';

class FromJsonBloc extends Bloc<FromJsonEvent, FromJsonState> {
  final AppModel app;
  final MemberModel member;
  String? createdDocumentKey;
  String? createdDocumentId;

  FromJsonBloc(
    this.app, this.member
  ) : super(FromJsonUninitialised()) {
    on<FromJsonInitialise>((event, emit) async {
      emit(FromJsonInitialised());
    });

    on<NewFromJsonWithUrl>((event, emit) async {
      runTasks(await JsonToModelsHelper.createOtherFromURL(app, member.documentID, event.url, event.includeMedia, feedback: feedback), event.postCreationAction);
    });

    on<NewFromJsonWithModel>((event, emit) async {
      runTasks(await JsonToModelsHelper.createOtherFromMemberMedium(app, member.documentID, event.memberMediumModel, event.includeMedia, feedback: feedback), event.postCreationAction);
    });

    on<NewFromJsonWithClipboard>((event, emit) async {
      var json = await Clipboard.getData(Clipboard.kTextPlain);
      if (json != null) {
        var jsonText = json.text;
        if (jsonText != null) {
          runTasks(await JsonToModelsHelper.createOtherFromJson(app, member.documentID, jsonText, event.includeMedia, feedback: feedback), event.postCreationAction);
        } else {
          throw Exception("Json text is null");
        }
      } else {
        throw Exception("json is null");
      }
    });

    on<NewFromJsonCancelAction>((event, emit) async {
      emit(FromJsonActionCancelled());
    });

  }

  void feedback(String key, String documentId) {
    createdDocumentKey = key;
    createdDocumentId = documentId;
  }

  void reportProgress(double progress) {
    emit(FromJsonProgress(progress));
  }

  Future<void> runTasks(List<NewAppTask> tasks, PostCreationAction postCreationAction) async {
    emit(FromJsonProgress(0));
    createdDocumentKey = null;
    createdDocumentId = null;
    var progressManager = ProgressManager(tasks.length, reportProgress);

    int i = 0;
    for (var task in tasks) {
      if (state is FromJsonActionCancelled) break;
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
    postCreationAction(createdDocumentKey, createdDocumentId);
  }
}
