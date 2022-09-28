import 'package:eliud_core/core/base/model_base.dart';
import 'package:eliud_core/core/base/repository_base.dart';
import 'package:eliud_core/core/blocs/access/access_event.dart';
import 'package:eliud_core/tools/widgets/app_policy_dashboard.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/registry.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_pkg_create/widgets/utils/models_json_bloc/models_json_bloc.dart';
import 'package:eliud_pkg_create/widgets/utils/models_json_bloc/models_json_event.dart';
import 'package:eliud_pkg_create/widgets/utils/models_json_widget.dart';
import 'package:eliud_core/decoration/decoration.dart';
import 'package:eliud_core/model/app_model.dart';
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
import '../jsontomodeltojson/modeltojsonhelper.dart';
import 'app_bloc/app_bloc.dart';
import 'app_bloc/app_event.dart';
import 'app_bloc/app_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'appbar_widget.dart';
import 'bodycomponents/bodycomponents__bloc/bodycomponents_create_state.dart';
import 'bottom_nav_bar_widget.dart';
import 'dialog_widget.dart';
import 'drawer_widget.dart';
import 'package:file_picker/file_picker.dart';

import 'logo_widget.dart';

typedef BlocProvider BlocProviderProvider(Widget child);

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
      create: (context) => AppCreateBloc(app.documentID, app)
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

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var member = AccessBloc.member(context);

    return BlocBuilder<AppCreateBloc, AppCreateState>(
        builder: (context, state) {
      if (state is AppCreateValidated) {
        return ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
          HeaderWidget(
            app: widget.app,
            cancelAction: () async {
              BlocProvider.of<AppCreateBloc>(context)
                  .add(AppCreateEventClose());
              return true;
            },
            okAction: () async {
              BlocProvider.of<AppCreateBloc>(context)
                  .add(AppCreateEventApplyChanges(true));
              return true;
            },
            title: 'App',
          ),
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
              title: 'Profile photo for members with no photo',
              collapsible: true,
              collapsed: true,
              children: [
                Registry.registry()!.getMediumApi().getPublicPhotoWidget(
                      context: context,
                      allowCrop: true,
                      defaultImage:
                          'packages/eliud_pkg_create/assets/rodentia-icons_preferences-desktop-personal.png',
                      feedbackFunction: (mediumModel) {
                        setState(() {
                          state.appModel.anonymousProfilePhoto = mediumModel;
                        });
                      },
                      app: widget.app,
                      initialImage: state.appModel.anonymousProfilePhoto,
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
          if (member == null)
            text(widget.app, context,
                "Not logged on, hence can't copy the widget to member medium"),
          if (member != null)
            ModelsJsonWidget.getIt(
                context,
                widget.app,
                    () => getModelsJsonConstructJsonEventToClipboard(state),
                    (baseName) =>
                    getModelsJsonConstructJsonEventToMemberMediumModel(
                        state, member, baseName),
                getFilename(state)),
          Container(height: 20),
          HeaderWidget(
            app: widget.app,
            title: 'Referenced data',
          ),
          topicContainer(widget.app, context,
              title: 'Policies',
              collapsible: true,
              collapsed: true,
              children: [
                Container(
                  child: ListView(children: [
                    Container(
                        height: 200, //heightUnit() * 1,
                        width: widget.widgetWidth,
                        child: ListView(
                            children:
                            state.policies.map((item) {
                              return getListTile(context, widget.app,
                                  trailing: popupMenuButton<int>(
                                      widget.app, context,
                                      child: Icon(Icons.more_vert),
                                      itemBuilder: (context) => [
                                        popupMenuItem(
                                          widget.app,
                                          context,
                                          value: 0,
                                          label: 'Delete',
                                        ),
                                        popupMenuItem(
                                          widget.app,
                                          context,
                                          value: 1,
                                          label: 'Update',
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 0) {
                                          setState(() {
                                            BlocProvider.of<AppCreateBloc>(context)
                                                .add(AppCreateDeletePolicy(item));
                                          });
                                        } else if (value == 1) {
                                          AppPolicyDashboard.updateAppPolicy(widget.app, context, item);
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
                            var documentId = newRandomKey();
                            if (kIsWeb) {
                              var data = _result.files[0].bytes;
                              var baseName = _result.files[0].name + (_result.files[0].extension ?? '');
                              if (data != null) {
                                await PublicMediumHelper(
                                  state.appModel,
                                  state.appModel.ownerID,
                                ).createThumbnailUploadPdfData(
                                    documentId, data, baseName, documentId,
                                    feedbackFunction: (pdf) =>
                                        _pdfFeedbackFunction(
                                            state.appModel, pdf),
                                    feedbackProgress: _policyUploading);
                              }
                            } else {
                              var path = _result.files[0].path;
                              if (path != null) {
                                await PublicMediumHelper(
                                  state.appModel,
                                  state.appModel.ownerID,
                                ).createThumbnailUploadPdfFile(
                                    documentId, path, documentId,
                                    feedbackFunction: (pdf) =>
                                        _pdfFeedbackFunction(
                                            state.appModel, pdf),
                                    feedbackProgress: _policyUploading);
                              }
                            }
                          }
                        })
                  ], shrinkWrap: true, physics: ScrollPhysics()),
                ),
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
                                  /* onTap: () => openPage(
                                    context,
                                    widget.app,
                                    false,
                                    item,
                                    "Update page",
                                  ),*/
                                  trailing: popupMenuButton<int>(
                                      widget.app, context,
                                      child: Icon(Icons.more_vert),
                                      itemBuilder: (context) => [
                                        popupMenuItem(
                                          widget.app,
                                          context,
                                          value: 0,
                                          label: 'Update',
                                        ),
                                        popupMenuItem(
                                          widget.app,
                                          context,
                                          value: 8,
                                          label: 'Delete',
                                        ),
                                        popupMenuDivider(widget.app, context),
                                        popupMenuItem(
                                          widget.app,
                                          context,
                                          value: 1,
                                          label: 'Set as public homepage',
                                        ),
                                        popupMenuItem(
                                          widget.app,
                                          context,
                                          value: 2,
                                          label:
                                          'Set as homepage for subscribed member',
                                        ),
                                        popupMenuItem(
                                          widget.app,
                                          context,
                                          value: 3,
                                          label:
                                          'Set as homepage for suscribed member, level 1',
                                        ),
                                        popupMenuItem(
                                          widget.app,
                                          context,
                                          value: 4,
                                          label:
                                          'Set as homepage for suscribed member, level 2',
                                        ),
                                        popupMenuItem(
                                          widget.app,
                                          context,
                                          value: 5,
                                          label:
                                          'Set as homepage for blocked member',
                                        ),
                                        popupMenuItem(
                                          widget.app,
                                          context,
                                          value: 6,
                                          label: 'Set as homepage for owner',
                                        ),
                                        popupMenuDivider(widget.app, context),
                                        popupMenuItem(
                                          widget.app,
                                          context,
                                          value: 7,
                                          label: 'Show page',
                                        ),
                                      ],
                                      onSelected: (value) {
                                        switch (value) {
                                          case 0:
                                            openPage(
                                              context,
                                              widget.app,
                                              false,
                                              item,
                                              "Update page",
                                            );
                                            break;
                                          case 8:
                                            BlocProvider.of<AppCreateBloc>(context)
                                                .add(AppCreateDeletePage(item));
                                            break;
                                          case 1:
                                            setState(() => state.appModel.homePages!
                                                .homePagePublic = item.documentID);
                                            break;
                                          case 2:
                                            setState(() => state.appModel.homePages!
                                                .homePageSubscribedMember =
                                                item.documentID);
                                            break;
                                          case 3:
                                            setState(() => state.appModel.homePages!
                                                .homePageLevel1Member =
                                                item.documentID);
                                            break;
                                          case 4:
                                            setState(() => state.appModel.homePages!
                                                .homePageLevel2Member =
                                                item.documentID);
                                            break;
                                          case 5:
                                            setState(() => state.appModel.homePages!
                                                .homePageBlockedMember =
                                                item.documentID);
                                            break;
                                          case 6:
                                            setState(() => state.appModel.homePages!
                                                .homePageOwner = item.documentID);
                                            break;
                                          case 7:
                                            Navigator.of(context).pop();
                                            var accessBloc =
                                            BlocProvider.of<AccessBloc>(
                                                context);
                                            accessBloc.add(GotoPageEvent(
                                              state.appModel,
                                              item.documentID,
                                            ));
                                            break;
                                        }
                                      }),
                                  subtitle:
                                  text(widget.app, context, item.documentID),
                                  title:
                                  text(widget.app, context, item.title ?? '?'));
                            }).toList())),
                    divider(widget.app, context),
                    GestureDetector(
                        child: Icon(Icons.add),
                        onTap: () {
                          openPage(
                              context,
                              widget.app,
                              true,
                              newPageDefaults(widget.app.documentID),
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
                                  /*onTap: () => openDialog(
                                    context,
                                    widget.app,
                                    false,
                                    item,
                                    "Update dialog",
                                  ),*/
                                  trailing: popupMenuButton<int>(
                                      widget.app, context,
                                      child: Icon(Icons.more_vert),
                                      itemBuilder: (context) => [
                                        popupMenuItem(
                                          widget.app,
                                          context,
                                          value: 0,
                                          label: 'Update',
                                        ),
                                        popupMenuItem(
                                          widget.app,
                                          context,
                                          value: 2,
                                          label: 'Delete',
                                        ),
                                        popupMenuItem(
                                          widget.app,
                                          context,
                                          value: 1,
                                          label: 'Open dialog',
                                        ),
                                      ],
                                      onSelected: (value) async {
                                        switch (value) {
                                          case 0:
                                            openDialog(
                                              context,
                                              widget.app,
                                              false,
                                              item,
                                              "Update dialog",
                                            );
                                            break;
                                          case 2:
                                            BlocProvider.of<AppCreateBloc>(context)
                                                .add(AppCreateDeleteDialog(item));
                                            break;
                                          case 1:
                                            await Registry.registry()!.openDialog(
                                                context,
                                                app: widget.app,
                                                id: item.documentID);
                                            break;
                                        }
                                      }),
                                  subtitle:
                                  text(widget.app, context, item.documentID),
                                  title:
                                  text(widget.app, context, item.title ?? '?'));
                            }).toList())),
                    divider(widget.app, context),
                    GestureDetector(
                        child: Icon(Icons.add),
                        onTap: () {
                          openDialog(
                              context,
                              widget.app,
                              true,
                              newDialogDefaults(widget.app.documentID),
                              'Create dialog');
                        })
                  ], shrinkWrap: true, physics: ScrollPhysics()),
                ),
              ]),
        ]);
      } else {
        return progressIndicator(widget.app, context);
      }
    });
  }

  String getFilename(AppCreateValidated state) =>
      getJsonFilename(state.appModel.documentID, 'app');

  Future<List<ModelsJsonTask>> getTasks(
      AppCreateInitialised appCreateInitialised,
      List<AbstractModelWithInformation> data) async {
    return ModelsToJsonHelper.getTasksForApp(
        appCreateInitialised.appModel,
        appCreateInitialised.appBarModel,
        appCreateInitialised.homeMenuModel,
        appCreateInitialised.leftDrawerModel,
        appCreateInitialised.rightDrawerModel,
        appCreateInitialised.dialogs,
        appCreateInitialised.pages,
        data);
  }

  ModelsJsonConstructJsonEventToClipboard
      getModelsJsonConstructJsonEventToClipboard(
          AppCreateInitialised appCreateInitialised) {
    List<AbstractModelWithInformation> data = [];
    return ModelsJsonConstructJsonEventToClipboard(
        () => getTasks(appCreateInitialised, data), data);
  }

  ModelsJsonConstructJsonEventToMemberMediumModel
      getModelsJsonConstructJsonEventToMemberMediumModel(
          AppCreateInitialised appCreateInitialised,
          MemberModel member,
          String baseName) {
    List<AbstractModelWithInformation> data = [];
    return ModelsJsonConstructJsonEventToMemberMediumModel(
        () => getTasks(appCreateInitialised, data), data, member, baseName);
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
                  : text(widget.app, context, app.documentID)),
          getListTile(context, widget.app,
              leading: Icon(Icons.description),
              title: dialogField(
                widget.app,
                context,
                initialValue: app.homeURL,
                valueChanged: (value) {
                  app.homeURL = value;
                },
                decoration: const InputDecoration(
                  hintText:
                      "e.g. https://www.minkey.io. This is usual as information, but actually used by some component, e.g. when presenting HTML: when HTML includes a link, this link will be evaluate and if it's a link within the app / website, it'll open that page, rather than open a browser",
                  labelText: 'Home URL',
                ),
              )),
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
              widget.app, context, 'Featured', app.isFeatured ?? false,
              (value) {
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
      if (publicMediumModel != null) {
        BlocProvider.of<AppCreateBloc>(context)
            .add(AppCreateAddPolicy(publicMediumModel));
      }
    });
  }

  void _policyUploading(double? progress) {
    if (progress != null) {}
    setState(() {
      _progressPolicy = progress;
    });
  }
}
