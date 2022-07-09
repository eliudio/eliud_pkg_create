
import 'package:eliud_core/core/blocs/access/state/access_determined.dart';
import 'package:eliud_core/core/blocs/access/state/logged_in.dart';
import 'package:eliud_core/core/wizards/registry/action_specification.dart';
import 'package:eliud_core/core/wizards/registry/registry.dart';
import 'package:eliud_core/core/wizards/tools/documentIdentifier.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/access_model.dart';
import 'package:eliud_core/model/member_medium_model.dart';
import 'package:eliud_core/package/access_rights.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/page/hello_world_page_builder.dart';
import 'package:eliud_pkg_create/widgets/utils/random_logo.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/tools/helpers/progress_manager.dart';
import 'package:eliud_core/model/app_home_page_references_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import 'package:flutter/services.dart';
import '../../../jsontomodeltojson/jsontomodelhelper.dart';
import '../new_app_bloc.dart';
import '../new_app_event.dart';
import '../new_app_state.dart';
import '../../wizard_shared/menus/app_bar_builder.dart';
import '../../wizard_shared/menus/home_menu_builder.dart';
import '../../wizard_shared/menus/left_drawer_builder.dart';
import '../../wizard_shared/menus/right_drawer_builder.dart';

typedef Evaluate = bool Function(ActionSpecification actionSpecification);

class AppBuilder {
  final String uniqueId = newRandomKey();
  final AppModel app;
  final LoggedIn loggedIn;
  late MemberModel member;
  late String appId;
  late String memberId;

  static String HELLO_WORLD_PAGE_ID = "hello";

  AppBuilder(
    this.app,
    this.loggedIn,
  ) {
    appId = app.documentID;
    member = loggedIn.member;
    memberId = member.documentID;
  }

  var leftDrawer;
  var rightDrawer;
  late HomeMenuModel theHomeMenu;
  var theAppBar;

  var newlyCreatedApp;

  Future<AppModel> create(
      NewAppCreateBloc newAppCreateBloc, bool fromExisting, MemberMediumModel? memberMediumModel, String? url) async {
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

    List<NewAppTask> newTasks = [];
    if (fromExisting) {
      // var testTasks = await createApp(newAppCreateBloc);
      if (url != null) {
        newTasks = await createAppFromUrl(url);
      } else if (memberMediumModel != null) {
        newTasks = await createAppFromMemberMedium(memberMediumModel);
      } else {
        newTasks = await createAppFromClipboard();
      }
    } else {
      newTasks = await createApp(newAppCreateBloc);
    }
    tasks.addAll(newTasks);

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

  Future<List<NewAppTask>> createAppFromMemberMedium(MemberMediumModel memberMediumModel) async {
    return JsonToModelsHelper.createAppFromMemberMedium(app, memberId, memberMediumModel);
  }

  Future<List<NewAppTask>> createAppFromUrl(String url) async {
    return JsonToModelsHelper.createAppFromURL(app, memberId, url);
  }

  Future<List<NewAppTask>> createApp(NewAppCreateBloc newAppCreateBloc) async {
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
      await HelloWorldPageBuilder(
        uniqueId,
        HELLO_WORLD_PAGE_ID,
        app,
        memberId,
        theHomeMenu,
        theAppBar,
        leftDrawer,
        rightDrawer,
      ).create();
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
        logo: logo,
        anonymousProfilePhoto: anonymousMedium,
        homePages: AppHomePageReferencesModel(
          homePageBlockedMember: constructDocumentId(
              uniqueId: uniqueId, documentId: HELLO_WORLD_PAGE_ID),
          homePagePublic: constructDocumentId(
              uniqueId: uniqueId, documentId: HELLO_WORLD_PAGE_ID),
          homePageSubscribedMember: constructDocumentId(
              uniqueId: uniqueId, documentId: HELLO_WORLD_PAGE_ID),
          homePageLevel1Member: constructDocumentId(
              uniqueId: uniqueId, documentId: HELLO_WORLD_PAGE_ID),
          homePageLevel2Member: constructDocumentId(
              uniqueId: uniqueId, documentId: HELLO_WORLD_PAGE_ID),
          homePageOwner: constructDocumentId(
              uniqueId: uniqueId, documentId: HELLO_WORLD_PAGE_ID),
        ),
        description: 'Your new application',
      );
      /*newlyCreatedApp = */await appRepository()!.update(newApp);
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
      appStatus: AppStatus.Offline,
      documentID: appId,
      ownerID: ownerID,
    );
    return await AbstractMainRepositorySingleton.singleton
        .appRepository()!
        .add(application);
  }

  Future<AccessModel> claimAccess(String appId, String ownerID) async {
    var returnMe = await accessRepository(appId: appId)!.add(AccessModel(
        appId: appId,
        documentID: ownerID,
        privilegeLevel: PrivilegeLevel.OwnerPrivilege,
        points: 0));


/*
    // temporary mechanism to refresh claims
    await loggedIn.refreshClaims();

    await AbstractMainRepositorySingleton.singleton
        .userRepository()!
        .signOut();
    await AbstractMainRepositorySingleton.singleton
        .userRepository()!
        .signInWithGoogle();
*/

    return returnMe;
  }
}
