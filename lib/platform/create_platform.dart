import 'package:eliud_core/model/app_model.dart';
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
