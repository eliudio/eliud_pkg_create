import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/blocs/access/state/access_determined.dart';
import 'package:eliud_core/core/blocs/access/state/access_state.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/dialog_list_bloc.dart';
import 'package:eliud_core/model/dialog_list_event.dart';
import 'package:eliud_core/model/dialog_list_state.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/page_list_bloc.dart';
import 'package:eliud_core/model/page_list_event.dart';
import 'package:eliud_core/model/page_list_state.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_tabs.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/etc.dart';
import 'package:eliud_core/tools/query/query_tools.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:eliud_pkg_create/widgets/utils/popup_menu_item_choices.dart';
import 'package:eliud_pkg_workflow/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_workflow/model/workflow_list_bloc.dart';
import 'package:eliud_pkg_workflow/model/workflow_list_event.dart';
import 'package:eliud_pkg_workflow/model/workflow_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:flutter/widgets.dart';

import '../dialog_widget.dart';
import '../page_widget.dart';
import '../workflow_widget.dart';
import 'menudef_bloc/menudef_create_bloc.dart';
import 'menudef_bloc/menudef_create_event.dart';
import 'menudef_bloc/menudef_create_state.dart';
import 'menuitem_widget.dart';

class MenuDefCreateWidget extends StatefulWidget {
  final AppModel app;

