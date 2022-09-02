import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_dialog_field.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/component/component_spec.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'package:eliud_pkg_create/widgets/utils/combobox_widget.dart';
import 'package:eliud_pkg_create/widgets/utils/string_combobox_widget.dart';
import 'package:eliud_pkg_workflow/model/workflow_notification_model.dart';
import 'package:eliud_pkg_workflow/model/workflow_task_model.dart';
import 'package:eliud_pkg_workflow/tools/task/task_model_registry.dart';
import 'package:flutter/material.dart';

class WorkflowTaskWidget extends StatefulWidget {
  final AppModel app;
  final WorkflowTaskModel model;
  final bool create;
  final EditorFeedback? feedback;

  WorkflowTaskWidget(
      {Key? key,
      required this.app,
      required this.model,
      required this.create,
      required this.feedback})
      : super(key: key) {
  }

  @override
  State<StatefulWidget> createState() => _WorkflowTaskWidgetState();
}

class _WorkflowTaskWidgetState extends State<WorkflowTaskWidget> {
  @override
  Widget build(BuildContext context) {
    var tasks = TaskModelRegistry.registry()!.getTasks();
    var taskIdentifiers = tasks.map((element) => element.identifier).toList();
    TaskEditor? taskEditorWidget;
    var taskDetails;
    widget.model.task ??= tasks[0].createNewInstance();
    taskDetails = TaskModelRegistry.registry()!
        .getDetails(widget.model.task!.identifier);
    if (taskDetails != null) {
      taskEditorWidget = taskDetails!.editor;
    }
    return ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
      HeaderWidget(app: widget.app,
        title: 'Divider',
        okAction: () async {
          if (widget.feedback != null) {
            widget.feedback!(true, widget.model);
          }
          return true;
        },
        cancelAction: () async {
          return true;
        },
      ),
      topicContainer(widget.app, context,
          title: 'General',
          collapsible: true,
          collapsed: true,
          children: [
            getListTile(context, widget.app,
                leading: Icon(Icons.vpn_key),
                title: widget.create
                    ? dialogField(widget.app,
                        context,
                        initialValue: widget.model.documentID,
                        valueChanged: (value) {
                          widget.model.documentID = value;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Identifier',
                          labelText: 'Identifier',
                        ),
                      )
                    : text(widget.app, context, widget.model.documentID)),
            getListTile(context, widget.app,
                leading: Icon(Icons.description),
                title: dialogField(widget.app,
                  context,
                  initialValue: widget.model.task!.description,
                  valueChanged: (value) {
                    widget.model.task!.description = value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Description',
                    labelText: 'Desription',
                  ),
                )),
            getListTile(
              context, widget.app,
              leading: Icon(Icons.description),
              title: ComboboxWidget(
                app: widget.app,
                initialValue: (widget.model.task!.executeInstantly == null)
                    ? 0
                    : (widget.model.task!.executeInstantly ? 0 : 1),
                options: const [
                  'No',
                  'Yes',
                ],
                feedback: (value) => widget.model.task!.executeInstantly =
                    (value == 0) ? true : false,
                title: "Execute next task instantly (if same person)",
              ),
            ),
          ]),
      topicContainer(widget.app, context,
          title: 'Confirm message',
          collapsible: true,
          collapsed: true,
          children: [
            checkboxListTile(widget.app,
                context, 'Include', widget.model.confirmMessage != null,
                (value) {
                  setState(() {
                    if (value!) {
                      widget.model.confirmMessage = WorkflowNotificationModel(
                          message: '',
                          addressee: WorkflowNotificationAddressee
                              .CurrentMember);
                    } else {
                      widget.model.confirmMessage = null;
                    }
                  });
            }),
            if (widget.model.confirmMessage != null)
              getListTile(context, widget.app,
                  leading: const Icon(Icons.description),
                  title: dialogField(widget.app,
                    context,
                    initialValue: (widget.model.confirmMessage!.message == null)
                        ? ''
                        : widget.model.confirmMessage!.message,
                    valueChanged: (value) {
                      widget.model.confirmMessage!.message = value;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Confirm message',
                      labelText: 'Confirm message',
                    ),
                  )),
            if (widget.model.confirmMessage != null)
              getListTile(
                context, widget.app,
                leading: const Icon(Icons.security),
                title: ComboboxWidget(
                  app: widget.app,
                  initialValue: (widget.model.confirmMessage!.addressee == null)
                      ? 0
                      : widget.model.confirmMessage!.addressee!.index,
                  options: const [
                    'CurrentMember',
                    'Owner',
                    'First',
                    'Previous',
                  ],
                  descriptions: const [
                    'In case of confirmation, the current member will receive the confirmation message',
                    'In case of confirmation, the owner of the app will receive the confirmation message',
                    'In case of confirmation, the first member in the workflow receives the confirmation message',
                    'In case of confirmation, the member of the previous action receives the confirmation message',
                  ],
                  feedback: (value) => widget.model.confirmMessage!.addressee =
                      toWorkflowNotificationAddressee(value),
                  title: "Confirmation notification message",
                ),
              ),
          ]),
      topicContainer(widget.app, context,
          title: 'Reject message',
          collapsible: true,
          collapsed: true,
          children: [
            checkboxListTile(widget.app,
                context, 'Include', widget.model.rejectMessage != null,
                    (value) {
                  setState(() {
                    if (value!) {
                      widget.model.rejectMessage = WorkflowNotificationModel(
                          message: '',
                          addressee: WorkflowNotificationAddressee
                              .CurrentMember);
                    } else {
                      widget.model.rejectMessage = null;
                    }
                  });
                }),
            if (widget.model.rejectMessage != null)
             getListTile(context,widget.app,
                leading: const Icon(Icons.description),
                title: dialogField(widget.app,
                  context,
                  initialValue: (widget.model.rejectMessage == null ||
                          widget.model.rejectMessage!.message == null)
                      ? ''
                      : widget.model.rejectMessage!.message,
                  valueChanged: (value) {
                    widget.model.rejectMessage!.message = value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Reject message',
                    labelText: 'Reject message',
                  ),
                )),
            if (widget.model.rejectMessage != null)
              getListTile(
              context,widget.app,
              leading: const Icon(Icons.security),
              title: ComboboxWidget(app: widget.app,
                initialValue: (widget.model.rejectMessage!.addressee == null)
                    ? 0
                    : widget.model.rejectMessage!.addressee!.index,
                options: const [
                  'CurrentMember',
                  'Owner',
                  'First',
                  'Previous',
                ],
                descriptions: const [
                  'In case of rejection, the current member will receive the rejection message',
                  'In case of rejection, the owner of the app will receive the rejection message',
                  'In case of rejection, the first member in the workflow receives the rejection message',
                  'In case of rejection, the member of the previous action receives the rejection message',
                ],
                feedback: (value) => widget.model.rejectMessage!.addressee =
                    toWorkflowNotificationAddressee(value),
                title: "Rejection notification message",
              ),
            ),
          ]),
      topicContainer(widget.app,context,
          title: 'Task responsible',
          collapsible: true,
          collapsed: true,
          children: [
            getListTile(
              context,widget.app,
              leading: const Icon(Icons.security),
              title: ComboboxWidget(app: widget.app,
                initialValue: (widget.model.responsible == null)
                    ? 0
                    : widget.model.responsible!.index,
                options: const [
                  'CurrentMember',
                  'Owner',
                  'First',
                  'Previous',
                ],
                descriptions: const [
                  'The current member will be required to do the action',
                  'The owner of the app will be required to do the action',
                  'The first member will be required to do the action',
                  'The member of the previous action will be required to do the action',
                ],
                feedback: (value) =>
                    widget.model.responsible = toWorkflowTaskResponsible(value),
                title: "Task responsible",
              ),
            ),
          ]),
      topicContainer(widget.app,context,
          title: 'Task',
          collapsible: true,
          collapsed: true,
          children: [
            getListTile(
              context,widget.app,
              leading: Icon(Icons.security),
              title: StringComboboxWidget(app: widget.app,
                initialValue: widget.model.task!.identifier,
                options: taskIdentifiers,
                feedback: (value) {
                  var newTaskDetails = tasks[value];
                  setState(() {
                    widget.model.task = newTaskDetails.createNewInstance();
                  });
                },
                title: "Task type",
              ),
            ),
            if (taskEditorWidget != null) taskEditorWidget(widget.app, widget.model.task, ),
          ]),
    ]);
  }
}
