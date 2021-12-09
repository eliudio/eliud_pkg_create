import 'package:eliud_core/model/model_export.dart';
import 'package:eliud_pkg_feed/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_feed/model/feed_model.dart';
import 'package:eliud_pkg_feed/model/header_model.dart';

class HeaderComponent {
  final String appId;

  HeaderComponent(this.appId);

  HeaderModel headerModel({required FeedModel feed, required String headerComponentIdentifier}) {
    return HeaderModel(
      documentID: headerComponentIdentifier,
      feed: feed,
      appId: appId,
      description: "Header",
      conditions: StorageConditionsModel(
          privilegeLevelRequired: PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple
      ),
    );
  }

  Future<HeaderModel> createHeaderModel({required FeedModel feed, required String headerComponentIdentifier}) async {
    return await AbstractRepositorySingleton.singleton
        .headerRepository(appId)!
        .add(headerModel(feed: feed, headerComponentIdentifier: headerComponentIdentifier));
  }

  Future<void> run({required FeedModel feed, required String headerComponentIdentifier}) async {
    await createHeaderModel(feed: feed, headerComponentIdentifier: headerComponentIdentifier);
  }
}
