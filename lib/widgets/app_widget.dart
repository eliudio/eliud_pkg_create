import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/registry.dart';
import 'package:eliud_core/decoration/decoration.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/app_policy_item_model.dart';
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
import 'package:eliud_core/tools/storage/public_medium_helper.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'package:eliud_pkg_create/widgets/page_widget.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
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

void openAppX(
  BuildContext context,
  AppModel app, {
  double? fraction,
}) {
  openFlexibleDialog(
    app,
    context,
    app.documentID! + '/_app',
    includeHeading: false,
    widthFraction: fraction,
    child: AppCreateWidget.getIt(
      context,
      app,
      false,
      fullScreenWidth(context) * ((fraction == null) ? 1 : fraction),
      fullScreenHeight(context) - 100,
    ),
  );
}

class AppCreateWidget extends StatefulWidget {
  final bool create;
  final double widgetWidth;
  final double widgetHeight;
  final AppModel app;

  AppCreateWidget._({
    Key? key,
    required this.app,
    required this.create,
    required this.widgetWidth,
    required this.widgetHeight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AppCreateWidgetState();
  }

  static Widget getIt(BuildContext context, AppModel app, bool create,
      double widgetWidth, double widgetHeight) {
    return BlocProvider<AppCreateBloc>(
      create: (context) => AppCreateBloc(app.documentID!, app)
        ..add(AppCreateEventValidateEvent(app)),
      child: AppCreateWidget._(
        app: app,
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
            app: widget.app,
            cancelAction: () async {
              return true;
            },
            okAction: () async {
              BlocProvider.of<AppCreateBloc>(context)
                  .add(AppCreateEventApplyChanges(true));
              return true;
            },
            title: 'App',
          ),
          divider(widget.app, context),
          _general(context, state.appModel, widget.create),
          LogoWidget(
              isCollapsable: true,
              app: state.appModel,
              logo: state.appModel.logo,
              logoFeedback: (newLogo) {
                setState(() {
                  state.appModel.logo = newLogo;
                });
              },
              collapsed: true),
          topicContainer(widget.app, context,
              title: 'Profile photo for members with not photo',
              collapsible: true,
              collapsed: true,
              children: [
                Registry.registry()!.getMediumApi().getPublicPhotoWidget(
                  context: context,
                  allowCrop: true,
                  defaultImage: 'packages/eliud_pkg_create/assets/rodentia-icons_preferences-desktop-personal.png',
                  feedbackFunction: (mediumModel) {
                    setState(() {
                      state.appModel.anonymousProfilePhoto = mediumModel;
                    });
                  },
                  app: widget.app,
                  initialImage: state.appModel.anonymousProfilePhoto ,
                ),
              ]),
          topicContainer(widget.app, context,
              title: 'Home pages',
              collapsible: true,
              collapsed: true,
              children: [
                getListTile(context, widget.app,
                    title: text(widget.app, context, 'Public'),
                    trailing: text(widget.app, context,
                        state.appModel.homePages!.homePagePublic ?? '')),
                getListTile(context, widget.app,
                    title: text(widget.app, context, 'Subscribed'),
                    trailing: text(
                        widget.app,
                        context,
                        state.appModel.homePages!.homePageSubscribedMember ??
                            '')),
                getListTile(context, widget.app,
                    title: text(widget.app, context, 'Level 1'),
                    trailing: text(widget.app, context,
                        state.appModel.homePages!.homePageLevel1Member ?? '')),
                getListTile(context, widget.app,
                    title: text(widget.app, context, 'Level 2'),
                    trailing: text(widget.app, context,
                        state.appModel.homePages!.homePageLevel2Member ?? '')),
                getListTile(context, widget.app,
                    title: text(widget.app, context, 'Blocked'),
                    trailing: text(widget.app, context,
                        state.appModel.homePages!.homePageBlockedMember ?? '')),
                getListTile(context, widget.app,
                    title: text(widget.app, context, 'Owner'),
                    trailing: text(widget.app, context,
                        state.appModel.homePages!.homePageOwner ?? '')),
              ]),
          topicContainer(widget.app, context,
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
                          return getListTile(context, widget.app,
                              onTap: () => openPage(
                                    context,
                                    widget.app,
                                    false,
                                    item!,
                                    "Update page",
                                  ),
                              trailing: popupMenuButton<int>(
                                widget.app, context,
                                  child: Icon(Icons.more_vert),
                                  itemBuilder: (context) => [
                                        popupMenuItem(
                                          widget.app, context,
                                          value: 0,
                                          label: 'Details',
                                        ),
                                        popupMenuDivider(widget.app, context),
                                        popupMenuItem(
                                          widget.app, context,
                                          value: 1,
                                          label: 'Set as public homepage',
                                        ),
                                        popupMenuItem(
                                          widget.app, context,
                                          value: 2,
                                          label: 'Set as homepage for subscribed member',
                                        ),
                                        popupMenuItem(
                                          widget.app, context,
                                          value: 3,
                                          label: 'Set as homepage for suscribed member, level 1',
                                        ),
                                        popupMenuItem(
                                          widget.app, context,
                                          value: 4,
                                          label: 'Set as homepage for suscribed member, level 2',
                                        ),
                                        popupMenuItem(
                                          widget.app, context,
                                          value: 5,
                                          label: 'Set as homepage for blocked member',
                                        ),
                                        popupMenuItem(
                                          widget.app, context,
                                          value: 6,
                                          label: 'Set as homepage for owner',
                                        ),
                                      ],
                                  onSelected: (value) {
                                    switch (value) {
                                      case 0:
                                        openPage(
                                          context,
                                          widget.app,
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
                                  widget.app,
                                  context,
                                  ((item != null) && (item.title != null))
                                      ? item.title!
                                      : '?'));
                        }).toList())),
                    divider(widget.app, context),
                    GestureDetector(
                        child: Icon(Icons.add),
                        onTap: () {
                          openPage(
                              context,
                              widget.app,
                              true,
                              newPageDefaults(widget.app.documentID!),
                              'Create page');
                        })
                  ], shrinkWrap: true, physics: ScrollPhysics()),
                ),
              ]),
          topicContainer(widget.app, context,
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
                          return getListTile(context, widget.app,
                              onTap: () => openDialog(
                                    context,
                                    widget.app,
                                    false,
                                    item!,
                                    "Update dialog",
                                  ),
                              trailing: popupMenuButton<int>(
                                widget.app, context,
                                  child: Icon(Icons.more_vert),
                                  itemBuilder: (context) => [
                                        popupMenuItem(
                                          widget.app, context,
                                          value: 0,
                                          label: 'Details',
                                        ),
                                      ],
                                  onSelected: (value) {
                                    if (value == 0) {
                                      openDialog(
                                        context,
                                        widget.app,
                                        false,
                                        item!,
                                        "Update dialog",
                                      );
                                    }
                                  }),
                              title: text(widget.app, context,
                                  item != null ? item.title! : '?'));
                        }).toList())),
                    divider(widget.app, context),
                    GestureDetector(
                        child: Icon(Icons.add),
                        onTap: () {
                          openDialog(
                              context,
                              widget.app,
                              true,
                              newDialogDefaults(widget.app.documentID!),
                              'Create page');
                        })
                  ], shrinkWrap: true, physics: ScrollPhysics()),
                ),
              ]),
          topicContainer(widget.app, context,
              title: 'Policies',
              collapsible: true,
              collapsed: true,
              children: [
                getListTile(context, widget.app,
                    leading: Icon(Icons.description),
                    title: dialogField(
                      widget.app,
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
                          return getListTile(context, widget.app,
                              trailing: popupMenuButton<int>(
                                  widget.app, context,
                                  child: Icon(Icons.more_vert),
                                  itemBuilder: (context) => [
                                        popupMenuItem(
                                          widget.app, context,
                                          value: 0,
                                          label: 'Delete',
                                        ),
                                        popupMenuItem(
                                          widget.app, context,
                                          value: 1,
                                          label: 'Rename',
                                        ),
                                      ],
                                  onSelected: (value) {
                                    if (value == 0) {
                                      setState(() {
                                        state.appModel.policies!.policies!
                                            .remove(item);
                                      });
                                    } else if (value == 1) {
                                      openEntryDialog(
                                          widget.app,
                                          context,
                                          widget.app.documentID! +
                                              '/_createdivider',
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
                              title: text(widget.app, context,
                                  item != null ? item.name! : '?'));
                        }).toList())),
                    divider(widget.app, context),
                    _progressPolicy != null
                        ? Container(
                            height: 50,
                            child: progressIndicatorWithValue(
                                widget.app, context,
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
                                    state.appModel,
                                    state.appModel.ownerID!,
                                  ).createThumbnailUploadPdfFile(
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
          topicContainer(widget.app, context,
              title: 'Navigation',
              collapsible: true,
              collapsed: true,
              children: [
                Container(
                    height: 50,
                    width: widget.widgetWidth,
                    child: Row(children: [
                      Spacer(),
                      button(widget.app, context,
                          label: 'Left drawer',
                          onPressed: () => openDrawer(
                              context,
                              widget.app,
                              state.leftDrawerModel,
                              DecorationDrawerType.Left,
                              1)),
                      Spacer(),
                      button(widget.app, context,
                          label: 'App Bar',
                          onPressed: () => openAppBar(
                                context,
                                widget.app,
                                state.appBarModel,
                              )),
                      Spacer(),
                      button(widget.app, context,
                          label: 'Right drawer',
                          onPressed: () => openDrawer(
                              context,
                              widget.app,
                              state.rightDrawerModel,
                              DecorationDrawerType.Right,
                              1)),
                      Spacer(),
                      button(widget.app, context,
                          label: 'Bottom navbar',
                          onPressed: () => openBottomNavBar(
                                context,
                                widget.app,
                                state.homeMenuModel,
                              )),
                      Spacer(),
                    ]))
              ]),
        ]);
      } else {
        return progressIndicator(widget.app, context);
      }
    });
  }

  Widget _general(BuildContext context, AppModel app, bool create) {
    return topicContainer(widget.app, context,
        title: 'General',
        collapsible: true,
        collapsed: true,
        children: [
          getListTile(context, widget.app,
              leading: Icon(Icons.vpn_key),
              title: create
                  ? dialogField(
                      widget.app,
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
                  : text(widget.app, context, app.documentID!)),
          getListTile(context, widget.app,
              leading: Icon(Icons.description),
              title: dialogField(
                widget.app,
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
          getListTile(context, widget.app,
              leading: Icon(Icons.description),
              title: dialogField(
                widget.app,
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
          getListTile(context, widget.app,
              leading: Icon(Icons.email),
              title: dialogField(
                widget.app,
                context,
                initialValue: app.email,
                valueChanged: (value) {
                  app.email = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Email',
                  labelText: 'Email',
                ),
              )),
          checkboxListTile(
              widget.app,
              context,
              'Auto privilege level 1 for new members?',
              app.autoPrivileged1 ?? false, (value) {
            setState(() {
              app.autoPrivileged1 = value ?? false;
            });
          }),
          checkboxListTile(
              widget.app,
              context,
              'Featured',
              app.isFeatured ?? false, (value) {
            setState(() {
              app.isFeatured = value ?? false;
            });
          }),
        ]);
  }

  void _pdfFeedbackFunction(
      AppModel appModel, PublicMediumModel? publicMediumModel) {
    setState(() {
      _progressPolicy = null;
      appModel.policies!.policies!.add(AppPolicyItemModel(
          documentID: newRandomKey(),
          name: publicMediumModel!.baseName,
          policy: publicMediumModel));
    });
  }

  void _policyUploading(double? progress) {
    if (progress != null) {}
    setState(() {
      _progressPolicy = progress;
    });
  }
}
