import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/style/frontend/has_dialog_field.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'package:eliud_pkg_create/widgets/page_bloc/page_bloc.dart';
import 'package:eliud_pkg_create/widgets/page_bloc/page_event.dart';
import 'package:eliud_pkg_create/widgets/page_bloc/page_state.dart';
import 'package:eliud_pkg_create/widgets/privilege_widget.dart';
import 'package:eliud_pkg_create/widgets/workflow_bloc/workflow_bloc.dart';
import 'package:eliud_pkg_create/widgets/workflow_bloc/workflow_event.dart';
import 'package:eliud_pkg_create/widgets/workflow_bloc/workflow_state.dart';
import 'package:eliud_pkg_create/widgets/workflowtasks/workflowtasks_widget.dart';
import 'package:eliud_pkg_workflow/model/workflow_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'bodycomponents/bodycomponents_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'condition/conditions_widget.dart';

void openWorkflow(BuildContext context, AppModel app, bool create, WorkflowModel model, String title,
    {VoidCallback? callOnAction, double? fraction}) {
  openFlexibleDialog(context,
      includeHeading: false,
      widthFraction: fraction,
      child: WorkflowCreateWidget.getIt(
        context,
        app,
        callOnAction,
        model,
        create,
        fullScreenWidth(context) * (fraction ?? 1),
        //fullScreenHeight(context) - 100,
      ),
      );
}

class WorkflowCreateWidget extends StatefulWidget {
  final double widgetWidth;
  final bool create;
  final AppModel app;

  WorkflowCreateWidget._({
    Key? key,
    required this.app,
    required this.create,
    required this.widgetWidth,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WorkflowCreateWidgetState();
  }

  static Widget getIt(
    BuildContext context,
    AppModel app,
    VoidCallback? callOnAction,
      WorkflowModel appBarModel,
    bool create,
    double widgetWidth,
  ) {
    return BlocProvider<WorkflowCreateBloc>(
      create: (context) =>
      WorkflowCreateBloc(app.documentID!, appBarModel, callOnAction)
            ..add(WorkflowCreateEventValidateEvent(appBarModel)),
      child: WorkflowCreateWidget._(
        app: app,
        create: create,
        widgetWidth: widgetWidth,
      ),
    );
  }
}

class _WorkflowCreateWidgetState extends State<WorkflowCreateWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkflowCreateBloc, WorkflowCreateState>(
        builder: (context, state) {
      if (state is WorkflowCreateValidated) {
        return ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
          HeaderWidget(
            cancelAction: () async {
              BlocProvider.of<WorkflowCreateBloc>(context)
                  .add(WorkflowCreateEventRevertChanges());
              return true;
            },
            okAction: () async {
              BlocProvider.of<WorkflowCreateBloc>(context)
                  .add(WorkflowCreateEventApplyChanges(true));
              return true;
            },
            title: widget.create
                ? 'Create new Workflow'
                : 'Change Workflow ' + state.workflowModel.documentID!,
          ),
          divider(context),
          if (widget.create)
            topicContainer(context,
                title: 'General',
                collapsible: true,
                collapsed: true,
                children: [
                  getListTile(context,
                      leading: Icon(Icons.vpn_key),
                      title: widget.create
                          ? dialogField(
                              context,
                              initialValue: state.workflowModel.documentID,
                              valueChanged: (value) {
                                state.workflowModel.documentID = value;
                              },
                              decoration: const InputDecoration(
                                hintText: 'Identifier',
                                labelText: 'Identifier',
                              ),
                            )
                          : text(context, state.workflowModel.documentID!))
                ]),
          WorkflowTasksCreateWidget.getIt(
            context,
            widget.app,
            state.workflowModel.workflowTask!,
            widget.widgetWidth,
          ),
        ]);
      } else {
        return progressIndicator(context);
      }
    });
  }
}
