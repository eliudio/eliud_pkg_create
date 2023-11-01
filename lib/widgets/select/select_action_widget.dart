import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/dialog_list_bloc.dart';
import 'package:eliud_core/model/dialog_list_event.dart';
import 'package:eliud_core/model/dialog_list_state.dart';
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
import 'package:eliud_core/tools/action/action_model.dart';
import 'package:eliud_core/tools/query/query_tools.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'package:eliud_pkg_workflow/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_workflow/model/workflow_list_bloc.dart';
import 'package:eliud_pkg_workflow/model/workflow_list_event.dart';
import 'package:eliud_pkg_workflow/model/workflow_list_state.dart';
import 'package:eliud_pkg_workflow/tools/action/workflow_action_model.dart';
import 'package:eliud_core/core/registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget openSelectActionWidget({required AppModel app,
  required ActionModel? action,
  required ActionSelected actionSelected,
  required int containerPrivilege,
  required String label}) {
  return SelectActionWidget(app: app, action: action, actionSelected: actionSelected, containerPrivilege: containerPrivilege, label: label);
}

class SelectActionWidget extends StatefulWidget {
  final AppModel app;
  final ActionModel? action;
  final ActionSelected actionSelected;
  final int containerPrivilege;
  final String label;

  const SelectActionWidget(
      {Key? key,
      required this.app,
      required this.action,
      required this.actionSelected,
      required this.containerPrivilege,
      required this.label})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectActionWidgetState();
}

class _SelectActionWidgetState extends State<SelectActionWidget> {
  @override
  Widget build(BuildContext context) {
    return topicContainer(
      widget.app,
      context,
      title: widget.label,
      collapsible: true,
      collapsed: true,
      children: [
        Center(
            child: text(widget.app, context,
                widget.action != null ? widget.action.toString() : 'none')),
        Row(children: [
          Spacer(),
          button(widget.app, context, label: 'Select', onPressed: () {
            SelectActionDialog.openIt(
                context, widget.app, widget.actionSelected, widget.containerPrivilege);
          }),
          Spacer(),
          button(widget.app, context, label: 'Clear', onPressed: () {
            widget.actionSelected(null);
          }),
          Spacer(),
        ]),
      ],
    );
  }
}

class SelectActionDialog extends StatefulWidget {
  final AppModel app;
  final ActionSelected actionSelected;
  final int containerPrivilege;

  SelectActionDialog._({
    required this.app,
    required this.actionSelected,
    required this.containerPrivilege,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SelectActionDialogState();
  }

  static void openIt(
    BuildContext context,
    AppModel app,
    ActionSelected actionSelected,
    int containerPrivilege
  ) {
    openFlexibleDialog(app, context, app.documentID + '/_selectaction',
        includeHeading: false,
        widthFraction: .8,
        child: SelectActionDialog._(app: app, actionSelected: actionSelected, containerPrivilege: containerPrivilege,));
  }
}

class _SelectActionDialogState extends State<SelectActionDialog> {
  @override
  Widget build(BuildContext context) {
    var app = widget.app;
    var appId = app.documentID;
    return MultiBlocProvider(
        providers: [
          BlocProvider<PageListBloc>(
            create: (context) => PageListBloc(
              eliudQuery: getComponentSelectorQuery(0, app.documentID),
              pageRepository: pageRepository(appId: appId)!,
            )..add(LoadPageList()),
          ),
          BlocProvider<DialogListBloc>(
            create: (context) => DialogListBloc(
              dialogRepository: dialogRepository(appId: appId)!,
            )..add(LoadDialogList()),
          ),
          BlocProvider<WorkflowListBloc>(
            create: (context) => WorkflowListBloc(
              workflowRepository: workflowRepository(appId: appId)!,
            )..add(LoadWorkflowList()),
          ),
        ],
        child: SelectActionPrivilege(app: app, actionSelected: widget.actionSelected, containerPrivilege: widget.containerPrivilege));
  }

}

class SelectActionPrivilege extends StatefulWidget {
  final AppModel app;
  final ActionSelected actionSelected;
  final int containerPrivilege;

  SelectActionPrivilege({
    required this.app,
    required this.actionSelected,
    required this.containerPrivilege,
    Key? key,
  }) : super(key: key);

