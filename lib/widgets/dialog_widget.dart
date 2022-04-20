import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/style/frontend/has_dialog_field.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_core/tools/widgets/editor/dialog_layout_widget.dart';
import 'package:eliud_core/tools/widgets/grid_view/select_grid_view_widget.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'package:eliud_pkg_create/widgets/dialog_bloc/dialog_bloc.dart';
import 'package:eliud_pkg_create/widgets/dialog_bloc/dialog_event.dart';
import 'package:eliud_pkg_create/widgets/dialog_bloc/dialog_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'bodycomponents/bodycomponents_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'condition/storage_conditions_widget.dart';

void openDialog(
  BuildContext context,
  AppModel app,
  bool create,
  DialogModel model,
  String title, {
  double? fraction = 1,
}) {
  openFlexibleDialog(
    app,
    context,
    app.documentID! + '/_dialog',
    includeHeading: false,
    widthFraction: fraction,
    child: DialogCreateWidget.getIt(
      context,
      app,
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
  final AppModel app;

  DialogCreateWidget._({
    Key? key,
    required this.app,
    required this.create,
    required this.widgetWidth,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DialogCreateWidgetState();
  }

  static Widget getIt(
    BuildContext context,
    AppModel app,
    DialogModel dialogModel,
    bool create,
    double widgetWidth,
  ) {
    return BlocProvider<DialogCreateBloc>(
      create: (context) => DialogCreateBloc(
        app.documentID!,
        dialogModel,
      )..add(DialogCreateEventValidateEvent(dialogModel)),
      child: DialogCreateWidget._(
        app: app,
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
            app: widget.app,
            cancelAction: () async {
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
          divider(widget.app, context),
          topicContainer(widget.app, context,
              title: 'General',
              collapsible: true,
              collapsed: true,
              children: [
                getListTile(context, widget.app,
                    leading: Icon(Icons.vpn_key),
                    title: widget.create
                        ? dialogField(
                            widget.app,
                            context,
                            readOnly: !widget.create,
                            initialValue: state.dialogModel.documentID,
                            valueChanged: (value) {
                              state.dialogModel.documentID = value;
                            },
                            decoration: const InputDecoration(
                              hintText: 'Identifier',
                              labelText: 'Identifier',
                            ),
                          )
                        : text(
                            widget.app, context, state.dialogModel.documentID!))
              ]),
          topicContainer(widget.app, context,
              title: 'Layout',
              collapsible: true,
              collapsed: true,
              children: [
//                BackgroundWidget(app: widget.app, label: 'Background override', value: state.pageModel.backgroundOverride, memberId: memberId);
                DialogLayoutWidget(
                  app: widget.app,
                  dialogLayoutCallback: (DialogLayout dialogLayout) {
                    setState(() {
                      state.dialogModel.layout = dialogLayout;
                    });
                  },
                  dialogLayout: state.dialogModel.layout ?? DialogLayout.ListView,
                ),
                if (state.dialogModel.layout == DialogLayout.GridView)
                  selectGridViewWidget(
                      context,
                      widget.app,
                      state.dialogModel.conditions,
                      state.dialogModel.gridView, (newGridView) {
                    setState(() {
                      state.dialogModel.gridView = newGridView;
                    });
                  }),
              ]),
          BodyComponentsCreateWidget.getIt(
            context,
            ((state.dialogModel.conditions == null) ||
                    (state.dialogModel.conditions!.privilegeLevelRequired ==
                        null))
                ? 0
                : state.dialogModel.conditions!.privilegeLevelRequired!.index,
            widget.app,
            state.dialogModel.bodyComponents!,
            widget.widgetWidth,
          ),
          StorageConditionsWidget(
              app: widget.app,
              value: state.dialogModel.conditions!,
              ownerType: 'dialog',
              feedback: (_) {
                setState(() {});
              }),
        ]);
      } else {
        return progressIndicator(widget.app, context);
      }
    });
  }
}
