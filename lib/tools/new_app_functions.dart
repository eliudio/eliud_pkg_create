// Start the installation by claiming ownership of the app.
// Otherwise you won't be able to add data, given security depends on the ownerId of the app being allowed to add data to app's entities
// We do this twice: the first time before wiping the data. This is to assure that we can wipe
// The second time because the wipe has deleted the entry
// This process works except when the app was create by someone else before. In which case you must delete the app through console.firebase.google.com or by logging in as the owner of the app
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/access_model.dart';
import 'package:eliud_core_model/model/app_model.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';

Future<AppModel> claimOwnerShipApplication(String appId, String ownerID) async {
  // first delete the app
  AppModel? oldApp = await appRepository()!.get(appId);
  if (oldApp != null) {
    await appRepository()!.delete(oldApp);
  }

  // add the app
  var application = AppModel(
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
      appId: appId,
      privilegeLevel: PrivilegeLevel.ownerPrivilege,
      points: 0));
}
