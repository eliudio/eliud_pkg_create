import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/icon_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/tools/action/action_model.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:flutter/material.dart';

menuItemSignOut(AppModel app, ) => MenuItemModel(
    documentID: newRandomKey(),
    text: "Sign out",
    description: "Sign out",
    icon: IconModel(
        codePoint: Icons.power_settings_new.codePoint,
        fontFamily: Icons.settings.fontFamily),
    action:
        InternalAction(app, internalActionEnum: InternalActionEnum.Logout));

menuItemSignIn(AppModel app, ) => MenuItemModel(
    documentID: newRandomKey(),
    text: "Sign in",
    description: "Sign in",
    action:
    InternalAction(app, internalActionEnum: InternalActionEnum.Login));
