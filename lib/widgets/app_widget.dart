import 'package:eliud_core/core/access/bloc/access_bloc.dart';
import 'package:eliud_core/decoration/decoration.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/app_policy_item_model.dart';
import 'package:eliud_core/model/conditions_simple_model.dart';
import 'package:eliud_core/model/platform_medium_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/style/frontend/has_dialog_field.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_core/tools/storage/platform_medium_helper.dart';
import 'package:eliud_core/tools/storage/public_medium_helper.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'package:eliud_pkg_create/widgets/page_widget.dart';
import 'package:eliud_pkg_create/widgets/utils/combobox_widget.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:eliud_pkg_etc/widgets/decorator/can_refresh.dart';
import 'package:eliud_pkg_medium/platform/access_rights.dart';
import 'package:eliud_pkg_medium/platform/medium_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'app_bloc/app_bloc.dart';
import 'app_bloc/app_event.dart';
import 'app_bloc/app_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'appbar_widget.dart';
import 'bottom_nav_bar_widget.dart';
import 'dialog_widget.dart';
import 'drawer_widget.dart';
import 'package:file_picker/file_picker.dart';

import 'logo_widget.dart';

typedef BlocProvider BlocProviderProvider(Widget child);

void openApp(
  BuildContext context,
  CanRefresh? canRefresh, {
  double? fraction,
}) {
  openFlexibleDialog(context,
      includeHeading: false,
      widthFraction: fraction,
      child: AppCreateWidget.getIt(
        context,
        false,
        canRefresh,
        fullScreenWidth(context) * ((fraction == null) ? 1 : fraction),
        fullScreenHeight(context) - 100,
      ),
      );
}

class AppCreateWidget extends StatefulWidget {
  final bool create;
  final double widgetWidth;
  final double widgetHeight;

