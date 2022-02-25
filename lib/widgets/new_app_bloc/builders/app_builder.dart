import 'package:eliud_core/core/wizards/registry/action_specification.dart';
import 'package:eliud_core/core/wizards/registry/registry.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/access_model.dart';
import 'package:eliud_core/tools/action/action_model.dart';
import 'package:eliud_pkg_create/widgets/utils/random_logo.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/tools/helpers/progress_manager.dart';
import 'package:eliud_pkg_medium/platform/medium_platform.dart';
import 'package:eliud_core/model/app_home_page_references_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/style/_default/default_style_family.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';

import '../new_app_bloc.dart';
import '../new_app_event.dart';
import '../new_app_state.dart';
import '../../wizard_shared/helpers/menu_helpers.dart';
import '../../wizard_shared/menus/app_bar_builder.dart';
import '../../wizard_shared/menus/home_menu_builder.dart';
import '../../wizard_shared/menus/left_drawer_builder.dart';
import '../../wizard_shared/menus/right_drawer_builder.dart';

typedef Evaluate = bool Function(ActionSpecification actionSpecification);


class AppBuilder {
  final AppModel app;
  final MemberModel member;
  late String appId;
  late String memberId;

  AppBuilder(
    this.app,
    this.member, ) {
    appId = app.documentID!;
    memberId = member.documentID!;
  }

  var leftDrawer;
  var rightDrawer;
  late HomeMenuModel theHomeMenu;
  var theAppBar;

  var newlyCreatedApp;

  Future<AppModel> create(NewAppCreateBloc newAppCreateBloc) async {
    List<NewAppTask> tasks = [];

    // create the app
    tasks.add(() async {
      newlyCreatedApp = await appRepository()!.add(AppModel(
        documentID: appId,
        appStatus: AppStatus.Offline,
        title: 'New application',
        ownerID: memberId,
      ));
    });

    tasks.add(() async {
      print("claimAccess");
      await claimAccess(appId, memberId);
    });
    tasks.add(() async {
      print("claimOwnerShipApplication");
      claimOwnerShipApplication(appId, memberId);
    });

    // check if no errors, e.g. identifier should not exist
    tasks.add(() async {
      print("leftDrawer");
      leftDrawer = await LeftDrawerBuilder(app, )
          .getOrCreate();
    });

    tasks.add(() async {
      print("rightDrawer");
      rightDrawer = await RightDrawerBuilder(app,
               )
          .getOrCreate();
    });

    tasks.add(() async {
      print("HomeMenu");
      theHomeMenu = await HomeMenuBuilder(app,
               )
          .getOrCreate();
    });

    tasks.add(() async {
      print("AppBar");
      theAppBar = await AppBarBuilder(app,
               )
          .getOrCreate();
    });


    // app
    tasks.add(() async {
      print("App");
      var newApp = AppModel(
          documentID: appId,
          title: 'New application',
          ownerID: memberId,
          appStatus: AppStatus.Live,
          email: member.email,
          description: 'Your new application',
          autoPrivileged1: app.autoPrivileged1,
      );
      newlyCreatedApp = await appRepository()!.update(newApp);
    });

    var progressManager = ProgressManager(tasks.length,
        (progress) => newAppCreateBloc.add(NewAppCreateProgressed(progress)));

    var currentTask = tasks[0];
    currentTask().then((value) => tasks[1]);

    int i = 0;
    for (var task in tasks) {
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
      if (newAppCreateBloc.state is NewAppCreateCreateCancelled)
        throw Exception("Process cancelled");
    }

    if (newlyCreatedApp != null) {
      newAppCreateBloc.add(NewAppSwitchAppEvent());
      return newlyCreatedApp;
    } else {
      throw Exception("no app created");
    }
  }

  // Start the installation by claiming ownership of the app.
  // Otherwise you won't be able to add data, given security depends on the ownerId of the app being allowed to add data to app's entities
  // We do this twice: the first time before wiping the data. This is to assure that we can wipe
  // The second time because the wipe has deleted the entry
  // This process works except when the app was create by someone else before. In which case you must delete the app through console.firebase.google.com or by logging in as the owner of the app
  Future<AppModel> claimOwnerShipApplication(
      String appId, String ownerID) async {
    // add the app
    var application = AppModel(
      appStatus: AppStatus.Offline,
      documentID: appId,
      ownerID: ownerID,
    );
    return await AbstractMainRepositorySingleton.singleton
        .appRepository()!
        .add(application);
  }

  Future<AccessModel> claimAccess(String appId, String ownerID) async {
    return await accessRepository(appId: appId)!.add(AccessModel(
        documentID: ownerID,
        privilegeLevel: PrivilegeLevel.OwnerPrivilege,
        points: 0));
  }
}
