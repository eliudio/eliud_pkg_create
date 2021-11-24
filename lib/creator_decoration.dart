import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/decoration/decoration.dart' as deco;
import 'package:eliud_core/decoration/decoration.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_pkg_create/widgets/app_widget.dart';
import 'package:eliud_pkg_create/widgets/appbar_widget.dart';
import 'package:eliud_pkg_create/widgets/bottom_nav_bar_widget.dart';
import 'package:eliud_pkg_create/widgets/dialog_widget.dart';
import 'package:eliud_pkg_create/widgets/drawer_widget.dart';
import 'package:eliud_pkg_create/widgets/page_widget.dart';
import 'package:eliud_pkg_create/widgets/privilege_widget.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:eliud_pkg_create/tools/help_functions.dart';
import 'package:eliud_pkg_create/widgets/style_selection_widget.dart';
import 'package:eliud_pkg_create/widgets/utils/my_decorated_widget.dart';
import 'package:eliud_pkg_create/widgets/utils/my_decorated_widget2.dart';
import 'package:eliud_pkg_etc/widgets/decorator/creator_button.dart';
import 'package:eliud_pkg_etc/widgets/decorator/decorated_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'tools/constants.dart';

class CreatorDecoration extends deco.Decoration {
  static double fraction = 1;
  ValueNotifier<bool> _isCreationMode = ValueNotifier<bool>(false);

  @override
  CreateWidget createDecoratedAppBar(BuildContext context, Key? appBarKey,
      CreateWidget createOriginalAppBar, AppBarModel model) {
    if (!AccessBloc.isOwner(context)) return createOriginalAppBar;
    var app = AccessBloc.currentApp(context);
    var currentAccess = AccessBloc.getState(context);

    return (() {
      return MyDecoratedWidget<AppBarModel>(
        isCreationMode: _isCreationMode,
        originalWidgetKey: appBarKey,
        createOriginalWidget: () {
          return MyDecoratedWidget<AppBarModel>(
            isCreationMode: _isCreationMode,
            originalWidgetKey: appBarKey,
            createOriginalWidget: createOriginalAppBar,
            model: model,
            action: SingleAction(() {
              openFlexibleDialog(
                context, app.documentID! + '/_appbar',
                includeHeading: false,
                widthFraction: .9,
                child: PrivilegeWidget(app: app, currentAccess: currentAccess,),
              );
            }),
            ensureHeight: false,
            initialPosition: InitialPosition.LeftBottom,
            label: 'privilege',
          );
        },
        model: model,
        action: SingleAction(() {
          openAppBar(context, app, model, fraction: fraction);
        }),
        ensureHeight: false,
        initialPosition: InitialPosition.CenterCenter,
        label: 'appbar',
      );
    });
  }

  @override
  CreateWidget createDecoratedBodyComponent(
      BuildContext context,
      Key? originalBodyComponentKey,
      CreateWidget createBodyComponent,
      BodyComponentModel model) {
    if (!AccessBloc.isOwner(context)) return createBodyComponent;

    return (() {
      return MyDecoratedWidget<BodyComponentModel>(
        isCreationMode: _isCreationMode,
        originalWidgetKey: originalBodyComponentKey,
        createOriginalWidget: createBodyComponent,
        model: model,
        action: SingleAction(() {
          updateComponent(context, model.componentName, model.componentId, (status) {});
        }),
        ensureHeight: true,
        initialPosition: InitialPosition.LeftTop,
        label: model.componentName! + ' [' + model.componentId! + ']',
      );
    });
  }

  @override
  CreateWidget createDecoratedBottomNavigationBar(
      BuildContext context,
      Key? originalBottomNavigationBarKey,
      CreateWidget createBottomNavigationBar,
      HomeMenuModel model) {
    if (!AccessBloc.isOwner(context)) return createBottomNavigationBar;
    var app = AccessBloc.currentApp(context);

    return (() {
      return MyDecoratedWidget<HomeMenuModel>(
        isCreationMode: _isCreationMode,
        originalWidgetKey: originalBottomNavigationBarKey,
        createOriginalWidget: createBottomNavigationBar,
        model: model,
        action: SingleAction(() {
          openBottomNavBar(context, app, model, fraction: fraction);
        }),
        ensureHeight: false,
        initialPosition: InitialPosition.CenterTop,
        label: 'bottom nav',
      );
    });
  }