  MenuDefCreateWidget._({
    required this.app,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MenuDefCreateWidgetState();
  }

  static Widget getIt(
    BuildContext context,
    AppModel app,
    MenuDefModel menuDefModel,
  ) {
    return BlocProvider<MenuDefCreateBloc>(
      create: (context) => MenuDefCreateBloc(
        app,
        menuDefModel,
      )..add(MenuDefCreateInitialiseEvent(menuDefModel)),
      child: MenuDefCreateWidget._(
        app: app,
      ),
    );
  }
}

class _MenuDefCreateWidgetState extends State<MenuDefCreateWidget>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final List<String> items = ['Pages', 'Dialogs', 'Workflows', 'Other'];
  final int active = 0;
  GlobalKey? currentVisible = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var app = widget.app;
    var appId = app.documentID!;
    return MultiBlocProvider(
        providers: [
          BlocProvider<PageListBloc>(
            create: (context) => PageListBloc(
              eliudQuery: getComponentSelectorQuery(0, widget.app.documentID!),
              pageRepository: pageRepository(appId: appId)!,
            )..add(LoadPageList()),
          ),
          BlocProvider<DialogListBloc>(
            create: (context) => DialogListBloc(
              eliudQuery: getComponentSelectorQuery(0, widget.app.documentID!),
              dialogRepository: dialogRepository(appId: appId)!,
            )..add(LoadDialogList()),
          ),
          BlocProvider<WorkflowListBloc>(
            create: (context) => WorkflowListBloc(
              workflowRepository: workflowRepository(appId: appId)!,
            )..add(LoadWorkflowList()),
          ),
        ],
        child: BlocBuilder<AccessBloc, AccessState>(
            builder: (context, accessState) {
          if (accessState is AccessDetermined) {
            return BlocBuilder<MenuDefCreateBloc, MenuDefCreateState>(
                builder: (context, state) {
              if (state is MenuDefCreateInitialised) {
                currentVisible = GlobalKey();
                ensureCurrentIsVisible();
                int count = 0;
                int size = state.menuDefModel.menuItems!.length;
                return Column(children: [
                  topicContainer(app, context,
                      title: 'Current menu items',
                      collapsible: true,
                      collapsed: true,
                      children: [
                        Container(
                            height: height(),
                            child: SingleChildScrollView(
                                physics: const ScrollPhysics(),
                                child: Column(
                                    children: state.menuDefModel.menuItems!
                                        .map((item) {
                                  var theKey;
                                  if (item == state.currentlySelected)
                                    theKey = currentVisible;
                                  count++;
                                  return ListTile(
                                      key: theKey,
                                      //                              onTap: () => details(item),
                                      leading: item.icon == null
                                          ? text(
                                              app,
                                              context,
                                              item.text == null
                                                  ? "?"
                                                  : item.text!)
                                          : IconHelper.getIconFromModel(
                                              iconModel: item.icon),
                                      trailing: PopupMenuItemChoices(
                                        app: app,
                                        isFirst: (count != 1),
                                        isLast: (count != size),
                                        actionUp: () =>
                                            BlocProvider.of<MenuDefCreateBloc>(
                                                    context)
                                                .add(MenuDefMoveMenuItem(item,
                                                    MoveMenuItemDirection.Up)),
                                        actionDown: () => BlocProvider.of<
                                                MenuDefCreateBloc>(context)
                                            .add(MenuDefMoveMenuItem(item,
                                                MoveMenuItemDirection.Down)),
                                        actionDetails: () =>
                                            details(appId, item),
                                        actionDelete: () => BlocProvider.of<
                                                MenuDefCreateBloc>(context)
                                            .add(MenuDefCreateDeleteMenuItem(
                                                item)),
                                      ),
                                      title: text(
                                          app,
                                          context,
                                          item.action != null
                                              ? item.action!.describe()
                                              : ''),
                                      subtitle: text(
                                          app,
                                          context,
                                          item.text == null
                                              ? "?"
                                              : item.text!));
                                }).toList())))
                      ]),
                  topicContainer(
                    app,
                    context,
                    title: 'Available menu items',
                    collapsible: true,
                    collapsed: true,
                    children: [
                      Column(children: [
                        tabBar(app, context,
                            items: items, tabController: _tabController!),
                        if (_tabController!.index == 0)
                          PagesOrDialogsWidget(
                              app: widget.app,
                              pages: true,
                              availableMenuItemPopup: (page) =>
                                  availableMenuItemPopup(
                                      MenuDefCreateAddMenuItemForPage(page!),
                                      () => openPage(
                                            context,
                                            app,
                                            false,
                                            page,
                                            'Update page',
                                          )),
                              height: height() + 50),
                        if (_tabController!.index == 1)
                          PagesOrDialogsWidget(
                              app: widget.app,
                              pages: false,
                              availableMenuItemPopup: (dialog) =>
                                  availableMenuItemPopup(
                                      MenuDefCreateAddMenuItemForDialog(
                                          dialog!),
                                      () => openDialog(
                                            context,
                                            app,
                                            true,
                                            dialog,
                                            'Update dialog',
                                          )),
                              height: height() + 50),
                        if (_tabController!.index == 2)
                          Container(
                              height: height(),
                              child: BlocBuilder<WorkflowListBloc,
                                  WorkflowListState>(builder: (context, state) {
                                if ((state is WorkflowListLoaded) &&
                                    (state.values != null)) {
                                  var workflows = state.values!;
                                  return ListView(
                                      children: [
                                        Container(
                                            height: 200,
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                physics: const ScrollPhysics(),
                                                itemCount: workflows.length,
                                                itemBuilder:
                                                    (context, position) {
                                                  var workflow =
                                                      workflows[position];
                                                  return ListTile(
                                                      trailing:
                                                          availableMenuItemPopup(
                                                              MenuDefCreateAddMenuItemForWorkflow(
                                                                  workflow!),
                                                              () =>
                                                                  openWorkflow(
                                                                    context,
                                                                    app,
                                                                    false,
                                                                    workflow,
                                                                    'Update workflow',
                                                                  )),
                                                      //Icon(Icons.add),
                                                      title: text(
                                                          app,
                                                          context,
                                                          workflow
                                                              .documentID!));
                                                })),
                                        divider(app, context),
                                        GestureDetector(
                                            child: const Icon(Icons.add),
                                            onTap: () {
                                              openWorkflow(
                                                context,
                                                app,
                                                true,
                                                newWorkflowDefaults(
                                                    app.documentID!),
                                                'Create workflow',
                                              );
                                            })
                                      ],
                                      shrinkWrap: true,
                                      physics: const ScrollPhysics());
                                } else {
                                  return progressIndicator(app, context);
                                }
                              })),
                        if (_tabController!.index == 3)
                          Container(
                              height: height(),
                              child: ListView(
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                children: [
                                  ListTile(
                                      trailing: GestureDetector(
                                          onTap: () {
                                            BlocProvider.of<MenuDefCreateBloc>(
                                                    context)
                                                .add(MenuDefCreateAddLogin());
                                          },
                                          child: const Icon(Icons.add)),
                                      title: text(app, context, 'login')),
                                  ListTile(
                                      trailing: GestureDetector(
                                          onTap: () {
                                            BlocProvider.of<MenuDefCreateBloc>(
                                                    context)
                                                .add(MenuDefCreateAddLogout());
                                          },
                                          child: const Icon(Icons.add)),
                                      title: text(app, context, 'logout')),
                                  ListTile(
                                      trailing: GestureDetector(
                                          onTap: () {
                                            BlocProvider.of<MenuDefCreateBloc>(
                                                    context)
                                                .add(MenuDefCreateAddGoHome());
                                          },
                                          child: const Icon(Icons.add)),
                                      title: text(app, context, 'go home')),
                                  ListTile(
                                      trailing: GestureDetector(
                                          onTap: () {
                                            BlocProvider.of<MenuDefCreateBloc>(
                                                    context)
                                                .add(
                                                    MenuDefCreateAddOtherApps());
                                          },
                                          child: const Icon(Icons.add)),
                                      title: text(app, context, 'other apps')),
                                ],
                              )),
                      ])
                    ],
                  )
                ]);
              } else {
                return progressIndicator(app, context);
              }
            });
          } else {
            return progressIndicator(app, context);
          }
        }));
  }

  PopupMenuButton<int> availableMenuItemPopup(
      MenuDefCreateEvent eventWhenAdded, VoidCallback updateAction) {
    return PopupMenuButton<int>(
        child: const Icon(Icons.more_vert),
        elevation: 10,
        itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: text(widget.app, context, 'Add to menu'),
              ),
              PopupMenuItem(
                value: 2,
                child: text(widget.app, context, 'Update'),
              ),
            ],
        onSelected: (value) {
          if (value == 1) {
            BlocProvider.of<MenuDefCreateBloc>(context).add(eventWhenAdded);
          } else if (value == 2) {
            updateAction();
          }
        });
  }

  void details(String appId, MenuItemModel menuItemModel) {
    var toUpdate = menuItemModel.copyWith();
    openFlexibleDialog(widget.app, context, appId + '/_error',
        title: 'Update Menu Item',
        widthFraction: .5,
        child: MenuItemWidget(app: widget.app, menuItemModel: toUpdate),
        buttons: [
          dialogButton(widget.app, context, label: 'Cancel', onPressed: () {
            Navigator.of(context).pop();
          }),
          dialogButton(widget.app, context, label: 'Ok', onPressed: () {
            BlocProvider.of<MenuDefCreateBloc>(context)
                .add(MenuDefUpdateMenuItem(menuItemModel, toUpdate));
            Navigator.of(context).pop();
          }),
        ]);
  }

  Widget getTitle(String _title) =>
      Center(child: h3(widget.app, context, _title));

  void ensureCurrentIsVisible() {
    if (currentVisible != null) {
      if (WidgetsBinding.instance != null) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          var context = currentVisible!.currentContext;
          if (context != null) {
            Scrollable.ensureVisible(context);
          }
        });
      }
    }
  }

  double height() => 250; //(widget.widgetHeight / 2);

  @override
  void initState() {
    var size = items.length;
    _tabController = TabController(vsync: this, length: size);
    _tabController!.addListener(_handleTabSelection);
    _tabController!.index = active;

    super.initState();
  }

  @override
  void dispose() {
    if (_tabController != null) {
      _tabController!.dispose();
    }
    super.dispose();
  }

  void _handleTabSelection() {
    if ((_tabController != null) && (_tabController!.indexIsChanging)) {
      setState(() {});
    }
  }
}