  @override
  _SelectActionPrivilegeState createState() {
    return _SelectActionPrivilegeState();
  }
}

class _SelectActionPrivilegeState extends State<SelectActionPrivilege>
    with SingleTickerProviderStateMixin {
  TabController? _privilegeTabController;
  final List<String> _privilegeItems = ['No', 'L1', 'L2', 'Owner'];
  final int _initialPrivilege = 0;
  int _currentPrivilege = 0;

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
      BlocProvider.of<PageListBloc>(context).add(
          PageChangeQuery(newQuery: getComponentSelectorQuery(_currentPrivilege, widget.app.documentID)));
      BlocProvider.of<DialogListBloc>(context).add(
          DialogChangeQuery(newQuery: getComponentSelectorQuery(_currentPrivilege, widget.app.documentID)));
/*
      BlocProvider.of<WorkflowListBloc>(context).add(
          WorkflowChangeQuery(newQuery: getComponentSelectorQuery(_currentPrivilege, widget.app.documentID)));
*/
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
      newPrivilegeItems.add(Wrap(children: [(i <= widget.containerPrivilege) ? Icon(Icons.check) : Icon(Icons.close), Container(width: 2), text(widget.app, context, privilegeItem)]));
      i++;
    }
    return ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
      HeaderWidget(
        app: widget.app,
        cancelAction: () async {
          return true;
        },
        title: 'Select page or dialog',
      ),
      divider(widget.app, context),
      Column(children: [
        tabBar2(widget.app, context,
            items: newPrivilegeItems, tabController: _privilegeTabController!),
        SelectActionPageOrDialog(app: widget.app, actionSelected: widget.actionSelected),
      ])
    ]);
  }

  double height() => 250; //(widget.widgetHeight / 2);
}

class SelectActionPageOrDialog extends StatefulWidget {
  final AppModel app;
  final ActionSelected actionSelected;

  SelectActionPageOrDialog({
    required this.app,
    required this.actionSelected,
    Key? key,
  }) : super(key: key);

  @override
  _SelectActionPageOrDialogState createState() {
    return _SelectActionPageOrDialogState();
  }

}

class _SelectActionPageOrDialogState extends State<SelectActionPageOrDialog>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final List<String> items = ['Pages', 'Dialogs', 'Workflows'];
  final int active = 0;
  GlobalKey? currentVisible = GlobalKey();

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

  @override
  Widget build(BuildContext context) {
    var app = widget.app;
    return ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
        tabBar(app, context, items: items, tabController: _tabController!),
        if (_tabController!.index == 0)
          Container(
              height: height(),
              child: BlocBuilder<PageListBloc, PageListState>(
                  builder: (context, state) {
                    if ((state is PageListLoaded) && (state.values != null)) {
                      var pages = state.values!;
                      return ListView(children: [
                        Container(
                            height: 200,
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemCount: pages.length,
                                itemBuilder: (context, position) {
                                  var page = pages[position];
                                  return GestureDetector(
                                      child: ListTile(
                                          title: text(
                                              app, context, page!.documentID)),
                                      onTap: () {
                                        widget.actionSelected(GotoPage(app,
                                            pageID: page.documentID));
                                        Navigator.pop(context);
                                      });
                                })),
                      ], shrinkWrap: true, physics: const ScrollPhysics());
                    } else {
                      return progressIndicator(app, context);
                    }
                  })),
      if (_tabController!.index == 1)
        Container(
            height: height(),
            child: BlocBuilder<DialogListBloc, DialogListState>(
                builder: (context, state) {
                  if ((state is DialogListLoaded) && (state.values != null)) {
                    var dialogs = state.values!;
                    return ListView(children: [
                      Container(
                          height: 200,
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              itemCount: dialogs.length,
                              itemBuilder: (context, position) {
                                var dialog = dialogs[position];
                                return GestureDetector(
                                    child: ListTile(
                                        title: text(app, context,
                                            dialog!.documentID)),
                                    onTap: () {
                                      widget.actionSelected(OpenDialog(app,
                                          dialogID: dialog.documentID));
                                      Navigator.pop(context);
                                    });
                              })),
                    ], shrinkWrap: true, physics: const ScrollPhysics());
                  } else {
                    return progressIndicator(app, context);
                  }
                })),
      if (_tabController!.index == 2)
        Container(
            height: height(),
            child: BlocBuilder<WorkflowListBloc, WorkflowListState>(
                builder: (context, state) {
                  if ((state is WorkflowListLoaded) && (state.values != null)) {
                    var workflows = state.values!;
                    return ListView(children: [
                      Container(
                          height: 200,
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              itemCount: workflows.length,
                              itemBuilder: (context, position) {
                                var workflow = workflows[position];
                                return GestureDetector(
                                    child: ListTile(
                                        title: text(app, context,
                                            workflow!.documentID)),
                                    onTap: () {
                                      widget.actionSelected(WorkflowActionModel(app,
                                           workflow: workflow));
                                      Navigator.pop(context);
                                    });
                              })),
                    ], shrinkWrap: true, physics: const ScrollPhysics());
                  } else {
                    return progressIndicator(app, context);
                  }
                })),
      ]);
  }

  double height() => 250; //(widget.widgetHeight / 2);
}


