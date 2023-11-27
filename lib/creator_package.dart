import 'package:eliud_core/access/access_bloc.dart';
import 'package:eliud_core_main/apis/apis.dart';
import 'package:eliud_core_main/apis/wizard_api/new_app_wizard_info.dart';
import 'package:eliud_core/core_package.dart';
import 'package:eliud_core/eliud.dart';
import 'package:eliud_core_main/tools/etc/member_collection_info.dart';
import 'package:eliud_core_model/model/access_model.dart';
import 'package:eliud_core_main/model/app_model.dart';
import 'package:eliud_core_main/model/member_model.dart';
import 'package:eliud_core/package/package.dart';
import 'package:eliud_pkg_create/editors/play_store_component_editor.dart';
import 'package:eliud_pkg_create/extensions/play_store_component.dart';
import 'package:eliud_pkg_create/widgets/select/select_action_widget.dart';
import 'package:eliud_pkg_create/wizards/logo_wizard.dart';
import 'package:eliud_pkg_create_model/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_create_model/model/component_registry.dart';
import 'package:eliud_pkg_create_model/model/repository_singleton.dart';
import 'package:eliud_pkg_etc/etc_package.dart';
import 'package:eliud_pkg_medium/medium_package.dart';
import 'package:eliud_pkg_text/text_package.dart';
import 'package:eliud_pkg_workflow/workflow_package.dart';

import 'creator_package_stub.dart'
    if (dart.library.io) 'creator_mobile_package.dart'
    if (dart.library.html) 'creator_web_package.dart';

abstract class CreatorPackage extends Package {
  CreatorPackage() : super('eliud_pkg_create');

  @override
  Future<List<PackageConditionDetails>>? getAndSubscribe(
          AccessBloc accessBloc,
          AppModel app,
          MemberModel? member,
          bool isOwner,
          bool? isBlocked,
          PrivilegeLevel? privilegeLevel) =>
      null;

  @override
  List<String>? retrieveAllPackageConditions() => null;

  @override
  void init() {
    ComponentRegistry().init(
      PlayStoreComponentConstructorDefault(),
      PlayStoreComponentEditorConstructor(),
    );

    NewAppWizardRegistry.registry().register(LogoWizard());

    Apis.apis()
        .getRegistryApi()
        .registerOpenSelectActionWidgetFnct(openSelectActionWidget);

    AbstractRepositorySingleton.singleton = RepositorySingleton();
  }

  @override
  List<MemberCollectionInfo> getMemberCollectionInfo() =>
      AbstractRepositorySingleton.collections;

  static CreatorPackage instance() => getCreatorPackage();

  /*
   * Register depending packages
   */
  @override
  void registerDependencies(Eliud eliud) {
    eliud.registerPackage(CorePackage.instance());
    eliud.registerPackage(MediumPackage.instance());
    eliud.registerPackage(WorkflowPackage.instance());
    eliud.registerPackage(TextPackage.instance());
    eliud.registerPackage(EtcPackage.instance());
  }
}
