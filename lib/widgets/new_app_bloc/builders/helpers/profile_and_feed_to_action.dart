import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/tools/action/action_model.dart';
import 'package:eliud_pkg_etc/model/member_action_model.dart';

class ProfileAndFeedToAction {
  static List<MemberActionModel> getMemberActionModels(AppModel app, String? profilePageId, String? feedPageId) {
    List<MemberActionModel> memberActions = [];
    if (profilePageId !=  null) {
      memberActions.add(MemberActionModel(
          documentID: '1', text: 'Profile', description: "Open member's profile", action: GotoPage(app, pageID: profilePageId)
      ));
    }
    if (feedPageId !=  null) {
      memberActions.add(MemberActionModel(
          documentID: '2', text: 'Feed', description: "Open member's feed", action: GotoPage(app, pageID: feedPageId)
      ));
    }
    return memberActions;
  }
}