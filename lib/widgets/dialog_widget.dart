import 'package:eliud_core/core/access/bloc/access_bloc.dart';
import 'package:eliud_core/model/dialog_model.dart';
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
import 'package:eliud_pkg_create/widgets/dialog_bloc/dialog_bloc.dart';
import 'package:eliud_pkg_create/widgets/dialog_bloc/dialog_event.dart';
import 'package:eliud_pkg_create/widgets/dialog_bloc/dialog_state.dart';
import 'package:eliud_pkg_create/widgets/privilege_widget.dart';
import 'package:eliud_pkg_etc/widgets/decorator/can_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'bodycomponents/bodycomponents_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'condition/conditions_widget.dart';

void openDialog(
  BuildContext context,
  bool create,
  DialogModel model,
  String title, {
  VoidCallback? callOnAction,
  double? fraction = 1,
}) {
  openFlexibleDialog(context,
      includeHeading: false,
      widthFraction: fraction,
      child: DialogCreateWidget.getIt(
        context,
        callOnAction,
        model,
        create,
        fullScreenWidth(context) * (fraction ?? 1),
        //fullScreenHeight(context) - 100,
      ),
      );
}

class DialogCreateWidget extends StatefulWidget {
  final double widgetWidth;
  final bool create;

  DialogCreateWidget._({
    Key? key,
    required this.create,
    required this.widgetWidth,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DialogCreateWidgetState();
  }

  static Widget getIt(
    BuildContext context,
    VoidCallback? callOnAction,
    DialogModel appBarModel,
    bool create,
    double widgetWidth,
  ) {
    var app = AccessBloc.app(context);
    return BlocProvider<DialogCreateBloc>(
      create: (context) =>
          DialogCreateBloc(app!.documentID!, appBarModel, callOnAction)
            ..add(DialogCreateEventValidateEvent(appBarModel)),
      child: DialogCreateWidget._(
        create: create,
        widgetWidth: widgetWidth,
      ),
    );
  }
}

class _DialogCreateWidgetState extends State<DialogCreateWidget> {
  @override
  Widget build(BuildContext context) {
    // Don't know:
    // layout
    // gridview
    // widgetWrapper

    return BlocBuilder<DialogCreateBloc, DialogCreateState>(
        builder: (context, state) {
      if (state is DialogCreateValidated) {
        return ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
          HeaderWidget(
            cancelAction: () async {
              BlocProvider.of<DialogCreateBloc>(context)
                  .add(DialogCreateEventRevertChanges());
              return true;
            },
            okAction: () async {
              BlocProvider.of<DialogCreateBloc>(context)
                  .add(DialogCreateEventApplyChanges(true));
              return true;
            },
            title: widget.create
                ? 'Create new dialog'
                : 'Change dialog ' + state.dialogModel.documentID!,
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
                              initialValue: state.dialogModel.documentID,
                              valueChanged: (value) {
                                state.dialogModel.documentID = value;
                              },
                              decoration: const InputDecoration(
                                hintText: 'Identifier',
                                labelText: 'Identifier',
                              ),
                            )
                          : text(context, state.dialogModel.documentID!))
                ]),
          BodyComponentsCreateWidget.getIt(
            context,
            state.dialogModel.bodyComponents!,
            widget.widgetWidth,
          ),
          ConditionsWidget(value: state.dialogModel.conditions!, ownerType: 'dialog',
              comment: pageAndDialogComment),
        ]);
      } else {
        return progressIndicator(context);
      }
    });
  }
}
