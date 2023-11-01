import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'package:flutter/material.dart';
import 'bottom_navbar_bloc/bottom_navbar_bloc.dart';
import 'bottom_navbar_bloc/bottom_navbar_event.dart';
import 'bottom_navbar_bloc/bottom_navbar_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'menudef/menudef_widget.dart';

typedef BlocProvider BlocProviderProvider(Widget child);

void openBottomNavBar(
  BuildContext context,
  AppModel app,
  HomeMenuModel model, {
  double? fraction,
}) {
  openFlexibleDialog(app, context,app.documentID + '/_bottomnavbar',
      includeHeading: false,
      widthFraction: fraction,
      child: BottomNavBarCreateWidget.getIt(
        context,
        app,
        model,
        fullScreenWidth(context) * ((fraction == null) ? 1 : fraction),
        fullScreenHeight(context) - 100,
      ),
      );
}

class BottomNavBarCreateWidget extends StatefulWidget {
  final double widgetWidth;
  final double widgetHeight;
  final AppModel app;

  BottomNavBarCreateWidget._({
    Key? key,
    required this.app,
    required this.widgetWidth,
    required this.widgetHeight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BottomNavBarCreateWidgetState();
  }

  static Widget getIt(BuildContext context, AppModel app, HomeMenuModel homeMenuModel, double widgetWidth, double widgetHeight) {
    return BlocProvider<BottomNavBarCreateBloc>(
      create: (context) =>
          BottomNavBarCreateBloc(app.documentID, homeMenuModel)
            ..add(BottomNavBarCreateEventValidateEvent(homeMenuModel)),
      child: BottomNavBarCreateWidget._(
        app: app,
        widgetWidth: widgetWidth,
        widgetHeight: widgetHeight,
      ),
    );
  }
}

class _BottomNavBarCreateWidgetState extends State<BottomNavBarCreateWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavBarCreateBloc, BottomNavBarCreateState>(
        builder: (context, state) {
      if (state is BottomNavBarCreateValidated) {
        return Scrollbar(
            thickness: 10,
            child:
                ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
              HeaderWidget(app: widget.app,
                cancelAction: () async {
                  return true;
                },
                okAction: () async {
                  BlocProvider.of<BottomNavBarCreateBloc>(context)
                      .add(BottomNavBarCreateEventApplyChanges(true));
                  return true;
                },
                title: 'Bottom navigation bar',
/*
            applyAction: () => BlocProvider.of<BottomNavBarCreateBloc>(context)
                .add(BottomNavBarCreateEventApplyChanges(false)),
*/
              ),
              divider(widget.app, context),
              MenuDefCreateWidget.getIt(
                context,
                widget.app,
                state.homeMenuModel
                    .menu!, /*widget.widgetWidth, widget.widgetHeight - 50*/
              )
            ]));
      } else {
        return progressIndicator(widget.app, context);
      }
    });
  }
}