typedef AvailableMenuItemPopupProvider(model);

class PagesOrDialogsWidget extends StatefulWidget {
  final AppModel app;
  final bool pages;
  final AvailableMenuItemPopupProvider availableMenuItemPopup;
  final double height;

  PagesOrDialogsWidget(
      {required this.app,
      Key? key,
      required this.pages,
      required this.availableMenuItemPopup,
      required this.height})
      : super(key: key);

  @override
  _PagesOrDialogsWidgetState createState() {
    return _PagesOrDialogsWidgetState();
  }
}

class _PagesOrDialogsWidgetState extends State<PagesOrDialogsWidget>
    with SingleTickerProviderStateMixin {
  TabController? _privilegeTabController;
  final List<String> _privilegeItems = ['No', 'L1', 'L2', 'Owner'];
  final int _initialPrivilege = 0;
  int _currentPrivilege = 0;

  _PagesOrDialogsWidgetState();

  @override
  void initState() {
    var _privilegeASize = _privilegeItems.length;
    _privilegeTabController =
        TabController(vsync: this, length: _privilegeASize);
    _privilegeTabController!.addListener(_handlePrivilegeTabSelection);
    _privilegeTabController!.index = _initialPrivilege;

    super.initState();
  }

  void _handlePrivilegeTabSelection() {
    if ((_privilegeTabController != null) &&
        (_privilegeTabController!.indexIsChanging)) {
      _currentPrivilege = _privilegeTabController!.index;
      BlocProvider.of<PageListBloc>(context).add(PageChangeQuery(
          newQuery: getComponentSelectorQuery(
              _currentPrivilege, widget.app.documentID!)));
      BlocProvider.of<DialogListBloc>(context).add(DialogChangeQuery(
          newQuery: getComponentSelectorQuery(
              _currentPrivilege, widget.app.documentID!)));
    }
  }

  @override
  void dispose() {
    if (_privilegeTabController != null) {
      _privilegeTabController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var newPrivilegeItems = <Widget>[];
    int i = 0;
    for (var privilegeItem in _privilegeItems) {
      newPrivilegeItems.add(text(widget.app, context, privilegeItem));
      i++;
    }
    if (widget.pages) {
      return Container(
          height: widget.height,
          child: BlocBuilder<PageListBloc, PageListState>(
              builder: (context, state) {
            if ((state is PageListLoaded) && (state.values != null)) {
              var pages = state.values!;
              return ListView(children: [
                tabBar2(widget.app, context,
                    items: newPrivilegeItems,
                    tabController: _privilegeTabController!),
                Container(
                    height: 200,
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemCount: pages.length,
                        itemBuilder: (context, position) {
                          var page = pages[position];
                          return ListTile(
                              trailing: widget.availableMenuItemPopup(page),
                              //Icon(Icons.add),
                              title:
                                  text(widget.app, context, page!.documentID!));
                        })),
                divider(widget.app, context),
                GestureDetector(
                    child: const Icon(Icons.add),
                    onTap: () {
                      openPage(
                        context,
                        widget.app,
                        true,
                        newPageDefaults(widget.app.documentID!),
                        'Create page',
                      );
                    })
              ], shrinkWrap: true, physics: const ScrollPhysics());
            } else {
              return progressIndicator(widget.app, context);
            }
          }));
    } else {
      return Container(
          height: widget.height,
          child: BlocBuilder<DialogListBloc, DialogListState>(
              builder: (context, state) {
            if ((state is DialogListLoaded) && (state.values != null)) {
              var dialogs = state.values!;
              return ListView(children: [
                tabBar2(widget.app, context,
                    items: newPrivilegeItems,
                    tabController: _privilegeTabController!),
                Container(
                    height: 200,
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemCount: dialogs.length,
                        itemBuilder: (context, position) {
                          var dialog = dialogs[position];
                          return ListTile(
                              trailing: widget.availableMenuItemPopup(
                                dialog,
                              ),
                              //Icon(Icons.add),
                              title: text(
                                  widget.app, context, dialog!.documentID!));
                        })),
                divider(widget.app, context),
                GestureDetector(
                    child: const Icon(Icons.add),
                    onTap: () {
                      openDialog(
                        context,
                        widget.app,
                        true,
                        newDialogDefaults(widget.app.documentID!),
                        'Create dialog',
                      );
                    })
              ], shrinkWrap: true, physics: const ScrollPhysics());
            } else {
              return progressIndicator(widget.app, context);
            }
          }));
    }
  }
}
