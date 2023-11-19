import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_home_page_references_model.dart';
import 'package:eliud_core_model/model/app_model.dart';
import 'package:eliud_core/model/app_policy_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core_model/model/storage_conditions_model.dart';
import 'package:eliud_core_model/style/frontend/has_drawer.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import 'package:eliud_core_model/tools/query/query_tools.dart';
import 'package:eliud_core_model/tools/etc/random.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:eliud_pkg_workflow/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_workflow/model/workflow_model.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppCreateBloc extends Bloc<AppCreateEvent, AppCreateState> {
  final AppModel appModel;
  final String appId;
  final Map<int, StreamSubscription> _pageSubscription = {};
  final Map<int, StreamSubscription> _dialogSubscription = {};
  final Map<int, StreamSubscription> _policySubscription = {};

  static EliudQuery getQuery() {
    return EliudQuery(theConditions: [
      EliudQueryCondition('conditions.privilegeLevelRequired', isEqualTo: 3),
    ]);
  }

  String comparable(String? title) => title == null ? '?' : title.toLowerCase();

  Future<List<PageModel>> _pages() async {
    var pages = <PageModel>[];
    {
      var countDown = 3;
      while (countDown >= 0) {
        try {
          var newPages = await pageRepository(appId: appId)!.valuesList(
              eliudQuery: getComponentSelectorQuery(countDown, appId));
          pages.addAll(newPages.map((e) => e!).toList());
        } catch (error) {
          print(error);
        }
        countDown--;
      }
    }
    pages.sort((a, b) => (comparable(a.title) + a.documentID)
        .compareTo((comparable(b.title) + b.documentID)));
    return pages;
  }

  void _listen() {
    var countDown = 3;
    while (countDown >= 0) {
      _pageSubscription[countDown]?.cancel();
      _pageSubscription[countDown] =
          pageRepository(appId: appId)!.listen((value) async {
        var pages = await _pages();
        if (state is AppCreateInitialised) {
          //var theState = state as AppCreateInitialised;
          add(PagesUpdated(pages));
        }
      }, privilegeLevel: countDown);

      _dialogSubscription[countDown]?.cancel();
      _dialogSubscription[countDown] =
          dialogRepository(appId: appId)!.listen((value) async {
        var dialogs = await _dialogs();
        add(DialogsUpdated(dialogs));
      }, privilegeLevel: countDown);

      _policySubscription[countDown]?.cancel();
      _policySubscription[countDown] =
          appPolicyRepository(appId: appId)!.listen((value) async {
        var policies = await _policies();
        add(PoliciesUpdated(policies));
      }, privilegeLevel: countDown);
      countDown--;
    }
  }

  void closeAll() {
    for (var ps in _pageSubscription.entries) {
      ps.value.cancel();
    }
    for (var ds in _dialogSubscription.entries) {
      ds.value.cancel();
    }
    for (var pos in _policySubscription.entries) {
      pos.value.cancel();
    }
  }

  Future<List<DialogModel>> _dialogs() async {
    var dialogs = <DialogModel>[];
    {
      var countDown = 3;
      while (countDown >= 0) {
        var newDialogs = await dialogRepository(appId: appId)!
            .valuesList(privilegeLevel: countDown);
        dialogs.addAll(newDialogs.map((d) => d!).toList());
        countDown--;
      }
    }
    dialogs.sort((a, b) => (comparable(a.title) + a.documentID)
        .compareTo((comparable(b.title) + b.documentID)));
    return dialogs;
  }

  Future<List<AppPolicyModel>> _policies() async {
    var appPolicyModels = await appPolicyRepository(appId: appId)!.valuesList();
    List<AppPolicyModel> newAppPolicyModels = [];
    for (var appPolicy in appPolicyModels) {
      if (appPolicy != null) {
        newAppPolicyModels.add(appPolicy);
      }
    }
    return newAppPolicyModels;
  }

  Future<List<WorkflowModel>> _workflows() async {
    var workflowModels = await workflowRepository(appId: appId)!.valuesList();
    List<WorkflowModel> newWorkflowModels = [];
    for (var workflow in workflowModels) {
      if (workflow != null) {
        newWorkflowModels.add(workflow);
      }
    }
    return newWorkflowModels;
  }

  AppCreateBloc(
    this.appId,
    AppModel initialiseWithApp,
  )   : appModel = deepCopy(appId, initialiseWithApp),
        super(AppCreateUninitialised()) {
    on<AppCreateEventValidateEvent>((event, emit) async {
      var pages = await _pages();
      var dialogs = await _dialogs();
      var policies = await _policies();
      var workflows = await _workflows();
      var theHomeMenu = await homeMenu(appId, store: true);
      var theAppBar = await appBar(appId);
      var leftDrawer = await getDrawer(appId, DrawerType.left, store: true);
      var rightDrawer = await getDrawer(appId, DrawerType.right, store: true);
      _listen();
      emit(AppCreateValidated(
          deepCopy(appId, event.appModel),
          pages,
          dialogs,
          workflows,
          policies,
          theHomeMenu,
          theAppBar,
          leftDrawer,
          rightDrawer));
    });

    on<AppCreateDeletePage>((event, emit) async {
      if (state is AppCreateInitialised) {
        var appCreateInitialised = state as AppCreateInitialised;
        var page = event.deleteThis;
        await pageRepository(appId: appId)!.delete(page);
        var pages = await _pages();
        emit(AppCreateValidated(
            appCreateInitialised.appModel,
            pages,
            appCreateInitialised.dialogs,
            appCreateInitialised.workflows,
            appCreateInitialised.policies,
            appCreateInitialised.homeMenuModel,
            appCreateInitialised.appBarModel,
            appCreateInitialised.leftDrawerModel,
            appCreateInitialised.rightDrawerModel));
      }
    });

    on<AppCreateDeleteDialog>((event, emit) async {
      if (state is AppCreateInitialised) {
        var appCreateInitialised = state as AppCreateInitialised;
        var dialog = event.deleteThis;
        await dialogRepository(appId: appId)!.delete(dialog);
        var dialogs = await _dialogs();
        emit(AppCreateValidated(
            appCreateInitialised.appModel,
            appCreateInitialised.pages,
            dialogs,
            appCreateInitialised.workflows,
            appCreateInitialised.policies,
            appCreateInitialised.homeMenuModel,
            appCreateInitialised.appBarModel,
            appCreateInitialised.leftDrawerModel,
            appCreateInitialised.rightDrawerModel));
      }
    });

    on<AppCreateDeleteWorkflow>((event, emit) async {
      if (state is AppCreateInitialised) {
        var appCreateInitialised = state as AppCreateInitialised;
        var workflow = event.deleteThis;
        await workflowRepository(appId: appId)!.delete(workflow);
        var workflows = await _workflows();
        emit(AppCreateValidated(
            appCreateInitialised.appModel,
            appCreateInitialised.pages,
            appCreateInitialised.dialogs,
            workflows,
            appCreateInitialised.policies,
            appCreateInitialised.homeMenuModel,
            appCreateInitialised.appBarModel,
            appCreateInitialised.leftDrawerModel,
            appCreateInitialised.rightDrawerModel));
      }
    });

    on<AppCreateDeletePolicy>((event, emit) async {
      if (state is AppCreateInitialised) {
        var appCreateInitialised = state as AppCreateInitialised;
        var policy = event.deleteThis;
        await appPolicyRepository(appId: appId)!.delete(policy);
        var policies = await _policies();
        emit(AppCreateValidated(
            appCreateInitialised.appModel,
            appCreateInitialised.pages,
            appCreateInitialised.dialogs,
            appCreateInitialised.workflows,
            policies,
            appCreateInitialised.homeMenuModel,
            appCreateInitialised.appBarModel,
            appCreateInitialised.leftDrawerModel,
            appCreateInitialised.rightDrawerModel));
      }
    });

    on<AppCreateAddPolicy>((event, emit) async {
      if (state is AppCreateInitialised) {
        var appCreateInitialised = state as AppCreateInitialised;
        var policyMedium = event.addThis;
        var appPolicyModel = AppPolicyModel(
          documentID: newRandomKey(),
          appId: appId,
          name: 'new policy',
          policy: policyMedium,
          conditions: StorageConditionsModel(
            privilegeLevelRequired:
                PrivilegeLevelRequiredSimple.noPrivilegeRequiredSimple,
          ),
        );
        await appPolicyRepository(appId: appId)!.add(appPolicyModel);
        var policies = await _policies();
        emit(AppCreateValidated(
            appCreateInitialised.appModel,
            appCreateInitialised.pages,
            appCreateInitialised.dialogs,
            appCreateInitialised.workflows,
            policies,
            appCreateInitialised.homeMenuModel,
            appCreateInitialised.appBarModel,
            appCreateInitialised.leftDrawerModel,
            appCreateInitialised.rightDrawerModel));
      }
    });

/*
    on<AppCreateAddWorkflow>((event, emit) async {
      if (state is AppCreateInitialised) {
        var appCreateInitialised = state as AppCreateInitialised;
        var workflow = event.addThis;
        var appPolicyModel = AppPolicyModel(
          documentID: newRandomKey(),
          appId: appId,
          name: 'new policy',
          policy: policyMedium,
          conditions: StorageConditionsModel(
            privilegeLevelRequired:
            PrivilegeLevelRequiredSimple.noPrivilegeRequiredSimple,
          ),
        );
        await appPolicyRepository(appId: appId)!.add(appPolicyModel);
        var policies = await _policies();
        emit(AppCreateValidated(
            appCreateInitialised.appModel,
            appCreateInitialised.pages,
            appCreateInitialised.dialogs,
            appCreateInitialised.workflows,
            policies,
            appCreateInitialised.homeMenuModel,
            appCreateInitialised.appBarModel,
            appCreateInitialised.leftDrawerModel,
            appCreateInitialised.rightDrawerModel));
      }
    });
*/

    on<AppCreateEventApplyChanges>((event, emit) async {
      var theState = state as AppCreateInitialised;
      // check other blocks for implementation
      appModel.email = theState.appModel.email;
      appModel.description = theState.appModel.description;
      appModel.title = theState.appModel.title;
      appModel.logo = theState.appModel.logo;
      appModel.homePages = theState.appModel.homePages;
      appModel.appStatus = theState.appModel.appStatus;
      appModel.autoPrivileged1 = theState.appModel.autoPrivileged1;
      appModel.isFeatured = theState.appModel.isFeatured;
      appModel.includeSubscriptions = theState.appModel.includeSubscriptions;
      appModel.includeInvoiceAddress = theState.appModel.includeInvoiceAddress;
      appModel.includeShippingAddress =
          theState.appModel.includeShippingAddress;
      appModel.welcomeMessage = theState.appModel.welcomeMessage;

      if (event.save) {
        var app = await appRepository(appId: appId)!
            .get(theState.appModel.documentID);
        if (app == null) {
          await appRepository(appId: appId)!.add(theState.appModel);
        } else {
          await appRepository(appId: appId)!.update(theState.appModel);
        }
      }
      closeAll();
    });

    on<AppCreateEventClose>((event, emit) async {
      closeAll();
    });

    on<PagesUpdated>((event, emit) async {
      if (state is AppCreateInitialised) {
        var appCreateInitialised = state as AppCreateInitialised;
        emit(AppCreateValidated(
            appCreateInitialised.appModel,
            event.pages,
            appCreateInitialised.dialogs,
            appCreateInitialised.workflows,
            appCreateInitialised.policies,
            appCreateInitialised.homeMenuModel,
            appCreateInitialised.appBarModel,
            appCreateInitialised.leftDrawerModel,
            appCreateInitialised.rightDrawerModel));
      }
    });

    on<DialogsUpdated>((event, emit) async {
      if (state is AppCreateInitialised) {
        var appCreateInitialised = state as AppCreateInitialised;
        emit(AppCreateValidated(
            appCreateInitialised.appModel,
            appCreateInitialised.pages,
            event.dialogs,
            appCreateInitialised.workflows,
            appCreateInitialised.policies,
            appCreateInitialised.homeMenuModel,
            appCreateInitialised.appBarModel,
            appCreateInitialised.leftDrawerModel,
            appCreateInitialised.rightDrawerModel));
      }
    });

    on<WorkflowsUpdated>((event, emit) async {
      if (state is AppCreateInitialised) {
        var appCreateInitialised = state as AppCreateInitialised;
        emit(AppCreateValidated(
            appCreateInitialised.appModel,
            appCreateInitialised.pages,
            appCreateInitialised.dialogs,
            event.workflows,
            appCreateInitialised.policies,
            appCreateInitialised.homeMenuModel,
            appCreateInitialised.appBarModel,
            appCreateInitialised.leftDrawerModel,
            appCreateInitialised.rightDrawerModel));
      }
    });

    on<PoliciesUpdated>((event, emit) async {
      if (state is AppCreateInitialised) {
        var appCreateInitialised = state as AppCreateInitialised;
        emit(AppCreateValidated(
            appCreateInitialised.appModel,
            appCreateInitialised.pages,
            appCreateInitialised.dialogs,
            appCreateInitialised.workflows,
            event.policies,
            appCreateInitialised.homeMenuModel,
            appCreateInitialised.appBarModel,
            appCreateInitialised.leftDrawerModel,
            appCreateInitialised.rightDrawerModel));
      }
    });
  }

  static AppModel deepCopy(String appID, AppModel from) {
    var homePages = from.homePages ?? AppHomePageReferencesModel();
    var copyOfAppModel = from.copyWith(
        documentID: appID, homePages: homePages, title: from.title);
    return copyOfAppModel;
  }
}
