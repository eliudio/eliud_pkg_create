import 'package:eliud_core/model/model_export.dart';
import 'package:eliud_pkg_feed/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_feed/model/feed_model.dart';
import 'package:eliud_pkg_feed/model/profile_model.dart';

class ProfileComponent {
  final String appId;

  ProfileComponent(this.appId);

  ProfileModel profileModel({required FeedModel feed, required  profileComponentId}) {
    return ProfileModel(
      documentID: profileComponentId,
      appId: appId,
      feed: feed,
      description: "Profile",
      conditions: StorageConditionsModel(
          privilegeLevelRequired: PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple
      ),
    );
  }

  Future<ProfileModel> createProfileModel({required FeedModel feed, required  profileComponentId}) async {
    return await AbstractRepositorySingleton.singleton
        .profileRepository(appId)!
        .add(profileModel(feed: feed, profileComponentId: profileComponentId));
  }

  Future<void> run({required FeedModel feed, required  profileComponentId}) async {
    await createProfileModel(feed: feed, profileComponentId: profileComponentId);
  }
}
