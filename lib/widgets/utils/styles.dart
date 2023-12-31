import 'package:eliud_core_main/model/app_model.dart';
import 'package:eliud_core_main/apis/style/frontend/has_style.dart';
import 'package:flutter/material.dart';

InputDecoration inputDecoration(
        AppModel app, BuildContext context, String label) =>
    InputDecoration(
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
      hintText: label,
      labelText: label,
      labelStyle: styleText(app, context),
    );
