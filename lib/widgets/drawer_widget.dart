import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/blocs/access/state/access_determined.dart';
import 'package:eliud_core/core/blocs/access/state/access_state.dart';
import 'package:eliud_core/core/registry.dart';
import 'package:eliud_core/decoration/decoration.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/background_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/model/storage_conditions_model.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/style/frontend/has_dialog_field.dart';
import 'package:eliud_core/style/frontend/has_drawer.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_core/tools/widgets/background_widget.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:eliud_pkg_create/widgets/utils/styles.dart';
import 'package:eliud_core/package/access_rights.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'drawer_bloc/drawer_bloc.dart';
import 'drawer_bloc/drawer_event.dart';
import 'drawer_bloc/drawer_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'menudef/menudef_widget.dart';

typedef BlocProvider BlocProviderProvider(Widget child);

void openDrawer(BuildContext context, AppModel app, DrawerModel model,
    DecorationDrawerType decorationDrawerType, double fraction) {
  openFlexibleDialog(
    app,
    context,
    app.documentID + '/_drawer',
    includeHeading: false,
    widthFraction: fraction,
    child: DrawerCreateWidget.getIt(
      context,
      app,
      decorationDrawerType == DecorationDrawerType.Left
          ? DrawerType.Left
          : DrawerType.Right,
      model,
      fullScreenWidth(context) * (fraction ?? .9),
      fullScreenHeight(context) - 100,
    ),
  );
}

enum DisplayCase {
  ShowProgress,
  ShowMemberProfilePhoto,
  ShowUrlPhoto,
  AllowNewEntry
}

class DrawerCreateWidget extends StatefulWidget {
  final double widgetWidth;
  final double widgetHeight;
  final AppModel app;

  DrawerCreateWidget._({
    Key? key,
    required this.app,
    required this.widgetWidth,
    required this.widgetHeight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DrawerCreateWidgetState();
  }

  static Widget getIt(BuildContext context, AppModel app, DrawerType drawerType,
      DrawerModel appBarModel, double widgetWidth, double widgetHeight) {
    return BlocProvider<DrawerCreateBloc>(
      create: (context) => DrawerCreateBloc(
        app.documentID,
        drawerType,
        appBarModel,
      )..add(DrawerCreateEventValidateEvent(appBarModel)),
      child: DrawerCreateWidget._(
        app: app,
        widgetWidth: widgetWidth,
        widgetHeight: widgetHeight,
      ),
    );
  }
}

class _DrawerCreateWidgetState extends State<DrawerCreateWidget> {
  double? _progress;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccessBloc, AccessState>(
        builder: (context, accessState) {
      if (accessState is AccessDetermined) {
        if (accessState.getMember() != null) {
          var memberId = accessState.getMember()!.documentID;
          return BlocBuilder<DrawerCreateBloc, DrawerCreateState>(
              builder: (context, state) {
            if (state is DrawerCreateValidated) {
              return ListView(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  children: [
                    HeaderWidget(
                      app: widget.app,
                      cancelAction: () async {
                        return true;
                      },
                      okAction: () async {
                        BlocProvider.of<DrawerCreateBloc>(context)
                            .add(DrawerCreateEventApplyChanges(true));
                        return true;
                      },
                      title: 'Update drawer',
                    ),
                    topicContainer(widget.app, context,
                        title: 'Header',
                        collapsible: true,
                        collapsed: true,
                        children: [
                          getListTile(
                            context,
                            widget.app,
                            leading: Icon(Icons.description),
                            title: dialogField(widget.app, context,
                                valueChanged: (value) =>
                                    state.drawerModel.headerText = value,
                                initialValue: state.drawerModel.headerText,
                                decoration: inputDecoration(
                                    widget.app, context, "Header text")),
                          ),
                          //_mediaButtons(context, state, widget.app, memberId),
                          getListTile(context, widget.app,
                              leading: Icon(Icons.description),
                              title: dialogField(
                                widget.app,
                                context,
                                keyboardType: TextInputType.multiline,
                                maxLines: 3,
                                valueChanged: (value) =>
                                    state.drawerModel.secondHeaderText = value,
                                initialValue:
                                    state.drawerModel.secondHeaderText,
                                decoration: inputDecoration(
                                  widget.app,
                                  context,
                                  'Second Header text',
                                ),
                              )),
                        ]),
                    topicContainer(widget.app, context,
                        title: 'Backgrounds',
                        collapsible: true,
                        collapsed: true,
                        children: [
                          topicContainer(widget.app, context,
                              title: 'Header Background override',
                              collapsible: true,
                              collapsed: true,
                              children: [
                                checkboxListTile(
                                    widget.app,
                                    context,
                                    'Header Background override?',
                                    state.drawerModel.headerBackgroundOverride !=
                                        null, (value) {
                                  setState(() {
                                    if (value!) {
                                      state.drawerModel.headerBackgroundOverride =
                                          BackgroundModel();
                                    } else {
                                      state.drawerModel.headerBackgroundOverride =
                                      null;
                                    }
                                  });
                                }),
                                if (state.drawerModel.headerBackgroundOverride !=
                                    null)
                                  BackgroundWidget(
                                      app: widget.app,
                                      memberId: memberId,
                                      value:
                                      state.drawerModel.headerBackgroundOverride!,
                                      label: 'Header Background'),
                              ]),
                          topicContainer(widget.app, context,
                              title: 'Background override',
                              collapsible: true,
                              collapsed: true,
                              children: [
                                checkboxListTile(
                                    widget.app,
                                    context,
                                    'Background override?',
                                    state.drawerModel.backgroundOverride !=
                                        null, (value) {
                                  setState(() {
                                    if (value!) {
                                      state.drawerModel.backgroundOverride =
                                          BackgroundModel();
                                    } else {
                                      state.drawerModel.backgroundOverride =
                                      null;
                                    }
                                  });
                                }),
                                if (state.drawerModel.backgroundOverride !=
                                    null)
                                  BackgroundWidget(
                                      app: widget.app,
                                      memberId: memberId,
                                      value:
                                      state.drawerModel.backgroundOverride!,
                                      label: 'Background'),
                              ]),
                        ]),
                    MenuDefCreateWidget.getIt(
                      context,
                      widget.app,
                      state.drawerModel
                          .menu!, /*widget.widgetWidth, max(widget.widgetHeight - 300, 200)*/
                    )
                  ]);
            } else {
              return progressIndicator(widget.app, context);
            }
          });
        } else {
          return text(widget.app, context, 'No member');
        }
      } else {
        return progressIndicator(widget.app, context);
      }
    });
  }
}
