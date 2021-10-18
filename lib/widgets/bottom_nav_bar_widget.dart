import 'package:eliud_core/core/access/bloc/access_bloc.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'package:eliud_pkg_etc/widgets/decorator/can_refresh.dart';
import 'package:eliud_pkg_medium/tools/media_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'appbar_bloc/appbar_bloc.dart';
import 'appbar_bloc/appbar_event.dart';
import 'appbar_bloc/appbar_state.dart';
import 'bottom_navbar_bloc/bottom_navbar_bloc.dart';
import 'bottom_navbar_bloc/bottom_navbar_event.dart';
import 'bottom_navbar_bloc/bottom_navbar_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'menudef/menudef_widget.dart';

typedef BlocProvider BlocProviderProvider(Widget child);

void openBottomNavBar(
  BuildContext context,
  HomeMenuModel model,
  CanRefresh? canRefresh, {
  double? fraction,
}) {
  openFlexibleDialog(context,
      includeHeading: false,
      widthFraction: fraction,
      child: BottomNavBarCreateWidget.getIt(
        context,
        canRefresh,
        model,
        fullScreenWidth(context) * ((fraction == null) ? 1 : fraction),
        fullScreenHeight(context) - 100,
      ),
      );
}

class BottomNavBarCreateWidget extends StatefulWidget {
  final double widgetWidth;
  final double widgetHeight;

  BottomNavBarCreateWidget._({
    Key? key,
    required this.widgetWidth,
    required this.widgetHeight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BottomNavBarCreateWidgetState();
  }

  static Widget getIt(BuildContext context, CanRefresh? canRefresh,
      HomeMenuModel homeMenuModel, double widgetWidth, double widgetHeight) {
    var app = AccessBloc.app(context);
    return BlocProvider<BottomNavBarCreateBloc>(
      create: (context) =>
          BottomNavBarCreateBloc(app!.documentID!, homeMenuModel, canRefresh)
            ..add(BottomNavBarCreateEventValidateEvent(homeMenuModel)),
      child: BottomNavBarCreateWidget._(
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
              HeaderWidget(
                cancelAction: () async {
                  BlocProvider.of<BottomNavBarCreateBloc>(context)
                      .add(BottomNavBarCreateEventRevertChanges());
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
              divider(context),
              MenuDefCreateWidget.getIt(
                context,
                state.homeMenuModel
                    .menu!, /*widget.widgetWidth, widget.widgetHeight - 50*/
              )
            ]));
      } else {
        return progressIndicator(context);
      }
    });
  }
}
