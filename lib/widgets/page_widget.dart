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
import 'package:eliud_pkg_etc/widgets/decorator/can_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'bodycomponents/bodycomponents_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'condition/conditions_widget.dart';

void openPage(BuildContext context, AppModel app, bool create, PageModel model, String title,
    {VoidCallback? callOnAction, double? fraction}) {
  openFlexibleDialog(context,
      includeHeading: false,
      widthFraction: fraction,
      child: PageCreateWidget.getIt(
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

class PageCreateWidget extends StatefulWidget {
  final double widgetWidth;
  final bool create;
  final AppModel app;

  PageCreateWidget._({
    Key? key,
    required this.app,
    required this.create,
    required this.widgetWidth,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageCreateWidgetState();
  }

  static Widget getIt(
    BuildContext context,
    AppModel app,
    VoidCallback? callOnAction,
    PageModel appBarModel,
    bool create,
    double widgetWidth,
  ) {
    return BlocProvider<PageCreateBloc>(
      create: (context) =>
          PageCreateBloc(app.documentID!, appBarModel, callOnAction)
            ..add(PageCreateEventValidateEvent(appBarModel)),
      child: PageCreateWidget._(
        app: app,
        create: create,
        widgetWidth: widgetWidth,
      ),
    );
  }
}

class _PageCreateWidgetState extends State<PageCreateWidget> {
  @override
  Widget build(BuildContext context) {
    // Don't know:
    // layout
    // gridview
    // widgetWrapper

    return BlocBuilder<PageCreateBloc, PageCreateState>(
        builder: (context, state) {
      if (state is PageCreateValidated) {
        return ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
          HeaderWidget(
            cancelAction: () async {
              BlocProvider.of<PageCreateBloc>(context)
                  .add(PageCreateEventRevertChanges());
              return true;
            },
            okAction: () async {
              BlocProvider.of<PageCreateBloc>(context)
                  .add(PageCreateEventApplyChanges(true));
              return true;
            },
            title: widget.create
                ? 'Create new page'
                : 'Change page ' + state.pageModel.documentID!,
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
                              initialValue: state.pageModel.documentID,
                              valueChanged: (value) {
                                state.pageModel.documentID = value;
                              },
                              decoration: const InputDecoration(
                                hintText: 'Identifier',
                                labelText: 'Identifier',
                              ),
                            )
                          : text(context, state.pageModel.documentID!))
                ]),
          BodyComponentsCreateWidget.getIt(
            context,
            widget.app,
            state.pageModel.bodyComponents!,
            widget.widgetWidth,
          ),
          ConditionsWidget(value: state.pageModel.conditions!, ownerType: 'page',
              comment: pageAndDialogComment),
        ]);
      } else {
        return progressIndicator(context);
      }
    });
  }
}