  AppCreateWidget._({
    Key? key,
    required this.create,
    required this.widgetWidth,
    required this.widgetHeight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AppCreateWidgetState();
  }

  static Widget getIt(BuildContext context, bool create, CanRefresh? canRefresh,
      double widgetWidth, double widgetHeight) {
    var app = AccessBloc.app(context);
    return BlocProvider<AppCreateBloc>(
      create: (context) => AppCreateBloc(app!.documentID!, app, canRefresh)
        ..add(AppCreateEventValidateEvent(app)),
      child: AppCreateWidget._(
        create: create,
        widgetWidth: widgetWidth,
        widgetHeight: widgetHeight,
      ),
    );
  }
}

class _AppCreateWidgetState extends State<AppCreateWidget> {
  double? _progress;
  double? _progressPolicy;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCreateBloc, AppCreateState>(
        builder: (context, state) {
      if (state is AppCreateValidated) {
        return ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
          HeaderWidget(
            cancelAction: () async {
              BlocProvider.of<AppCreateBloc>(context)
                  .add(AppCreateEventRevertChanges());
              return true;
            },
            okAction: () async {
              BlocProvider.of<AppCreateBloc>(context)
                  .add(AppCreateEventApplyChanges(true));
              return true;
            },
            title: 'App',
          ),
          divider(context),
          _general(context, state.appModel, widget.create),
          LogoWidget(appModel: state.appModel, collapsed: true),
          topicContainer(context,
              title: 'Home pages',
              collapsible: true,
              collapsed: true,
              children: [
                getListTile(context,
                    title: text(context, 'Public'),
                    trailing: text(context,
                        state.appModel.homePages!.homePagePublic ?? '')),
                getListTile(context,
                    title: text(context, 'Subscribed'),
                    trailing: text(
                        context,
                        state.appModel.homePages!.homePageSubscribedMember ??
                            '')),
                getListTile(context,
                    title: text(context, 'Level 1'),
                    trailing: text(context,
                        state.appModel.homePages!.homePageLevel1Member ?? '')),
                getListTile(context,
                    title: text(context, 'Level 2'),
                    trailing: text(context,
                        state.appModel.homePages!.homePageLevel2Member ?? '')),
                getListTile(context,
                    title: text(context, 'Blocked'),
                    trailing: text(context,
                        state.appModel.homePages!.homePageBlockedMember ?? '')),
                getListTile(context,
                    title: text(context, 'Owner'),
                    trailing: text(context,
                        state.appModel.homePages!.homePageOwner ?? '')),
              ]),
          topicContainer(context,
              title: 'Pages',
              collapsible: true,
              collapsed: true,
              children: [
                Container(
                  child: ListView(children: [
                    Container(
                        height: 200, //heightUnit() * 1,
                        width: widget.widgetWidth,
                        child: ListView(
                            children: state.pages.map((item) {
                          return getListTile(context,
                              onTap: () => openPage(
                                    context,
                                    false,
                                    item!,
                                    "Update page",
                                  ),
                              trailing: PopupMenuButton<int>(
                                  child: Icon(Icons.more_vert),
                                  elevation: 10,
                                  itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 0,
                                          child: text(context, 'Details'),
                                        ),
                                        PopupMenuDivider(),
                                        PopupMenuItem(
                                          value: 1,
                                          child: text(context,
                                              'Set as public homepage'),
                                        ),
                                        PopupMenuItem(
                                          value: 2,
                                          child: text(context,
                                              'Set as homepage for subscribed member'),
                                        ),
                                        PopupMenuItem(
                                          value: 3,
                                          child: text(context,
                                              'Set as homepage for suscribed member, level 1'),
                                        ),
                                        PopupMenuItem(
                                          value: 4,
                                          child: text(context,
                                              'Set as homepage for suscribed member, level 2'),
                                        ),
                                        PopupMenuItem(
                                          value: 5,
                                          child: text(context,
                                              'Set as homepage for blocked member'),
                                        ),
                                        PopupMenuItem(
                                          value: 6,
                                          child: text(context,
                                              'Set as homepage for owner'),
                                        ),
                                      ],
                                  onSelected: (value) {
                                    switch (value) {
                                      case 0:
                                        openPage(
                                          context,
                                          false,
                                          item!,
                                          "Update page",
                                        );
                                        break;
                                      case 1:
                                        setState(() => state.appModel.homePages!
                                            .homePagePublic = item!.documentID);
                                        break;
                                      case 2:
                                        setState(() => state.appModel.homePages!
                                                .homePageSubscribedMember =
                                            item!.documentID);
                                        break;
                                      case 3:
                                        setState(() => state.appModel.homePages!
                                                .homePageLevel1Member =
                                            item!.documentID);
                                        break;
                                      case 4:
                                        setState(() => state.appModel.homePages!
                                                .homePageLevel2Member =
                                            item!.documentID);
                                        break;
                                      case 5:
                                        setState(() => state.appModel.homePages!
                                                .homePageBlockedMember =
                                            item!.documentID);
                                        break;
                                      case 6:
                                        setState(() => state.appModel.homePages!
                                            .homePageOwner = item!.documentID);
                                        break;
                                    }
                                  }),
                              title: text(
                                  context, item != null ? item.title! : '?'));
                        }).toList())),
                    divider(context),
                    GestureDetector(
                        child: Icon(Icons.add),
                        onTap: () {
                          openPage(
                              context,
                              true,
                              newPageDefaults(AccessBloc.appId(context)!),
                              'Create page');
                        })
                  ], shrinkWrap: true, physics: ScrollPhysics()),
                ),
              ]),
          topicContainer(context,
              title: 'Dialogs',
              collapsible: true,
              collapsed: true,
              children: [
                Container(
                  child: ListView(children: [
                    Container(
                        height: 200, //heightUnit() * 1,
                        width: widget.widgetWidth,
                        child: ListView(
                            children: state.dialogs.map((item) {
                          return getListTile(context,
                              onTap: () => openDialog(
                                    context,
                                    false,
                                    item!,
                                    "Update dialog",
                                  ),
                              trailing: PopupMenuButton<int>(
                                  child: Icon(Icons.more_vert),
                                  elevation: 10,
                                  itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 0,
                                          child: text(context, 'Details'),
                                        ),
                                      ],
                                  onSelected: (value) {
                                    if (value == 0) {
                                      openDialog(
                                        context,
                                        false,
                                        item!,
                                        "Update dialog",
                                      );
                                    }
                                  }),
                              title: text(
                                  context, item != null ? item.title! : '?'));
                        }).toList())),
                    divider(context),
                    GestureDetector(
                        child: Icon(Icons.add),
                        onTap: () {
                          openDialog(
                              context,
                              true,
                              newDialogDefaults(AccessBloc.appId(context)!),
                              'Create page');
                        })
                  ], shrinkWrap: true, physics: ScrollPhysics()),
                ),
              ]),
          topicContainer(context,
              title: 'Policies',
              collapsible: true,
              collapsed: true,
              children: [
                getListTile(context,
                    leading: Icon(Icons.description),
                    title: dialogField(
                      context,
                      initialValue: state.appModel.policies!.comments,
                      valueChanged: (value) {
                        state.appModel.policies!.comments = value;
                      },
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Comments',
                        labelText: 'Comments',
                      ),
                    )),
                Container(
                  child: ListView(children: [
                    Container(
                        height: 200, //heightUnit() * 1,
                        width: widget.widgetWidth,
                        child: ListView(
                            children:
                                state.appModel.policies!.policies!.map((item) {
                          return getListTile(context,
                              trailing: PopupMenuButton<int>(
                                  child: Icon(Icons.more_vert),
                                  elevation: 10,
                                  itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 0,
                                          child: text(context, 'Delete'),
                                        ),
                                        PopupMenuItem(
                                          value: 1,
                                          child: text(context, 'Rename'),
                                        ),
                                      ],
                                  onSelected: (value) {
                                    if (value == 0) {
                                      setState(() {
                                        state.appModel.policies!.policies!
                                            .remove(item);
                                      });
                                    } else if (value == 1) {
                                      openEntryDialog(context,
                                          title: 'Provide new name for policy',
                                          hintText: 'Policy name',
                                          initialValue: item.name ?? '',
                                          ackButtonLabel: 'Rename',
                                          nackButtonLabel: 'Cancel',
                                          onPressed: (newName) {
                                        if (newName != null) {
                                          setState(() {
                                            item.name = newName;
                                          });
                                        }
                                      });
                                    }
                                  }),
                              title: text(
                                  context, item != null ? item.name! : '?'));
                        }).toList())),
                    divider(context),
                    _progressPolicy != null
                        ? Container(
                            height: 50,
                            child: progressIndicatorWithValue(context,
                                value: _progressPolicy!))
                        : GestureDetector(
                            child: Icon(Icons.add),
                            onTap: () async {
                              var _result = await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['pdf'],
                                  allowMultiple: false);
                              if ((_result != null) && (_result.count > 0)) {
                                var path = _result.files[0].path;
                                if (path != null) {
                                  var documentId = newRandomKey();
                                  await PublicMediumHelper(
                                          state.appModel.documentID!,
                                          state.appModel.ownerID!,)
                                      .createThumbnailUploadPdfFile(
                                          documentId, path, documentId,
                                          feedbackFunction: (pdf) =>
                                              _pdfFeedbackFunction(
                                                  state.appModel, pdf),
                                          feedbackProgress: _policyUploading);
                                }
                              }
                            })
                  ], shrinkWrap: true, physics: ScrollPhysics()),
                ),
              ]),
