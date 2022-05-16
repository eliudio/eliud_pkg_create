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
    app.documentID! + '/_drawer',
    includeHeading: false,
    widthFraction: fraction,
    child: DrawerCreateWidget.getIt(
      context,
      app,
      decorationDrawerType == DecorationDrawerType.Left
          ? DrawerType.Left
          : DrawerType.Right,
      model,
      fullScreenWidth(context) * fraction,
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
        app.documentID!,
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
                      title: 'General',
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
                        _mediaButtons(context, state, widget.app,
                            accessState.getMember()!.documentID!),
                        getListTile(context, widget.app,
                            leading: Icon(Icons.description),
                            title: dialogField(
                              widget.app,
                              context,
                              keyboardType: TextInputType.multiline,
                              maxLines: 3,
                              valueChanged: (value) =>
                                  state.drawerModel.secondHeaderText = value,
                              initialValue: state.drawerModel.secondHeaderText,
                              decoration: inputDecoration(
                                widget.app,
                                context,
                                'Second Header text',
                              ),
                            )),
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
        return progressIndicator(widget.app, context);
      }
    });
  }

  Widget _mediaButtons(BuildContext context, DrawerCreateValidated state,
      AppModel app, String memberId) {
    // logic:
    // if there's progress then show a progress bar
    // if there's a url, then show the photo and a clear button
    // if there's no url, then show an icon to set a photo

    var displayCase = DisplayCase.AllowNewEntry;
    if (_progress != null) {
      displayCase = DisplayCase.ShowProgress;
    } else if (state.drawerModel.headerBackgroundOverride != null) {
      if ((state.drawerModel.headerBackgroundOverride!
                  .useProfilePhotoAsBackground !=
              null) &&
          (state.drawerModel.headerBackgroundOverride!
              .useProfilePhotoAsBackground!)) {
        displayCase = DisplayCase.ShowMemberProfilePhoto;
      } else if (state.drawerModel.headerBackgroundOverride!.backgroundImage !=
          null) {
        displayCase = DisplayCase.ShowUrlPhoto;
      }
    }
    switch (displayCase) {
      case DisplayCase.ShowProgress:
        return progressIndicatorWithValue(widget.app, context,
            value: _progress!);
      case DisplayCase.ShowMemberProfilePhoto:
        return _listTileWithMemberPhoto(context, memberId, state.drawerModel);
      case DisplayCase.ShowUrlPhoto:
        return _listTileWithPhotoUrl(context, memberId, state.drawerModel);
      case DisplayCase.AllowNewEntry:
        return _listTileForNewEntry(context, memberId, state.drawerModel);
    }
  }

  Widget _listTileForNewEntry(
      BuildContext context, String ownerId, DrawerModel drawerModel) {
    return _listTile(context,
        widget1: _mediaButton(
          context,
          ownerId,
          drawerModel,
        ));
  }

  Widget _listTileWithPhotoUrl(
      BuildContext context, String ownerId, DrawerModel drawerModel) {
    return _listTile(context,
        widget1: Image.network(
          drawerModel.headerBackgroundOverride!.backgroundImage!.url!,
          width: 100,
        ),
        widget2: _clearButton(drawerModel.headerBackgroundOverride!));
  }

  Widget _listTileWithMemberPhoto(
      BuildContext context, String ownerId, DrawerModel drawerModel) {
    return _listTile(context,
        widget1: text(widget.app, context, 'Using member profile photo'),
        widget2: _clearButton(drawerModel.headerBackgroundOverride!));
  }

  Widget _listTile(BuildContext context,
      {required Widget widget1, Widget? widget2}) {
    return getListTile(context, widget.app,
        leading: Icon(Icons.add_a_photo),
        title: Container(
          padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
          child:
              ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
            inputDecorationLabel(widget.app, context, 'Header image / logo'),
            Row(children: [
              widget1,
              Spacer(),
              if (widget2 != null) widget2,
              if (widget2 != null) Spacer(),
            ])
          ]),
        ));
  }

  Widget _constructWithPhoto() {
    return Row(children: [
      Spacer(),
      Spacer(),
    ]);
  }

  Widget _clearButton(BackgroundModel backgroundModel) {
    return iconButton(widget.app, context, icon: Icon(Icons.clear),
        onPressed: () {
      setState(() {
        backgroundModel.backgroundImage = null;
        backgroundModel.useProfilePhotoAsBackground = null;
      });
    });
  }

  Widget _mediaButton(
    BuildContext context,
    String ownerId,
    DrawerModel drawerModel,
  ) {
    var items = <PopupMenuItem<int>>[];
    if (Registry.registry()!.getMediumApi().hasCamera()) {
      items.add(
        popupMenuItem<int>(
            widget.app, context,
            label: 'Take photo', value: 0),
      );
    }
    items.add(popupMenuItem<int>(
        widget.app, context,
        label: 'Upload photo', value: 1));
    items.add(popupMenuItem<int>(
        widget.app, context,
        label: 'Use member profile photo',
        value: 2));
    return popupMenuButton(
        widget.app, context,
        tooltip: 'Add photo',
        child: const Icon(Icons.photo, size: 40),
        itemBuilder: (_) => items,
        onSelected: (choice) {
          if (choice == 0) {
            Registry.registry()!.getMediumApi().takePhoto(
                context,
                widget.app,
                ownerId,
                () => PublicMediumAccessRights(),
                (photo) => _photoFeedbackFunction(drawerModel, photo),
                _photoUploading,
                allowCrop: false);
          }
          if (choice == 1) {
            Registry.registry()!.getMediumApi().uploadPhoto(
                context,
                widget.app,
                ownerId,
                () => PlatformMediumAccessRights(
                    PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple),
                (photo) => _photoFeedbackFunction(drawerModel, photo),
                _photoUploading,
                allowCrop: false);
          }
          if (choice == 2) {
            setState(() {
              drawerModel.headerBackgroundOverride =
                  drawerModel.headerBackgroundOverride == null
                      ? BackgroundModel(useProfilePhotoAsBackground: true)
                      : drawerModel.headerBackgroundOverride!.copyWith(
                          useProfilePhotoAsBackground: true,
                          backgroundImage: null);
            });
          }
        });
  }

  void _photoFeedbackFunction(
      DrawerModel drawerModel, PublicMediumModel? publicMediumModel) {
    setState(() {
      _progress = null;
      if (publicMediumModel != null) {
        drawerModel.headerBackgroundOverride =
            drawerModel.headerBackgroundOverride == null
                ? BackgroundModel(backgroundImage: publicMediumModel)
                : drawerModel.headerBackgroundOverride!.copyWith(
                    useProfilePhotoAsBackground: false,
                    backgroundImage: publicMediumModel);
      }
    });
  }

  void _photoUploading(double? progress) {
    if (progress != null) {}
    setState(() {
      _progress = progress;
    });
  }
}
