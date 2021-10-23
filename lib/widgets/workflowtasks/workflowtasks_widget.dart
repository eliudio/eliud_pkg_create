import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/component/component_spec.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:eliud_pkg_create/widgets/utils/popup_menu_item_choices.dart';
import 'package:eliud_pkg_create/widgets/workflowtasks/workflow_task_widget.dart';
import 'package:eliud_pkg_workflow/model/workflow_task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/core/access/bloc/access_bloc.dart';
import 'package:flutter/widgets.dart';
import 'workflowtasks__bloc/workflowtasks_create_bloc.dart';
import 'workflowtasks__bloc/workflowtasks_create_event.dart';
import 'workflowtasks__bloc/workflowtasks_create_state.dart';

class WorkflowTasksCreateWidget extends StatefulWidget {
  final double widgetWidth;

  WorkflowTasksCreateWidget._({
    Key? key,
    required this.widgetWidth,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WorkflowTasksCreateWidgetState();
  }

  static Widget getIt(
    BuildContext context,
    List<WorkflowTaskModel> workflowTasks,
    double widgetWidth,
    /*double widgetHeight
      */
  ) {
    var app = AccessBloc.app(context);
    if (app == null) throw Exception("No app selected");
    return BlocProvider<WorkflowTasksCreateBloc>(
      create: (context) => WorkflowTasksCreateBloc(
        app,
        workflowTasks,
      )..add(WorkflowTasksCreateInitialiseEvent(workflowTasks)),
      child: WorkflowTasksCreateWidget._(
        widgetWidth: widgetWidth,
      ),
    );
  }
}

class _WorkflowTasksCreateWidgetState extends State<WorkflowTasksCreateWidget>
    with SingleTickerProviderStateMixin {
  final int active = 0;
  GlobalKey? currentVisible = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var app = AccessBloc.app(context);
    if (app == null) throw Exception("No app");
    return BlocBuilder<WorkflowTasksCreateBloc, WorkflowTasksCreateState>(
        builder: (context, state) {
      if (state is WorkflowTasksCreateInitialised) {
        currentVisible = GlobalKey();
        ensureCurrentIsVisible();
        int count = 0;
        int size = state.workflowTaskModels.length;
        return Column(
          children: [
            topicContainer(context,
                title: 'Tasks',
                collapsible: true,
                collapsed: false,
                children: [
                  ListView(children: [
                    Container(
                        height: 200, //heightUnit() * 1,
                        width: widget.widgetWidth,
                        child: SingleChildScrollView(
                            physics: ScrollPhysics(),
                            child: Column(
                                children: state.workflowTaskModels.map((item) {
                              var theKey;
                              if (item == state.currentlySelected)
                                theKey = currentVisible;
                              count++;
                              return getListTile(context,
                                  key: theKey,
//                                  onTap: () => details(context, item),
                                  leading:
                                      text(context, item.seqNumber.toString()),
                                  trailing: PopupMenuItemChoices(
                                    isFirst: (count != 1),
                                    isLast: (count != size),
                                    actionUp: () => BlocProvider.of<
                                            WorkflowTasksCreateBloc>(context)
                                        .add(WorkflowTasksMoveItem(
                                            item, MoveItemDirection.Up)),
                                    actionDown: () => BlocProvider.of<
                                            WorkflowTasksCreateBloc>(context)
                                        .add(WorkflowTasksMoveItem(
                                            item, MoveItemDirection.Down)),
                                    actionDetails: () => details(context, item),
                                    actionDelete: () => BlocProvider.of<
                                            WorkflowTasksCreateBloc>(context)
                                        .add(WorkflowTasksCreateDeleteMenuItem(
                                            item)),
                                  ),
                                  title: text(
                                      context,
                                      ((item.task == null) && (item.task!.description != null))
                                          ? '?'
                                          : item.task!.description));
                            }).toList()))),
                    divider(context),
                    GestureDetector(
                        child: Icon(Icons.add),
                        onTap: () {
                          details(context, null);
                        })
                  ], shrinkWrap: true, physics: ScrollPhysics()),
                ]),
          ],
        );
      } else {
        return progressIndicator(context);
      }
    });
  }

  void details(BuildContext context, WorkflowTaskModel? workflowTaskModel/*, EditorFeedback feedback*/) {
    openComplexDialog(
      context,
      title: 'Create divider',
      includeHeading: false,
      widthFraction: .9,
      child: WorkflowTaskWidget(
        model: (workflowTaskModel ?? newWorkflowTaskDefaults()),
        create: workflowTaskModel == null,
        feedback: null /*feedback*/),
    );
  }

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
}
