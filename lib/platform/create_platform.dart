import 'dart:collection';
import 'dart:typed_data';
import 'package:eliud_core/core/base/model_base.dart';
import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_medium_model.dart';
import 'package:eliud_core/model/platform_medium_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/package/medium_api.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/tools/etc.dart';
import 'package:eliud_core/tools/router_builders.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_core/tools/storage/upload_info.dart';
import 'package:eliud_pkg_medium/tools/view/video_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class AbstractCreatePlatform {
  static late AbstractCreatePlatform platform;

/*
  Future<Widget> storeModelAsFile(BuildContext context, AppModel app, ModelBase model) async {
    var jsonString = await getJsonString(app, model);
    return storeJsonAsFile(context, app, jsonString);
  }

*/

  Widget openJsonAsLink(BuildContext context, AppModel app, String jsonString);
/*
  Future<Widget> storeJsonAsFile(BuildContext context, AppModel app, String json);

  Future<String> getJsonString(AppModel app, ModelBase model) async {
    return await model.toRichJsonString(appId: app.documentID);
  }

*/
}