  @override
  CreateWidget createDecoratedDrawer(
      BuildContext context,
      DecorationDrawerType decorationDrawerType,
      Key? originalDrawerKey,
      CreateWidget createOriginalDrawer,
      DrawerModel model) {
    if (!AccessBloc.isOwner(context)) return createOriginalDrawer;
    var app = AccessBloc.currentApp(context);

    return (() {
      return MyDecoratedWidget<DrawerModel>(
        isCreationMode: _isCreationMode,
        originalWidgetKey: originalDrawerKey,
        createOriginalWidget: createOriginalDrawer,
        model: model,
        action: SingleAction(() {
          openDrawer(
              context, app, model, decorationDrawerType, fraction);
        }),
        ensureHeight: false,
        initialPosition: InitialPosition.CenterCenter,
        label: 'drawer1',
      );
    });
  }

  @override
  CreateWidget createDecoratedPage(BuildContext context, Key? originalPageKey,
      CreateWidget createOriginalPage, PageModel model) {
    if (!AccessBloc.isOwner(context)) return createOriginalPage;
    var app = AccessBloc.currentApp(context);

    return (() {
      // Button for the decorator itself
      return DecoratedWidget(
          backgroundColor: Constants.BACKGROUND_COLOR,
          textColor: Constants.TEXT_COLOR,
          iconOn: Icon(
            Icons.edit,
            color: Constants.ICON_COLOR,
            size: 15,
          ),
          iconOff: Icon(
            Icons.edit_outlined,
            color: Constants.ICON_COLOR,
            size: 15,
          ),
          bordercolor: Constants.BORDER_COLOR,
//        label: 'creator',
          ensureHeight: false,
          initialPosition: InitialPosition.RightAlmostBottom,
          isCreationMode: _isCreationMode,
          originalWidgetKey: originalPageKey,
          createOriginalWidget: () {
            // Button for the page
            return MyDecoratedWidget<PageModel>(
              isCreationMode: _isCreationMode,
              originalWidgetKey: originalPageKey,
              createOriginalWidget: () {
                // Button for the app
                return MyDecoratedWidget<AppModel>(
                  isCreationMode: _isCreationMode,
                  originalWidgetKey: originalPageKey,
                  createOriginalWidget: () {
                    var app = AccessBloc.currentApp(context);
                    if (app != null) {
                      return MyDecoratedWidget2<PageModel>(
                        originalWidgetKey: originalPageKey,
                        createOriginalWidget: createOriginalPage,
                        model: model,
                        action: (state) {
                          openComplexDialog(context, app.documentID! + '/_style',
                              widthFraction: .5,
                              includeHeading: false,
                              child:
                              StyleSelectionWidget.getIt(context, app, true, false, ),
                              title: 'Style');
                        },
                        ensureHeight: false,
                        initialPosition: InitialPosition.RightBottom,
                      );
                    } else {
                      return text(context, 'No app');
                    }
                  },
                  model: app,
                  action: SingleAction(() {
                    openFlexibleDialog(
                      context, app.documentID! + '/_appcreate',
                      includeHeading: false,
                      widthFraction: fraction,
                      child: AppCreateWidget.getIt(
                        context,
                        app,
                        false,
                        fullScreenWidth(context) * fraction,
                        fullScreenHeight(context) - 100,
                      ),
                    );
                  }),
                  ensureHeight: false,
                  initialPosition: InitialPosition.LeftBottom,
                  label: 'app',
                );
              },
              model: model,
              action: MultipleActions([
                ActionWithLabel('Update page', () {
                  openPage(context, app, false, model, 'Update Page',);
                }),
                ActionWithLabel('Create page', () {
                  openPage(
                      context,
                      app,
                      true,
                      newPageDefaults(AccessBloc.currentAppId(context)),
                      'Create page');
                }),
              ]),
              ensureHeight: false,
              initialPosition: InitialPosition.LeftCenter,
              label: 'page',
            );
          });
    });
  }

  @override
  deco.CreateWidget createDecoratedApp(
      BuildContext context,
      Key? originalAppkey,
      deco.CreateWidget createOriginalApp,
      AppModel model) {
    return createOriginalApp;
  }

  @override
  deco.CreateWidget createDecoratedDialog(
      BuildContext context,
      Key? originalDialogKey,
      deco.CreateWidget createOriginalDialog,
      DialogModel model) {
    if (!AccessBloc.isOwner(context)) return createOriginalDialog;
    var app = AccessBloc.currentApp(context);

    return (() {
      return MyDecoratedWidget<DialogModel>(
        isCreationMode: _isCreationMode,
        originalWidgetKey: originalDialogKey,
        createOriginalWidget: createOriginalDialog,
        model: model,
        action: MultipleActions([
          ActionWithLabel('Update dialog', () {
            openDialog(context, app, false, model, 'Update Page',);
          }),
          ActionWithLabel('Create dialog', () {
            openDialog(context, app, true,
                newDialogDefaults(AccessBloc.currentAppId(context)), 'Create dialog');
          }),
        ]),
        ensureHeight: false,
        initialPosition: InitialPosition.LeftCenter,
        label: 'dialog',
      );
    });
  }
}
