import 'package:eliud_core/core/base/model_base.dart';
import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/wizards/registry/registry.dart';
import 'package:eliud_core/model/access_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/package/package.dart';
import 'package:eliud_pkg_create/widgets/select/select_action_widget.dart';
import 'package:eliud_pkg_create/wizards/logo_wizard.dart';
import 'model/abstract_repository_singleton.dart';
import 'model/component_registry.dart';
import 'model/repository_singleton.dart';
import 'package:eliud_core/core/registry.dart';

abstract class CreatorPackage extends Package {
  CreatorPackage() : super('eliud_pkg_fundamentals');

  @override
  Future<List<PackageConditionDetails>>? getAndSubscribe(AccessBloc accessBloc, AppModel app, MemberModel? member, bool isOwner, bool? isBlocked, PrivilegeLevel? privilegeLevel) => null;

  @override
  List<String>? retrieveAllPackageConditions() => null;

  @override
  void init() {
    ComponentRegistry().init();

    NewAppWizardRegistry.registry().register(LogoWizard());

    Registry.registry()!.registerOpenSelectActionWidgetFnct(openSelectActionWidget);

    AbstractRepositorySingleton.singleton = RepositorySingleton();
  }

  @override
  List<MemberCollectionInfo> getMemberCollectionInfo() => AbstractRepositorySingleton.collections;


}
