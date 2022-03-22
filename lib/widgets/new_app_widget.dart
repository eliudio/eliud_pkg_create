import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/blocs/access/access_event.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/style/frontend/has_dialog_field.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/new_app_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'new_app_bloc/new_app_bloc.dart';
import 'new_app_bloc/new_app_state.dart';

typedef BlocProvider BlocProviderProvider(Widget child);

void newApp(
  BuildContext context,
  MemberModel member,
  AppModel app, {
  double? fraction,
}) {
  openFlexibleDialog(
    app,
    context,
    app.documentID! + '/_newapp',
    includeHeading: false,
    widthFraction: fraction == null ? .5 : fraction,
    child: Container(
        width: 10,
        child: NewAppCreateWidget.getIt(
          context,
          member,
          app,
          fullScreenWidth(context) * ((fraction == null) ? .5 : fraction),
          fullScreenHeight(context) - 100,
        )),
  );
}

class NewAppCreateWidget extends StatefulWidget {
  final AppModel app;
  final double widgetWidth;
  final double widgetHeight;

  NewAppCreateWidget._({
    Key? key,
    required this.app,
    required this.widgetWidth,
    required this.widgetHeight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NewAppCreateWidgetState();
  }

  static Widget getIt(BuildContext context, MemberModel member, AppModel app,
      double widgetWidth, double widgetHeight) {
    return BlocProvider<NewAppCreateBloc>(
      create: (context) => NewAppCreateBloc()
        ..add(NewAppCreateEventInitialise('YOUR_APP_ID', member)),
      child: NewAppCreateWidget._(
        app: app,
        widgetWidth: widgetWidth,
        widgetHeight: widgetHeight,
      ),
    );
  }
}

class _NewAppCreateWidgetState extends State<NewAppCreateWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewAppCreateBloc, NewAppCreateState>(
        builder: (context, state) {
      if (state is SwitchApp) {
        BlocProvider.of<AccessBloc>(context).add(SwitchAppWithIDEvent(
            appId: state.appToBeCreated.documentID!, goHome: true));
      } else if (state is NewAppCreateInitialised) {
        return Container(
            width: widget.widgetWidth,
            child:
                ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
              HeaderWidget(
                app: widget.app,
                cancelAction: () async {
                  if (state is NewAppCreateCreateInProgress) {
                    BlocProvider.of<NewAppCreateBloc>(context)
                        .add(NewAppCancelled());
                    return false;
                  } else {
                    return true;
                  }
                },
                okAction: ((state is NewAppCreateAllowEnterDetails) || (state is NewAppCreateError))
                    ? () async {
                        BlocProvider.of<NewAppCreateBloc>(context)
                            .add(NewAppCreateConfirm(
                        ));
                        return false;
                      }
                    : null,
                title: 'Create new App',
              ),
              if (state is NewAppCreateError) text(widget.app, context, state.error),
              if ((state is NewAppCreateAllowEnterDetails) || (state is NewAppCreateError)) enterDetails(state),
              if (state is NewAppCreateCreateInProgress) _progress(state),
            ]));
      }
      return progressIndicator(widget.app, context);
    });
  }

  Widget enterDetails(NewAppCreateInitialised state) {
    return ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
      divider(widget.app, context),
      getListTile(context, widget.app,
          leading: Icon(Icons.vpn_key),
          title: dialogField(
            widget.app,
            context,
            initialValue: state.appToBeCreated.documentID,
            inputFormatters: [
              UpperCaseTextFormatter(),
            ],
            valueChanged: (value) {
                state.appToBeCreated.documentID = value.toUpperCase();
/*
                setState(() {
              });
*/
            },
            decoration: const InputDecoration(
              hintText: 'Identifier',
              labelText: 'Identifier',
            ),
          )),
    ]);
  }

  Widget _progress(NewAppCreateCreateInProgress state) {
    return Container(
        height: 100,
        width: widget.widgetWidth,
        child: progressIndicatorWithValue(widget.app, context,
            value: state.progress));
  }

}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
