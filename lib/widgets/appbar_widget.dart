import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'appbar_bloc/appbar_bloc.dart';
import 'appbar_bloc/appbar_event.dart';
import 'appbar_bloc/appbar_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'menudef/menudef_widget.dart';

typedef BlocProvider BlocProviderProvider(Widget child);

void openAppBar(
  BuildContext context,
  AppModel app,
  AppBarModel model,{
  double? fraction,
}) {
  openFlexibleDialog(context,
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
    Key? key,
    required this.widgetWidth,
    required this.widgetHeight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AppBarCreateWidgetState();
  }

  static Widget getIt(BuildContext context, AppModel app,
      AppBarModel appBarModel, double widgetWidth, double widgetHeight) {
    return BlocProvider<AppBarCreateBloc>(
      create: (context) =>
          AppBarCreateBloc(app.documentID!, appBarModel, )
            ..add(AppBarCreateEventValidateEvent(appBarModel)),
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
          divider(context),
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
