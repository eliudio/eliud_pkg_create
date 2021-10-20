import 'package:eliud_core/core/access/bloc/access_bloc.dart';
import 'package:eliud_core/core/access/bloc/access_event.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/style/frontend/has_dialog_field.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/new_app_bloc.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/new_app_event.dart';
import 'package:eliud_pkg_create/widgets/style_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'logo_widget.dart';
import 'new_app_bloc/new_app_state.dart';

typedef BlocProvider BlocProviderProvider(Widget child);

void newApp(
  BuildContext context, {
  double? fraction,
}) {
  openFlexibleDialog(context,
      includeHeading: false,
      widthFraction: fraction == null ? .5 : fraction,
      child: Container(
          width: 10,
          child: NewAppCreateWidget.getIt(
            context,
            fullScreenWidth(context) * ((fraction == null) ? .5 : fraction),
            fullScreenHeight(context) - 100,
          )),
      );
}

class NewAppCreateWidget extends StatefulWidget {
  final double widgetWidth;
  final double widgetHeight;

  NewAppCreateWidget._({
    Key? key,
    required this.widgetWidth,
    required this.widgetHeight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NewAppCreateWidgetState();
  }

  static Widget getIt(
      BuildContext context, double widgetWidth, double widgetHeight) {
    var member = AccessBloc.member(context);
    if (member != null) {
      return BlocProvider<NewAppCreateBloc>(
        create: (context) => NewAppCreateBloc()
          ..add(NewAppCreateEventInitialise('YOUR_APP_ID', member)),
        child: NewAppCreateWidget._(
          widgetWidth: widgetWidth,
          widgetHeight: widgetHeight,
        ),
      );
    } else {
      return text(context, "Member should be logged on");
    }
  }
}

class _NewAppCreateWidgetState extends State<NewAppCreateWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewAppCreateBloc, NewAppCreateState>(
        builder: (context, state) {
      if (state is SwitchApp) {
        BlocProvider.of<AccessBloc>(context)
            .add(SwitchAppEvent(state.appToBeCreated.documentID));
      } else if (state is NewAppCreateInitialised) {
        return Container(
            width: widget.widgetWidth,
            child:
                ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
              HeaderWidget(
                cancelAction: () async {
                  if (state is NewAppCreateCreateInProgress) {
                    BlocProvider.of<NewAppCreateBloc>(context)
                        .add(NewAppCancelled());
                    return false;
                  } else {
                    return true;
                  }
                },
                okAction: (state is NewAppCreateAllowEnterDetails)
                    ? () async {
                        BlocProvider.of<NewAppCreateBloc>(context)
                            .add(NewAppCreateConfirm(
                          logo: state.appToBeCreated.logo,
                          includeWelcome: true,
                          includeShop: true,
                          includeChat: true,
                          includeFeed: true,
                          includeMemberDashboard: true,
                          includeExamplePolicy: true,
                          includeSignoutButton: true,
                          includeFlushButton: true,
                        ));
                        return false;
                      }
                    : null,
                title: 'Create new App',
              ),
              divider(context),
              _contents(context, state),
                  _logo(state.appToBeCreated),
                  StyleSelectionWidget.getIt(context, state.appToBeCreated, false, true),
            ]));
      }
      return progressIndicator(context);
    });
  }

  Widget _logo(AppModel appModel) {
    return LogoWidget(appModel: appModel, collapsed: false);
  }

  Widget _contents(BuildContext context, NewAppCreateInitialised state) {
    if (state is NewAppCreateAllowEnterDetails) {
      return topicContainer(context,
          width: widget.widgetWidth,
          title: 'General',
          collapsible: true,
          collapsed: false,
          children: [
            getListTile(context,
                leading: Icon(Icons.vpn_key),
                title: dialogField(
                  context,
                  initialValue: state.appToBeCreated.documentID,
                  valueChanged: (value) {
                    state.appToBeCreated.documentID = value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Identifier',
                    labelText: 'Identifier',
                  ),
                ))
          ]);
    } else if (state is NewAppCreateCreateInProgress) {
      return Container(
          height: 100,
          width: widget.widgetWidth,
          child: progressIndicatorWithValue(context, value: state.progress));
    } else {
      return text(context, 'no contents');
    }
  }
}
