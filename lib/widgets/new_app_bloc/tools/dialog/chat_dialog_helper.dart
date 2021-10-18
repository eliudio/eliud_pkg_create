import 'package:eliud_core/model/abstract_repository_singleton.dart'
    as corerepo;
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/model_export.dart';
import 'package:eliud_pkg_chat/chat_package.dart';
import 'package:eliud_pkg_chat/model/chat_dashboard_component.dart';
import 'package:eliud_pkg_chat/model/chat_dashboard_model.dart';
import 'package:eliud_pkg_chat/model/abstract_repository_singleton.dart';

import 'dialog_helper.dart';

class ChatDialogs {
  final DialogModel chatUnread;
  final DialogModel chatReadAndUnread;

  ChatDialogs({required this.chatUnread, required this.chatReadAndUnread});
}

class ChatDialogHelper extends DialogHelper {
  ChatDialogHelper(AppModel newApp) : super(newApp);

  // Security is setup to indicate if a page or dialog is accessible
  // For this reason we need 2 dialogs, one for unread and one for read chats
  static String IDENTIFIER_READ = "chat_dialog_read";
  static String IDENTIFIER_UNREAD = "chat_dialog_unread";

  static String CHAT_ID = "chat";

  Future<DialogModel> _setupDialog(
      String identifier, String packageCondition) async {
    return await corerepo.AbstractRepositorySingleton.singleton
        .dialogRepository(newApp.documentID)!
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
        appId: newApp.documentID,
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
      appId: newApp.documentID,
      description: "Chat",
      conditions: ConditionsSimpleModel(
          privilegeLevelRequired:
              PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple),
    );
  }

  Future<ChatDashboardModel> _setupChat() async {
    return await AbstractRepositorySingleton.singleton
        .chatDashboardRepository(newApp.documentID)!
        .add(_chatModel());
  }

  Future<ChatDialogs> create() async {
    await _setupChat();
    var dialogModel1 = await _setupDialog(IDENTIFIER_READ,
        ChatPackage.CONDITION_MEMBER_DOES_NOT_HAVE_UNREAD_CHAT);
    var dialogModel2 = await _setupDialog(
        IDENTIFIER_UNREAD, ChatPackage.CONDITION_MEMBER_HAS_UNREAD_CHAT);
    return ChatDialogs(chatUnread: dialogModel1, chatReadAndUnread: dialogModel2);
  }
}
