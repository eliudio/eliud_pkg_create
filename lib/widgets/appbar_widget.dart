import 'package:eliud_core_main/model/app_bar_model.dart';
import 'package:eliud_core_main/model/app_model.dart';
import 'package:eliud_core_main/apis/style/frontend/has_dialog.dart';
import 'package:eliud_core_main/apis/style/frontend/has_divider.dart';
import 'package:eliud_core_helpers/etc/screen_size.dart';
import 'package:eliud_core/core/widgets/helper_widgets/header_widget.dart';
import 'package:flutter/material.dart';
import 'appbar_bloc/appbar_bloc.dart';
import 'appbar_bloc/appbar_event.dart';
import 'appbar_bloc/appbar_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'menudef/menudef_widget.dart';

typedef BlocProviderProvider = BlocProvider Function(Widget child);

void openAppBar(
  BuildContext context,
  AppModel app,
  AppBarModel model, {
  double? fraction,
}) {
  openFlexibleDialog(
    app,
    context,
    '${app.documentID}/_appbar',
    includeHeading: false,
    widthFraction: fraction,
    child: AppBarCreateWidget.getIt(
      context,
      app,
      model,
      fullScreenWidth(context) * ((fraction == null) ? 1 : fraction),
      fullScreenHeight(context) - 100,
    ),
  );
}

class AppBarCreateWidget extends StatefulWidget {
  final double widgetWidth;
  final double widgetHeight;
  final AppModel app;

  AppBarCreateWidget._({
    required this.app,
    required this.widgetWidth,
    required this.widgetHeight,
  });

  @override
  State<StatefulWidget> createState() {
    return _AppBarCreateWidgetState();
  }

  static Widget getIt(BuildContext context, AppModel app,
      AppBarModel appBarModel, double widgetWidth, double widgetHeight) {
    return BlocProvider<AppBarCreateBloc>(
      create: (context) => AppBarCreateBloc(
        app.documentID,
        appBarModel,
      )..add(AppBarCreateEventValidateEvent(appBarModel)),
      child: AppBarCreateWidget._(
        app: app,
        widgetWidth: widgetWidth,
        widgetHeight: widgetHeight,
      ),
    );
  }
}

class _AppBarCreateWidgetState extends State<AppBarCreateWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBarCreateBloc, AppBarCreateState>(
        builder: (context, state) {
      if (state is AppBarCreateValidated) {
        return ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
          HeaderWidget(
            app: widget.app,
            cancelAction: () async {
              return true;
            },
            okAction: () async {
              BlocProvider.of<AppBarCreateBloc>(context)
                  .add(AppBarCreateEventApplyChanges(true));
              return true;
            },
            title: 'AppBar',
          ),
          divider(widget.app, context),
          MenuDefCreateWidget.getIt(
            context,
            widget.app,
            state.appBarModel
                .iconMenu!, /*widget.widgetWidth, widget.widgetHeight - 50*/
          )
        ]);
      } else {
        return Center(child: CircularProgressIndicator());
      }
    });
  }
}
