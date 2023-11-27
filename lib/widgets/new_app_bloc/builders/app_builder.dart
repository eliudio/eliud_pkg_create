import 'package:eliud_core_main/apis/wizard_api/action_specification.dart';
import 'package:eliud_core_main/apis/wizard_api/new_app_wizard_info.dart';
import 'package:eliud_core_main/model/app_home_page_references_model.dart';
import 'package:eliud_core_main/tools/main_abstract_repository_singleton.dart';
import 'package:eliud_core_main/wizards/tools/document_identifier.dart';
import 'package:eliud_core_main/model/app_bar_model.dart';
import 'package:eliud_core_main/model/drawer_model.dart';
import 'package:eliud_core_main/model/home_menu_model.dart';
import 'package:eliud_core_main/model/member_medium_model.dart';
import 'package:eliud_core_main/apis/medium/access_rights.dart';
import 'package:eliud_core_helpers/etc/random.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/page/hello_world_page_builder.dart';
import 'package:eliud_pkg_create/widgets/utils/random_logo.dart';
import 'package:eliud_core_main/model/public_medium_model.dart';
import 'package:eliud_core/tools/helpers/progress_manager.dart';
import 'package:eliud_core_main/model/app_model.dart';
import 'package:eliud_core_main/model/member_model.dart';
import 'package:flutter/services.dart';
import '../../../jsontomodeltojson/jsontomodelhelper.dart';
import '../../../tools/new_app_functions.dart';
import '../../wizard_shared/menus/app_bar_builder.dart';
import '../../wizard_shared/menus/home_menu_builder.dart';
import '../../wizard_shared/menus/left_drawer_builder.dart';
import '../../wizard_shared/menus/right_drawer_builder.dart';

typedef Evaluate = bool Function(ActionSpecification actionSpecification);

abstract class AppBuilderFeedback {
  void started();
  void progress(double progress);
  bool isCancelled();
  void finished();
}

class ConsoleConsumeAppBuilderProgress extends AppBuilderFeedback {
  @override
  bool isCancelled() {
    return false;
  }

  @override
  void finished() {}

  @override
  void progress(double progress) {
    print(progress);
  }

  @override
  void started() {
    print("Creating app");
  }
}

class AppBuilder {
  final String uniqueId = newRandomKey();
  final AppModel app;
  late MemberModel member;
  late String appId;
  late String memberId;

  static String helloWorldPageId = "hello";

  AppBuilder(
    this.app,
    this.member,
  ) {
    appId = app.documentID;
    memberId = member.documentID;
  }

  DrawerModel? leftDrawer;
  DrawerModel? rightDrawer;
  HomeMenuModel? theHomeMenu;
  AppBarModel? theAppBar;

  AppModel? newlyCreatedApp;