/*
          topicContainer(context,
                title: 'Page Transition Animation',
              collapsible: true,
              collapsed: true,
              children: [
                getListTile(
                  context,
                  leading: Icon(Icons.security),
                  title: ComboboxWidget(
                    initialValue: (state.appModel.routeBuilder == null)
                        ? 0
                        : state.appModel.routeBuilder!.index,
                    options: [
                      'Slide right to left',
                      'Slide bottom to top',
                      'Scale',
                      'Rotate',
                      'Fade',
                    ],
                    feedback: (value) =>
                        state.appModel.routeBuilder = toPageTransitionAnimation(value),
                    title: "Page transition animation",
                  ),
                )
              ]),
*/
          topicContainer(context,
              title: 'Navigation',
              collapsible: true,
              collapsed: true,
              children: [
                Container(
                    height: 50,
                    width: widget.widgetWidth,
                    child: Row(children: [
                      Spacer(),
                      button(context,
                          label: 'Left drawer',
                          onPressed: () => openDrawer(
                              context,
                              state.leftDrawerModel,
                              DecorationDrawerType.Left,
                              null,
                              1)),
                      Spacer(),
                      button(context,
                          label: 'App Bar',
                          onPressed: () =>
                              openAppBar(context, state.appBarModel, null)),
                      Spacer(),
                      button(context,
                          label: 'Right drawer',
                          onPressed: () => openDrawer(
                              context,
                              state.rightDrawerModel,
                              DecorationDrawerType.Right,
                              null,
                              1)),
                      Spacer(),
                      button(context,
                          label: 'Bottom navbar',
                          onPressed: () => openBottomNavBar(
                              context, state.homeMenuModel, null)),
                      Spacer(),
                    ]))
              ]),
        ]);
      } else {
        return progressIndicator(context);
      }
    });
  }

  Widget _general(BuildContext context, AppModel app, bool create) {
    return topicContainer(context,
        title: 'General',
        collapsible: true,
        collapsed: true,
        children: [
          getListTile(context,
              leading: Icon(Icons.vpn_key),
              title: create
                  ? dialogField(
                      context,
                      initialValue: app.documentID,
                      valueChanged: (value) {
                        app.documentID = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Identifier',
                        labelText: 'Identifier',
                      ),
                    )
                  : text(context, app.documentID!)),
          getListTile(context,
              leading: Icon(Icons.description),
              title: dialogField(
                context,
                initialValue: app.title,
                valueChanged: (value) {
                  app.title = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Title',
                  labelText: 'Title',
                ),
              )),
          getListTile(context,
              leading: Icon(Icons.description),
              title: dialogField(
                context,
                initialValue: app.description,
                valueChanged: (value) {
                  app.description = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Description',
                  labelText: 'Description',
                ),
              )),
          getListTile(context,
              leading: Icon(Icons.email),
              title: dialogField(
                context,
                initialValue: app.email,
                valueChanged: (value) {
                  app.title = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Email',
                  labelText: 'Email',
                ),
              )),
        ]);
  }

  void _pdfFeedbackFunction(
      AppModel appModel, PlatformMediumModel? platformMediumModel) {
    setState(() {
      _progressPolicy = null;
      appModel.policies!.policies!.add(AppPolicyItemModel(
          documentID: newRandomKey(),
          name: platformMediumModel!.baseName,
          policy: platformMediumModel));
    });
  }

  void _policyUploading(double? progress) {
    if (progress != null) {}
    setState(() {
      _progressPolicy = progress;
    });
  }
}
