import 'package:eliud_core/model/abstract_repository_singleton.dart'
    as corerepo;
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/model_export.dart';
import 'package:eliud_pkg_chat/chat_package.dart';
import 'package:eliud_pkg_chat/model/chat_dashboard_component.dart';
import 'package:eliud_pkg_chat/model/chat_dashboard_model.dart';
import 'package:eliud_pkg_chat/model/abstract_repository_singleton.dart';

import 'dialog_builder.dart';

class ChatDialogBuilder extends DialogBuilder {
  final String identifierMemberHasUnreadChat;
  final String identifierMemberAllHaveBeenRead;

  ChatDialogBuilder(String appId, {required this.identifierMemberHasUnreadChat, required this.identifierMemberAllHaveBeenRead}) : super(appId, 'NA');

  // Security is setup to indicate if a page or dialog is accessible
  // For this reason we need 2 dialogs, one for unread and one for read chats

  static String CHAT_ID = "chat";

  Future<DialogModel> _setupDialog(
      String identifier, String packageCondition) async {
    return await corerepo.AbstractRepositorySingleton.singleton
        .dialogRepository(appId)!
        .add(_dialog(identifier, packageCondition));
  }

  DialogModel _dialog(String identifier, String packageCondition) {
    List<BodyComponentModel> components = [];
    components.add(BodyComponentModel(
        documentID: "1",
        componentName: AbstractChatDashboardComponent.componentName,
        componentId: CHAT_ID));

    return DialogModel(
        documentID: identifier,
        appId: appId,
        title: "Chat",
        layout: DialogLayout.ListView,
        conditions: ConditionsModel(
            privilegeLevelRequired: PrivilegeLevelRequired.NoPrivilegeRequired,
            packageCondition: packageCondition),
        bodyComponents: components);
  }

  ChatDashboardModel _chatModel() {
    return ChatDashboardModel(
      documentID: CHAT_ID,
      appId: appId,
      description: "Chat",
      conditions: ConditionsSimpleModel(
          privilegeLevelRequired:
              PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple),
    );
  }

  Future<ChatDashboardModel> _setupChat() async {
    return await AbstractRepositorySingleton.singleton
        .chatDashboardRepository(appId)!
        .add(_chatModel());
  }

  Future<void> create() async {
    await _setupChat();
    await _setupDialog(identifierMemberHasUnreadChat,
        ChatPackage.CONDITION_MEMBER_HAS_UNREAD_CHAT);
    await _setupDialog(identifierMemberAllHaveBeenRead,
        ChatPackage.CONDITION_MEMBER_ALL_HAVE_BEEN_READ);
  }
}
