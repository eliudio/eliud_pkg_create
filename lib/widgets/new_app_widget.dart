import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/blocs/access/access_event.dart';
import 'package:eliud_core/core/blocs/access/state/logged_in.dart';
import 'package:eliud_core_model/model/app_model.dart';
import 'package:eliud_core_model/model/member_medium_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core_model/style/frontend/has_container.dart';
import 'package:eliud_core_model/style/frontend/has_dialog.dart';
import 'package:eliud_core_model/style/frontend/has_dialog_field.dart';
import 'package:eliud_core_model/style/frontend/has_divider.dart';
import 'package:eliud_core_model/style/frontend/has_list_tile.dart';
import 'package:eliud_core_model/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core_model/style/frontend/has_text.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/new_app_event.dart';
import 'package:eliud_pkg_create/widgets/utils/models_json_destination_widget.dart';
import 'package:eliud_pkg_create/widgets/utils/models_json_select_membermedium.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'new_app_bloc/new_app_bloc.dart';
import 'new_app_bloc/new_app_state.dart';

typedef BlocProviderProvider = BlocProvider Function(Widget child);

void newApp(
  BuildContext context,
  MemberModel member,
  AppModel app, {
  double? fraction,
}) {
  openFlexibleDialog(
    app,
    context,
    '${app.documentID}/_newapp',
    includeHeading: false,
    widthFraction: fraction ?? .5,
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
    required this.app,
    required this.widgetWidth,
    required this.widgetHeight,
  });

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
  bool _fromExisting = false;
  JsonDestination? jsonDestination;
  MemberMediumModel? memberMediumModel;
  String? url;

  @override
  void initState() {
    jsonDestination = JsonDestination.memberMedium;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var loggedInState = AccessBloc.getState(context);
    if (loggedInState is LoggedIn) {
      return BlocBuilder<NewAppCreateBloc, NewAppCreateState>(
          builder: (context, state) {
        if (state is SwitchApp) {
          BlocProvider.of<AccessBloc>(context).add(SwitchAppWithIDEvent(
              appId: state.appToBeCreated.documentID, goHome: true));
        } else if (state is NewAppCreateInitialised) {
          return Container(
              width: widget.widgetWidth,
              child: ListView(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  children: [
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
                      okAction: ((state is NewAppCreateAllowEnterDetails) ||
                              (state is NewAppCreateError))
                          ? () async {
                              BlocProvider.of<NewAppCreateBloc>(context).add(
                                  NewAppCreateConfirm(
                                      _fromExisting,
                                      loggedInState,
                                      jsonDestination ==
                                              JsonDestination.memberMedium
                                          ? memberMediumModel
                                          : null,
                                      jsonDestination == JsonDestination.url
                                          ? url
                                          : null));
                              return false;
                            }
                          : null,
                      title: 'Create new App',
                    ),
                    divider(widget.app, context),
                    if (state is NewAppCreateError)
                      text(widget.app, context, state.error),
                    if ((state is NewAppCreateAllowEnterDetails) ||
                        (state is NewAppCreateError))
                      enterDetails(state),
                    if (((state is NewAppCreateAllowEnterDetails) ||
                            (state is NewAppCreateError)) &&
                        (_fromExisting))
                      topicContainer(widget.app, context,
                          title: 'Source',
                          collapsible: true,
                          collapsed: true,
                          children: [
                            JsonDestinationWidget(
                              app: widget.app,
                              jsonDestination: jsonDestination ??
                                  JsonDestination.memberMedium,
                              jsonDestinationCallback: (JsonDestination val) {
                                setState(() {
                                  jsonDestination = val;
                                });
                              },
                            ),
                            if (jsonDestination == JsonDestination.memberMedium)
                              JsonMemberMediumWidget(
                                  app: widget.app,
                                  ext: 'app.json',
                                  initialValue: memberMediumModel,
                                  jsonMemberMediumCallback: (value) {
                                    setState(() {
                                      memberMediumModel = value;
                                    });
                                  }),
                            if (jsonDestination == JsonDestination.url)
                              getListTile(context, widget.app,
                                  leading: Icon(Icons.description),
                                  title: dialogField(
                                    widget.app,
                                    context,
                                    initialValue: url,
                                    valueChanged: (value) {
                                      setState(() {
                                        url = value;
                                      });
                                    },
                                    maxLines: 1,
                                    decoration: const InputDecoration(
                                      hintText: 'URL',
                                      labelText: 'URL',
                                    ),
                                  )),
                          ]),
                    if (state is NewAppCreateCreateInProgress) _progress(state),
                  ]));
        }
        return progressIndicator(widget.app, context);
      });
    } else {
      return text(
          widget.app, context, 'You need to be logged in to create a new app');
    }
  }

  Widget enterDetails(NewAppCreateInitialised state) =>
      topicContainer(widget.app, context,
          title: 'Generic',
          collapsible: true,
          collapsed: true,
          children: [
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
                  },
                  decoration: const InputDecoration(
                    hintText: 'Identifier',
                    labelText: 'Identifier',
                  ),
                )),
            checkboxListTile(
              widget.app,
              context,
              'Create from existing app',
              _fromExisting,
              (value) {
                setState(() {
                  _fromExisting = value!;
                });
              },
            ),
          ]);

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
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