  /*
   * if creating an app from an existing app, then specify fromExisting = true and provide
   * memberMediumModel representing that app or
   * url to the json
   */
  Future<AppModel> create(
      AppBuilderFeedback appBuilderFeedback, bool fromExisting,
      {MemberMediumModel? memberMediumModel, String? url}) async {
    List<NewAppTask> tasks = [];
    // create the app
    tasks.add(() async {
      newlyCreatedApp = await appRepository()!.add(AppModel(
        documentID: appId,
        appStatus: AppStatus.offline,
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

    List<NewAppTask> newTasks = [];
    if (fromExisting) {
      if (url != null) {
        newTasks = await createAppFromUrl(url);
      } else if (memberMediumModel != null) {
        newTasks = await createAppFromMemberMedium(memberMediumModel);
      } else {
        newTasks = await createAppFromClipboard();
      }
    } else {
      newTasks = await createApp();
    }
    tasks.addAll(newTasks);

    var progressManager = ProgressManager(
        tasks.length, (progress) => appBuilderFeedback.progress(progress));

    var currentTask = tasks[0];
    currentTask().then((value) => tasks[1]);

    int i = 0;
    for (var task in tasks) {
      i++;
      try {
        await task();
      } catch (e) {
        print('Exception running task $i, error: $e');
      }
      progressManager.progressedNextStep();
      if (appBuilderFeedback.isCancelled()) {
        throw Exception("Process cancelled");
      }
    }

    if (newlyCreatedApp != null) {
      appBuilderFeedback.finished();
      return newlyCreatedApp!;
    } else {
      throw Exception("no app created");
    }
  }

  Future<List<NewAppTask>> createAppFromClipboard() async {
    var json = await Clipboard.getData(Clipboard.kTextPlain);
    if (json != null) {
      var jsonText = json.text;
      if (jsonText != null) {
        return JsonToModelsHelper.createAppFromJson(app, memberId, jsonText);
      } else {
        throw Exception("Json text is null");
      }
    } else {
      throw Exception("json is null");
    }
  }

  Future<List<NewAppTask>> createAppFromMemberMedium(
      MemberMediumModel memberMediumModel) async {
    return JsonToModelsHelper.createAppFromMemberMedium(
        app, memberId, memberMediumModel);
  }

  Future<List<NewAppTask>> createAppFromUrl(String url) async {
    return JsonToModelsHelper.createAppFromURL(app, memberId, url);
  }

  Future<List<NewAppTask>> createApp() async {
    List<NewAppTask> tasks = [];

    PublicMediumModel? logo;
    tasks.add(() async {
      print("Logo");
      try {
        logo = await RandomLogo.getRandomPhoto(app, memberId, null);
      } catch (_) {}
    });

    PublicMediumModel? anonymousMedium;
    tasks.add(() async {
      print("Anonymous photo");
      try {
        anonymousMedium = await PublicMediumAccessRights()
            .getMediumHelper(
              app,
              memberId,
            )
            .createThumbnailUploadPhotoAsset(newRandomKey(),
                'packages/eliud_pkg_create/assets/rodentia-icons_preferences-desktop-personal.png');
      } catch (_) {}
    });

    tasks.add(() async {
      print("leftDrawer");
      leftDrawer = await LeftDrawerBuilder(app, logo: logo).getOrCreate();
    });

    tasks.add(() async {
      print("rightDrawer");
      rightDrawer = await RightDrawerBuilder(
        app,
      ).getOrCreate();
    });

    tasks.add(() async {
      print("HomeMenu");
      theHomeMenu = await HomeMenuBuilder(
        app,
      ).getOrCreate();
    });

    tasks.add(() async {
      print("AppBar");
      theAppBar = await AppBarBuilder(
        app,
      ).getOrCreate();
    });

    tasks.add(() async {
      print("Welcome Page");
      if ((theHomeMenu != null) &&
          (theAppBar != null) &&
          (leftDrawer != null) &&
          (rightDrawer != null)) {
        await HelloWorldPageBuilder(
          uniqueId,
          helloWorldPageId,
          app,
          memberId,
          theHomeMenu!,
          theAppBar!,
          leftDrawer!,
          rightDrawer!,
        ).create();
      }
    });

    // app
    tasks.add(() async {
      print("App");
      var newApp = AppModel(
        documentID: appId,
        title: 'New application',
        ownerID: memberId,
        appStatus: AppStatus.live,
        email: member.email,
        logo: logo,
        anonymousProfilePhoto: anonymousMedium,
        homePages: AppHomePageReferencesModel(
          homePageBlockedMember: constructDocumentId(
              uniqueId: uniqueId, documentId: helloWorldPageId),
          homePagePublic: constructDocumentId(
              uniqueId: uniqueId, documentId: helloWorldPageId),
          homePageSubscribedMember: constructDocumentId(
              uniqueId: uniqueId, documentId: helloWorldPageId),
          homePageLevel1Member: constructDocumentId(
              uniqueId: uniqueId, documentId: helloWorldPageId),
          homePageLevel2Member: constructDocumentId(
              uniqueId: uniqueId, documentId: helloWorldPageId),
          homePageOwner: constructDocumentId(
              uniqueId: uniqueId, documentId: helloWorldPageId),
        ),
        description: 'Your new application',
      );
      /*newlyCreatedApp = */ await appRepository()!.update(newApp);
    });

    return tasks;
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
      appStatus: AppStatus.offline,
      documentID: appId,
      ownerID: ownerID,
    );
    return await AbstractMainRepositorySingleton.singleton
        .appRepository()!
        .add(application);
  }
}
