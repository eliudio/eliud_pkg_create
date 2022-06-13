import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/package/medium_api.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_core/tools/storage/basename_helper.dart';
import 'package:eliud_core/tools/storage/upload_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'create_platform.dart';
import 'dart:html' as html;

class WebCreatePlatform extends AbstractCreatePlatform {
  @override
  Widget openJsonAsLink(BuildContext context, AppModel app, String jsonString) {
    var blob = html.Blob([jsonString], 'text/plain', 'native');
    return button(app, context, label: "Open file", onPressed: () {
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.window.open(url, "_blank");
        html.Url.revokeObjectUrl(url);
      });
  }
}
