import 'package:eliud_core_model/model/app_model.dart';
import 'package:eliud_core_model/style/frontend/has_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
