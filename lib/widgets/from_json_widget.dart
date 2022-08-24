import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/core/blocs/access/state/logged_in.dart';
import 'package:eliud_core/model/member_medium_model.dart';
import 'package:eliud_pkg_create/widgets/utils/models_json_destination_widget.dart';
import 'package:eliud_pkg_create/widgets/utils/models_json_select_membermedium.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'from_json_bloc/from_json_bloc.dart';
import 'from_json_bloc/from_json_event.dart';
import 'from_json_bloc/from_json_state.dart';

typedef BlocProvider BlocProviderProvider(Widget child);

void newFromJson(
  BuildContext context,
  MemberModel member,
  AppModel app, {
  double? fraction,
}) {
  openFlexibleDialog(
    app,
    context,
    app.documentID + '/_fromjson',
    includeHeading: false,
    widthFraction: fraction == null ? .5 : fraction,
    child: Container(
        width: 10,
        child: NewFromJsonCreateWidget.getIt(
          context,
          member,
          app,
          fullScreenWidth(context) * ((fraction == null) ? .5 : fraction),
          fullScreenHeight(context) - 100,
        )),
  );
}

class NewFromJsonCreateWidget extends StatefulWidget {
  final AppModel app;
  final double widgetWidth;
  final double widgetHeight;

  NewFromJsonCreateWidget._({
    Key? key,
    required this.app,
    required this.widgetWidth,
    required this.widgetHeight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NewFromJsonCreateWidgetState();
  }

  static Widget getIt(BuildContext context, MemberModel member, AppModel app,
      double widgetWidth, double widgetHeight) {
    return BlocProvider<FromJsonBloc>(
      create: (context) => FromJsonBloc(
        app,
        member,
      )..add(FromJsonInitialise()),
      child: NewFromJsonCreateWidget._(
        app: app,
        widgetWidth: widgetWidth,
        widgetHeight: widgetHeight,
      ),
    );
  }
}

class _NewFromJsonCreateWidgetState extends State<NewFromJsonCreateWidget> {
  JsonDestination? jsonDestination;
  MemberMediumModel? memberMediumModel;
  String? url;

  void initState() {
    jsonDestination = JsonDestination.MemberMedium;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var loggedInState = AccessBloc.getState(context);
    if (loggedInState is LoggedIn) {
      return BlocBuilder<FromJsonBloc, FromJsonState>(
          builder: (context, state) {
        if (state is FromJsonInitialised) {
          return Container(
              width: widget.widgetWidth,
              child: ListView(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  children: [
                    HeaderWidget(
                      app: widget.app,
                      cancelAction: () async {
                        return true;
                      },
                      okAction: () async {
                        if (jsonDestination == JsonDestination.MemberMedium) {
                          if (memberMediumModel != null) {
                            BlocProvider.of<FromJsonBloc>(context)
                                .add(NewFromJsonWithModel(
                              loggedInState,
                              memberMediumModel!,
                            ));
                          } else {
                            print("Should select a medium");
                          }
                        } else if (jsonDestination == JsonDestination.URL) {
                          if (memberMediumModel != null) {
                            BlocProvider.of<FromJsonBloc>(context)
                                .add(NewFromJsonWithUrl(
                              loggedInState,
                              url!,
                            ));
                          } else {
                            print("Should specify a URL");
                          }
                        } else {
                          BlocProvider.of<FromJsonBloc>(context)
                              .add(NewFromJsonWithClipboard());
                        }
                        return false;
                      },
                      title: 'Create new Page from existing Page',
                    ),
                    divider(widget.app, context),
                    topicContainer(widget.app, context,
                        title: 'Source',
                        collapsible: true,
                        collapsed: true,
                        children: [
                          JsonDestinationWidget(
                            app: widget.app,
                            jsonDestination:
                                jsonDestination ?? JsonDestination.MemberMedium,
                            jsonDestinationCallback: (JsonDestination val) {
                              setState(() {
                                jsonDestination = val;
                              });
                            },
                          ),
                          if (jsonDestination == JsonDestination.MemberMedium)
                            JsonMemberMediumWidget(
                                app: widget.app,
                                ext: 'page.json',
                                initialValue: memberMediumModel,
                                jsonMemberMediumCallback: (value) {
                                  setState(() {
                                    memberMediumModel = value;
                                  });
                                }),
                          if (jsonDestination == JsonDestination.URL)
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
                  ]));
        } else {
          return progressIndicator(widget.app, context);
        }
      });
    } else {
      return text(
          widget.app, context, 'You need to be logged in to create a new app');
    }
  }

/*  Widget _progress(NewAppCreateCreateInProgress state) {
    return Container(
        height: 100,
        width: widget.widgetWidth,
        child: progressIndicatorWithValue(widget.app, context,
            value: state.progress));
  }*/
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
