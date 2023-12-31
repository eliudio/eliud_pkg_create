import 'package:eliud_core/access/access_bloc.dart';
import 'package:eliud_core_main/model/app_model.dart';
import 'package:eliud_core_main/model/member_model.dart';
import 'package:eliud_core_main/tools/main_abstract_repository_singleton.dart';

import '../widgets/new_app_bloc/builders/app_builder.dart';

class BasicApp {
  // create the app if it doesn't exist
  static Future<void> checkApp(String appId) async {
    appId = appId.toUpperCase();
    var app = await appRepository()!.get(appId);
    if (app == null) {
      await AbstractMainRepositorySingleton.singleton
          .userRepository()!
          .signOut();
      await AbstractMainRepositorySingleton.singleton
          .userRepository()!
          .signOut();
      var usr = await AbstractMainRepositorySingleton.singleton
          .userRepository()!
          .signInWithGoogle();
      if (usr == null) {
        throw Exception("User is null");
      }
//    await claimOwnerShipApplication(theApp.documentID, usr.uid);

      MemberModel member = await AccessBloc.firebaseToMemberModel(usr);
      await AppBuilder(
              AppModel(documentID: appId, ownerID: member.documentID), member)
          .create(ConsoleConsumeAppBuilderProgress(), false);
    }
  }
}
