import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/wizards/registry/registry.dart';
import 'package:eliud_core/core_package.dart';
import 'package:eliud_core/eliud.dart';
import 'package:eliud_core/model/access_model.dart';
import 'package:eliud_core_model/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/package/package.dart';
import 'package:eliud_pkg_create/widgets/select/select_action_widget.dart';
import 'package:eliud_pkg_create/wizards/logo_wizard.dart';
import 'package:eliud_pkg_etc/etc_package.dart';
import 'package:eliud_pkg_medium/medium_package.dart';
import 'package:eliud_pkg_text/text_package.dart';
import 'package:eliud_pkg_workflow/workflow_package.dart';
import 'model/abstract_repository_singleton.dart';
import 'model/component_registry.dart';
import 'model/repository_singleton.dart';
import 'package:eliud_core/core/registry.dart';

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
    ComponentRegistry().init();

    NewAppWizardRegistry.registry().register(LogoWizard());

    Apis.apis()
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
