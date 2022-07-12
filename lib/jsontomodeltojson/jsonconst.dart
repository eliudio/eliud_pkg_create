import 'package:eliud_core/core/base/model_base.dart';
import 'package:eliud_core/core/base/repository_base.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_pkg_create/widgets/utils/models_json_bloc/models_json_bloc.dart';
import 'package:eliud_pkg_create/widgets/utils/models_json_bloc/models_json_event.dart';
import 'package:eliud_core/model/app_model.dart';

import '../widgets/bodycomponents/bodycomponents__bloc/bodycomponents_create_state.dart';

class JsonConsts {
  static String app = 'app';
  static String appBar = 'appBar';
  static String homeMenu = 'homeMenu';
  static String leftDrawerX = 'leftDrawer';
  static String rightDrawer = 'rightDrawer';
  static String dialogs = 'dialogs';
  static String pages = 'pages';
  static String menuDef = 'menuDef';
}