import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/blocs/access/state/access_determined.dart';
import 'package:eliud_core/core/blocs/access/state/access_state.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:eliud_pkg_create/widgets/utils/popup_menu_item_choices.dart';
import 'package:eliud_pkg_create/widgets/workflowtasks/workflow_task_widget.dart';
import 'package:eliud_pkg_workflow/model/workflow_task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart';
import 'workflowtasks__bloc/workflowtasks_create_bloc.dart';
import 'workflowtasks__bloc/workflowtasks_create_event.dart';
import 'workflowtasks__bloc/workflowtasks_create_state.dart';

class WorkflowTasksCreateWidget extends StatefulWidget {
  final double widgetWidth;
  final AppModel app;

  WorkflowTasksCreateWidget._({
    required this.app,
    Key? key,
    required this.widgetWidth,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WorkflowTasksCreateWidgetState();
  }

  static Widget getIt(
    BuildContext context,
    AppModel app,
    List<WorkflowTaskModel> workflowTasks,
    double widgetWidth,
    /*double widgetHeight
      */
  ) {
    return BlocProvider<WorkflowTasksCreateBloc>(
      create: (context) => WorkflowTasksCreateBloc(
        app,
        workflowTasks,
      )..add(WorkflowTasksCreateInitialiseEvent(workflowTasks)),
      child: WorkflowTasksCreateWidget._(
        app: app,
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
    return BlocBuilder<AccessBloc, AccessState>(
        builder: (context, accessState) {
      if (accessState is AccessDetermined) {
        return BlocBuilder<WorkflowTasksCreateBloc, WorkflowTasksCreateState>(
            builder: (context, state) {
          if (state is WorkflowTasksCreateInitialised) {
            currentVisible = GlobalKey();
            ensureCurrentIsVisible();
            int count = 0;
            int size = state.workflowTaskModels.length;
            return Column(
              children: [
                topicContainer(widget.app, context,
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
                                    children:
                                        state.workflowTaskModels.map((item) {
                                  var theKey;
                                  if (item == state.currentlySelected)
                                    theKey = currentVisible;
                                  count++;
                                  return getListTile(context, widget.app,
                                      key: theKey,
                                      //                                  onTap: () => details(context, item),
                                      leading: text(widget.app, context,
                                          item.seqNumber.toString()),
                                      trailing: PopupMenuItemChoices(
                                        app: widget.app,
                                        isFirst: (count != 1),
                                        isLast: (count != size),
                                        actionUp: () => BlocProvider.of<
                                                    WorkflowTasksCreateBloc>(
                                                context)
                                            .add(WorkflowTasksMoveItem(
                                                item, MoveItemDirection.Up)),
                                        actionDown: () => BlocProvider.of<
                                                    WorkflowTasksCreateBloc>(
                                                context)
                                            .add(WorkflowTasksMoveItem(
                                                item, MoveItemDirection.Down)),
                                        actionDetails: () =>
                                            details(context, item),
                                        actionDelete: () => BlocProvider.of<
                                                    WorkflowTasksCreateBloc>(
                                                context)
                                            .add(
                                                WorkflowTasksCreateDeleteMenuItem(
                                                    item)),
                                      ),
                                      title: text(
                                          widget.app,
                                          context,
                                          ((item.task == null) &&
                                                  (item.task!.description !=
                                                      null))
                                              ? '?'
                                              : item.task!.description));
                                }).toList()))),
                        divider(widget.app, context),
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
            return progressIndicator(widget.app, context);
          }
        });
      } else {
        return progressIndicator(widget.app, context);
      }
    });
  }

  void details(BuildContext context,
      WorkflowTaskModel? workflowTaskModel /*, EditorFeedback feedback*/) {
    var newVersion;
    if (workflowTaskModel == null) {
      newVersion = newWorkflowTaskDefaults();
    } else {
      newVersion = workflowTaskModel.copyWith();
    }
    openComplexDialog(
      widget.app,
      context,
      widget.app.documentID! + '/_createtask',
      title: 'Create divider',
      includeHeading: false,
      widthFraction: .9,
      child: WorkflowTaskWidget(
          app: widget.app,
          model: newVersion,
          create: workflowTaskModel == null,
          feedback: (status) {
            if (status) {
              if (workflowTaskModel != null) {
                BlocProvider.of<WorkflowTasksCreateBloc>(context).add(
                    WorkflowTasksUpdateItem(workflowTaskModel, newVersion));
              } else {
                BlocProvider.of<WorkflowTasksCreateBloc>(context)
                    .add(WorkflowTasksCreateAddWorkflowTask(newVersion));
              }
            }
          }),
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
