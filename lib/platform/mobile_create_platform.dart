import 'dart:io';
import 'package:eliud_core_model/model/app_model.dart';
import 'package:eliud_core_model/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core_model/style/frontend/has_text.dart';
import 'package:eliud_pkg_create/platform/create_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class MobileCreatePlatform extends AbstractCreatePlatform {
  @override
  Widget openJsonAsLink(BuildContext context, AppModel app, String jsonString) {
    return FutureBuilder<String>(
        future: getFile(jsonString),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return text(app, context, snapshot.data!);
          }
          return progressIndicator(app, context);
        });
  }

  Future<String> getFile(String jsonString) async {
    var applicationDirectory = await getApplicationDocumentsDirectory();
    final String location = '${applicationDirectory.path}/my_app.json';
    final File file = File(location);
    await file.writeAsString(jsonString);
    return location;
  }
}
