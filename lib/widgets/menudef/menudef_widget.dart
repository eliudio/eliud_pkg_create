import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_tabs.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/style/style_registry.dart';
import 'package:eliud_core/tools/etc.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:eliud_pkg_create/widgets/utils/popup_menu_item_choices.dart';
import 'package:eliud_pkg_etc/widgets/decorator/can_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/core/access/bloc/access_bloc.dart';
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
/*
  final double widgetWidth;
  final double widgetHeight;
*/

  MenuDefCreateWidget._({
    Key? key,
/*
    required this.widgetWidth,
    required this.widgetHeight,
*/
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MenuDefCreateWidgetState();
  }

  static Widget getIt(
      BuildContext context,
      MenuDefModel
          menuDefModel /*,
      double widgetWidth, double widgetHeight*/
      ) {
    var app = AccessBloc.app(context);
    if (app == null) throw Exception("No app selected");
    return BlocProvider<MenuDefCreateBloc>(
      create: (context) => MenuDefCreateBloc(
        app,
        menuDefModel,
      )..add(MenuDefCreateInitialiseEvent(menuDefModel)),
      child: MenuDefCreateWidget._(),
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
    var app = AccessBloc.app(context);
    if (app == null) throw Exception("No app");
    return BlocBuilder<MenuDefCreateBloc, MenuDefCreateState>(
        builder: (context, state) {
      if (state is MenuDefCreateInitialised) {
        currentVisible = GlobalKey();
        ensureCurrentIsVisible();
        int count = 0;
        int size = state.menuDefModel.menuItems!.length;
        return Column(children: [
          topicContainer(context,
              title: 'Current menu items',
              collapsible: true,
              collapsed: true,
              children: [
                Container(
                    height: height(),
                    child: SingleChildScrollView(
                        physics: ScrollPhysics(),
                        child: Column(
                            children: state.menuDefModel.menuItems!.map((item) {
                          var theKey;
                          if (item == state.currentlySelected)
                            theKey = currentVisible;
                          count++;
                          return ListTile(
                              key: theKey,
//                              onTap: () => details(item),
                              leading: item.icon == null
                                  ? text(context,
                                      item.text == null ? "?" : item.text!)
                                  : IconHelper.getIconFromModel(
                                      iconModel: item.icon),
                              trailing: PopupMenuItemChoices(
                                isFirst: (count != 1),
                                isLast: (count != size),
                                actionUp: () =>
                                    BlocProvider.of<MenuDefCreateBloc>(context)
                                        .add(MenuDefMoveMenuItem(
                                            item, MoveMenuItemDirection.Up)),
                                actionDown: () =>
                                    BlocProvider.of<MenuDefCreateBloc>(context)
                                        .add(MenuDefMoveMenuItem(
                                            item, MoveMenuItemDirection.Down)),
                                actionDetails: () => details(item),
                                actionDelete: () =>
                                    BlocProvider.of<MenuDefCreateBloc>(context)
                                        .add(MenuDefCreateDeleteMenuItem(item)),
                              ),
                              title: text(
                                  context,
                                  item.action != null
                                      ? item.action!.describe()
                                      : ''),
                              subtitle: text(context,
                                  item.text == null ? "?" : item.text!));
                        }).toList())))
              ]),
          topicContainer(
            context,
            title: 'Available menu items',
            collapsible: true,
            collapsed: true,
            children: [
              Column(children: [
                tabBar(context, items: items, tabController: _tabController!),
                if (_tabController!.index == 0)
                  Container(
                    height: height(),
                    child: ListView(children: [
                      Container(
                          height: 200,
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              itemCount: state.pages.length,
                              itemBuilder: (context, position) {
                                var page = state.pages[position];
                                return ListTile(
                                    trailing: availableMenuItemPopup(
                                        MenuDefCreateAddMenuItemForPage(page!),
                                        () => openPage(
                                            context,
                                            false,
                                            page,
                                            'Update page',
                                            callOnAction: () => BlocProvider.of<
                                                    MenuDefCreateBloc>(context)
                                                .add(
                                                    MenuDefRefreshPages()))), //Icon(Icons.add),
                                    title: text(context, page.documentID!));
                              })),
                      divider(context),
                      GestureDetector(
                          child: Icon(Icons.add),
                          onTap: () {
                            openPage(
                                context,
                                true,
                                newPageDefaults(AccessBloc.appId(context)!),
                                'Create page',
                                callOnAction: () =>
                                    BlocProvider.of<MenuDefCreateBloc>(context)
                                        .add(MenuDefRefreshPages()));
                          })
                    ], shrinkWrap: true, physics: ScrollPhysics()),
                  ),
                if (_tabController!.index == 1)
                  Container(
                    height: height(),
                    child: ListView(children: [
                      Container(
                          height: 200,
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              itemCount: state.dialogs.length,
                              itemBuilder: (context, position) {
                                var dialog = state.dialogs[position];
                                return ListTile(
                                    trailing: availableMenuItemPopup(
                                        MenuDefCreateAddMenuItemForDialog(
                                            dialog!),
                                        () => openDialog(
                                            context,
                                            true,
                                            dialog,
                                            'Update dialog',
                                            callOnAction: () => BlocProvider.of<
                                                    MenuDefCreateBloc>(context)
                                                .add(
                                                    MenuDefRefreshDialogs()))), //Icon(Icons.add),
                                    title: text(
                                        context,
                                        dialog != null
                                            ? dialog.documentID!
                                            : '?'));
                              })),
                      divider(context),
                      GestureDetector(
                          child: Icon(Icons.add),
                          onTap: () {
                            openDialog(
                                context,
                                true,
                                newDialogDefaults(AccessBloc.appId(context)!),
                                'Create dialog',
                                callOnAction: () =>
                                    BlocProvider.of<MenuDefCreateBloc>(context)
                                        .add(MenuDefRefreshDialogs()));
                          })
                    ], shrinkWrap: true, physics: ScrollPhysics()),
                  ),
                if (_tabController!.index == 2)
                  Container(
                    height: height(),
                    child: ListView(children: [
                      Container(
                          height: 200,
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              itemCount: state.workflows.length,
                              itemBuilder: (context, position) {
                                var workflow = state.workflows[position];
                                return ListTile(
                                    trailing: availableMenuItemPopup(
                                        MenuDefCreateAddMenuItemForWorkflow(
                                            workflow!),
                                        () => openWorkflow(
                                            context,
                                            false,
                                            workflow,
                                            'Update workflow',
                                            callOnAction: () => BlocProvider.of<
                                                    MenuDefCreateBloc>(context)
                                                .add(
                                                    MenuDefRefreshWorkflows()))), //Icon(Icons.add),
                                    title: text(
                                        context,
                                        workflow != null
                                            ? workflow.documentID!
                                            : '?'));
                              })),
                      divider(context),
                      GestureDetector(
                          child: Icon(Icons.add),
                          onTap: () {
                            openWorkflow(
                                context,
                                true,
                                newWorkflowDefaults(AccessBloc.appId(context)!),
                                'Create workflow',
                                callOnAction: () =>
                                    BlocProvider.of<MenuDefCreateBloc>(context)
                                        .add(MenuDefRefreshWorkflows()));
                          })
                    ], shrinkWrap: true, physics: ScrollPhysics()),
                  ),
                if (_tabController!.index == 3)
                  Container(
                      height: height(),
                      child: ListView(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        children: [
                          ListTile(
                              trailing: GestureDetector(
                                  onTap: () {
                                    BlocProvider.of<MenuDefCreateBloc>(context)
                                        .add(MenuDefCreateAddLogin());
                                  },
                                  child: Icon(Icons.add)),
                              title: text(context, 'login')),
                          ListTile(
                              trailing: GestureDetector(
                                  onTap: () {
                                    BlocProvider.of<MenuDefCreateBloc>(context)
                                        .add(MenuDefCreateAddLogout());
                                  },
                                  child: Icon(Icons.add)),
                              title: text(context, 'logout')),
                          ListTile(
                              trailing: GestureDetector(
                                  onTap: () {
                                    BlocProvider.of<MenuDefCreateBloc>(context)
                                        .add(MenuDefCreateAddOtherApps());
                                  },
                                  child: Icon(Icons.add)),
                              title: text(context, 'other apps')),
                        ],
                      )),
              ])
            ],
          )
        ]);
      } else {
        return progressIndicator(context);
      }
    });
  }

  PopupMenuButton<int> availableMenuItemPopup(
      MenuDefCreateEvent eventWhenAdded, VoidCallback updateAction) {
    return PopupMenuButton<int>(
        child: Icon(Icons.more_vert),
        elevation: 10,
        itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: text(context, 'Add to menu'),
              ),
              PopupMenuItem(
                value: 2,
                child: text(context, 'Update'),
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

  void details(MenuItemModel menuItemModel) {
    var toUpdate = menuItemModel.copyWith();
    openFlexibleDialog(context,
        title: 'Update Menu Item',
        widthFraction: .5,
        child: MenuItemWidget(menuItemModel: toUpdate),
        buttons: [
          dialogButton(context, label: 'Cancel', onPressed: () {
            Navigator.of(context).pop();
          }),
          dialogButton(context, label: 'Ok', onPressed: () {
            BlocProvider.of<MenuDefCreateBloc>(context)
                .add(MenuDefUpdateMenuItem(menuItemModel, toUpdate));
            Navigator.of(context).pop();
          }),
        ]);
  }

  Widget getTitle(String _title) => Center(child: h3(context, _title));

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
