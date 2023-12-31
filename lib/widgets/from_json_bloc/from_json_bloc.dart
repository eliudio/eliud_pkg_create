import 'package:bloc/bloc.dart';
import 'package:eliud_core_main/apis/wizard_api/new_app_wizard_info.dart';
import 'package:eliud_core_main/model/app_model.dart';
import 'package:eliud_core_main/model/member_model.dart';
import 'package:eliud_core/tools/helpers/progress_manager.dart';
import 'package:flutter/services.dart';
import '../../jsontomodeltojson/jsontomodelhelper.dart';
import 'from_json_event.dart';
import 'from_json_state.dart';

class FromJsonBloc extends Bloc<FromJsonEvent, FromJsonState> {
  final AppModel app;
  final MemberModel member;
  String? createdDocumentKey;
  String? createdDocumentId;

  FromJsonBloc(this.app, this.member) : super(FromJsonUninitialised()) {
    on<FromJsonInitialise>((event, emit) async {
      emit(FromJsonInitialised());
    });

    on<NewFromJsonWithUrl>((event, emit) async {
      runTasks(
          await JsonToModelsHelper.createOtherFromURL(
              app, member.documentID, event.url, event.includeMedia,
              feedback: feedback),
          event.postCreationAction);
    });

    on<NewFromJsonWithModel>((event, emit) async {
      runTasks(
          await JsonToModelsHelper.createOtherFromMemberMedium(app,
              member.documentID, event.memberMediumModel, event.includeMedia,
              feedback: feedback),
          event.postCreationAction);
    });

    on<NewFromJsonWithClipboard>((event, emit) async {
      var json = await Clipboard.getData(Clipboard.kTextPlain);
      if (json != null) {
        var jsonText = json.text;
        if (jsonText != null) {
          runTasks(
              await JsonToModelsHelper.createOtherFromJson(
                  app, member.documentID, jsonText, event.includeMedia,
                  feedback: feedback),
              event.postCreationAction);
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

    on<FromJsonProgressEvent>((event, emit) async {
      emit(FromJsonProgress(event.progress));
    });
  }

  void feedback(String key, String documentId) {
    createdDocumentKey = key;
    createdDocumentId = documentId;
  }

  void reportProgress(double progress) {
    add(FromJsonProgressEvent(progress));
  }

  Future<void> runTasks(
      List<NewAppTask> tasks, PostCreationAction postCreationAction) async {
    add(FromJsonProgressEvent(0));
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
        print('Exception running task $i, error: $e');
      }
      progressManager.progressedNextStep();
    }
    postCreationAction(createdDocumentKey, createdDocumentId);
  }
}
