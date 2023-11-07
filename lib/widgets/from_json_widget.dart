import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/blocs/access/access_event.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/core/blocs/access/state/logged_in.dart';
import 'package:eliud_core/model/member_medium_model.dart';
import 'package:eliud_pkg_create/widgets/utils/models_json_destination_widget.dart';
import 'package:eliud_pkg_create/widgets/utils/models_json_select_membermedium.dart';
import 'package:flutter/services.dart';
import '../jsontomodeltojson/jsonconst.dart';
import 'from_json_bloc/from_json_bloc.dart';
import 'from_json_bloc/from_json_event.dart';
import 'from_json_bloc/from_json_state.dart';

typedef BlocProviderProvider = BlocProvider Function(Widget child);

void newFromJson(
  BuildContext context,
  MemberModel member,
  AppModel app, {
  double? fraction,
}) {
  openFlexibleDialog(
    app,
    context,
    '${app.documentID}/_fromjson',
    includeHeading: false,
    widthFraction: fraction ?? .5,
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
    required this.app,
    required this.widgetWidth,
    required this.widgetHeight,
  });

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
  bool _includeMedia = false;
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
                        if (state is FromJsonProgress) {
                          BlocProvider.of<FromJsonBloc>(context)
                              .add(NewFromJsonCancelAction());
                        }
                        return true;
                      },
                      okAction: () async {
                        if (jsonDestination == JsonDestination.memberMedium) {
                          if (memberMediumModel != null) {
                            BlocProvider.of<FromJsonBloc>(context)
                                .add(NewFromJsonWithModel(
                              loggedInState,
                              memberMediumModel!,
                              _includeMedia,
                              (key, documentId) {
                                postCreationAction(key, documentId);
                              },
                            ));
                          } else {
                            print("Should select a medium");
                          }
                        } else if (jsonDestination == JsonDestination.url) {
                          if (memberMediumModel != null) {
                            BlocProvider.of<FromJsonBloc>(context)
                                .add(NewFromJsonWithUrl(
                              loggedInState,
                              url!,
                              _includeMedia,
                              (key, documentId) {
                                postCreationAction(key, documentId);
                              },
                            ));
                          } else {
                            print("Should specify a URL");
                          }
                        } else {
                          BlocProvider.of<FromJsonBloc>(context)
                              .add(NewFromJsonWithClipboard(
                            _includeMedia,
                            (key, documentId) {
                              postCreationAction(key, documentId);
                            },
                          ));
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
                                jsonDestination ?? JsonDestination.memberMedium,
                            jsonDestinationCallback: (JsonDestination val) {
                              setState(() {
                                jsonDestination = val;
                              });
                            },
                          ),
                          if (jsonDestination == JsonDestination.memberMedium)
                            JsonMemberMediumWidget(
                                app: widget.app,
                                ext: 'page.json',
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
                    topicContainer(widget.app, context,
                        title: 'Include Media',
                        collapsible: true,
                        collapsed: true,
                        children: [
                          text(
                            widget.app,
                            context,
                            "Also re-upload the media referenced by this page in the json or reference the same image as the one being created?",
                            maxLines: 10,
                          ),
                          checkboxListTile(widget.app, context, 'Create media',
                              _includeMedia, (value) {
                            setState(() {
                              _includeMedia = value!;
                            });
                          }),
                        ]),
                  ]));
        } else if (state is FromJsonProgress) {
          return Container(
              height: 100,
              width: widget.widgetWidth,
              child: progressIndicatorWithValue(widget.app, context,
                  value: state.progress));
        } else {
          return progressIndicator(widget.app, context);
        }
      });
    } else {
      return text(
          widget.app, context, 'You need to be logged in to create a new app');
    }
  }

  void postCreationAction(String? key, String? documentId) {
    Navigator.of(context).pop(); // close this popup first
    if (documentId != null) {
      if (key == JsonConsts.pages) {
        BlocProvider.of<AccessBloc>(context).add(GotoPageEvent(
          widget.app,
          documentId,
        ));
      }
      if (key == JsonConsts.dialogs) {
        BlocProvider.of<AccessBloc>(context).add(OpenDialogEvent(documentId));
      }
    }
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
