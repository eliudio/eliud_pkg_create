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
import 'package:eliud_core/tools/component/update_component.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_pkg_create/widgets/app_widget.dart';
import 'package:eliud_pkg_create/widgets/appbar_widget.dart';
import 'package:eliud_pkg_create/widgets/bottom_nav_bar_widget.dart';
import 'package:eliud_pkg_create/widgets/dialog_widget.dart';
import 'package:eliud_pkg_create/widgets/drawer_widget.dart';
import 'package:eliud_pkg_create/widgets/from_json_widget.dart';
import 'package:eliud_pkg_create/widgets/page_widget.dart';
import 'package:eliud_pkg_create/widgets/privilege_widget.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:eliud_pkg_create/widgets/style_selection_widget.dart';
import 'package:eliud_pkg_create/widgets/utils/creator_button.dart';
import 'package:eliud_pkg_create/widgets/utils/my_decorated_widget.dart';
import 'package:eliud_pkg_create/widgets/wizard_widget.dart';
import 'package:flutter/material.dart';
import 'tools/constants.dart';

class CreatorDecoration extends deco.Decoration {
  static double fraction = 1;
  ValueNotifier<bool> _isCreationMode = ValueNotifier<bool>(false);

  static bool disableSimulatePrivilege = true;

  @override
  CreateWidget createDecoratedAppBar(AppModel app, BuildContext context,
      Key? appBarKey, CreateWidget createOriginalAppBar, AppBarModel model) {
    if (!AccessBloc.isOwner(context, app)) return createOriginalAppBar;
    var currentAccess = AccessBloc.getState(context);

    return (() {
      return MyDecoratedWidget(
        isCreationMode: _isCreationMode,
        originalWidgetKey: appBarKey,
        createOriginalWidget: disableSimulatePrivilege
            ? createOriginalAppBar
            : () {
                return MyDecoratedWidget(
                  isCreationMode: _isCreationMode,
                  originalWidgetKey: appBarKey,
                  createOriginalWidget: createOriginalAppBar,
                  action: SingleAction(() {
                    openFlexibleDialog(
                      app,
                      context,
                      app.documentID + '/_appbar',
                      includeHeading: false,
                      widthFraction: .9,
                      child: PrivilegeWidget(
                        app: app,
                        currentAccess: currentAccess,
                      ),
                    );
                  }),
                  ensureHeight: false,
                  initialPosition: InitialPosition.LeftBottom,
                  label: 'privilege',
                );
              },
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
      AppModel app,
      BuildContext context,
      Key? originalBodyComponentKey,
      CreateWidget createBodyComponent,
      BodyComponentModel model) {
    if (!AccessBloc.isOwner(context, app)) return createBodyComponent;

    return (() {
      return MyDecoratedWidget(
        isCreationMode: _isCreationMode,
        originalWidgetKey: originalBodyComponentKey,
        createOriginalWidget: createBodyComponent,
        action: SingleAction(() {
          updateComponent(context, app, model.componentName, model.componentId,
              (status, value) {});
        }),
        ensureHeight: true,
        initialPosition: InitialPosition.LeftTop,
        label: model.componentName! + ' [' + model.componentId! + ']',
      );
    });
  }

  @override
  CreateWidget createDecoratedBottomNavigationBar(
      AppModel app,
      BuildContext context,
      Key? originalBottomNavigationBarKey,
      CreateWidget createBottomNavigationBar,
      HomeMenuModel model) {
    if (!AccessBloc.isOwner(context, app)) return createBottomNavigationBar;

    return (() {
      return MyDecoratedWidget(
        isCreationMode: _isCreationMode,
        originalWidgetKey: originalBottomNavigationBarKey,
        createOriginalWidget: createBottomNavigationBar,
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
      AppModel app,
      BuildContext context,
      DecorationDrawerType decorationDrawerType,
      Key? originalDrawerKey,
      CreateWidget createOriginalDrawer,
      DrawerModel model) {
    if (!AccessBloc.isOwner(context, app)) return createOriginalDrawer;

    return (() {
      return MyDecoratedWidget(
        isCreationMode: _isCreationMode,
        originalWidgetKey: originalDrawerKey,
        createOriginalWidget: createOriginalDrawer,
        action: SingleAction(() {
          openDrawer(context, app, model, decorationDrawerType, fraction);
        }),
        ensureHeight: false,
        initialPosition: InitialPosition.CenterCenter,
        label: 'drawer1',
      );
    });
  }

  @override
  CreateWidget createDecoratedPage(AppModel app, BuildContext context,
      Key? originalPageKey, CreateWidget createOriginalPage, PageModel model) {
    if (!AccessBloc.isOwner(context, app)) return createOriginalPage;

    return (() {
      // Button for the decorator itself
      return MyDecoratedWidget(
//        label: 'creator',
          action: SingleAction(() {
            _isCreationMode.value = !_isCreationMode.value;
          }),
          ensureHeight: false,
          initialPosition: InitialPosition.CenterBottom,
          isCreationMode: ValueNotifier<bool>(true),
          originalWidgetKey: originalPageKey,
          createOriginalWidget: () {
            // Button for the page
            return MyDecoratedWidget(
              isCreationMode: _isCreationMode,
              originalWidgetKey: originalPageKey,
              createOriginalWidget: () {
                // Button for the wizard
                return MyDecoratedWidget(
                  isCreationMode: _isCreationMode,
                  icon: Icon(
                    Icons.star,
                    color: Constants.ICON_COLOR,
                    size: 15,
                  ),
                  originalWidgetKey: originalPageKey,
                  createOriginalWidget: () {
                    // Button for the app
                    return MyDecoratedWidget(
                      isCreationMode: _isCreationMode,
                      originalWidgetKey: originalPageKey,
                      createOriginalWidget: () {
                        if (app != null) {
                          return MyDecoratedWidget(
                            isCreationMode: _isCreationMode,
                            originalWidgetKey: originalPageKey,
                            createOriginalWidget: createOriginalPage,
                            icon: Icon(
                              Icons.palette_outlined,
                              color: Constants.ICON_COLOR,
                              size: CreatorButton.BUTTON_HEIGHT * .7,
                            ),
                            action: SingleAction(() {
                              openComplexDialog(
                                  app, context, app.documentID + '/_style',
                                  widthFraction: .5,
                                  includeHeading: false,
                                  child: StyleSelectionWidget.getIt(
                                      context, app, true, false, false),
                                  title: 'Style');
                            }),
                            ensureHeight: false,
                            initialPosition: InitialPosition.RightBottom,
                          );
                        } else {
                          return text(app, context, 'No app');
                        }
                      },
                      action: SingleAction(() {
                        openFlexibleDialog(
                          app,
                          context,
                          app.documentID + '/_appcreate',
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
                      initialPosition: InitialPosition.LeftAlmostBottom,
                      label: 'app',
                    );
                  },
                  action: SingleAction(() {
                    var member = AccessBloc.member(context);
                    if (member != null) {
                      newWizard(
                        context,
                        member,
                        app,
                        fraction: .9,
                      );
                    }
                  }),
                  ensureHeight: false,
                  initialPosition: InitialPosition.LeftBottom,
//                  label: 'wizard',
                );
              },
              action: MultipleActions(app, [
                ActionWithLabel('Update page', () {
                  openPage(
                    context,
                    app,
                    false,
                    model,
                    'Update Page',
                  );
                }),
                ActionWithLabel('Create page', () {
                  openPage(context, app, true, newPageDefaults(app.documentID),
                      'Create page');
                }),
                ActionWithLabel('Create page from previously stored page', () {
                  var member = AccessBloc.member(context);
                  if (member != null) {
                    newFromJson(
                      context,
                      member,
                      app,
                    );
                  } else {
                    print("Can't create page without logged in member");
                  }
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
  deco.CreateWidget createDecoratedErrorPage(AppModel app, BuildContext context,
      Key? originalPageKey, deco.CreateWidget createOriginalPage) {
    if (!AccessBloc.isOwner(context, app)) return createOriginalPage;

    return (() {
      // Button for the decorator itself
      return MyDecoratedWidget(
        action: SingleAction(() {
          _isCreationMode.value = !_isCreationMode.value;
        }),
//        label: 'creator',
        ensureHeight: false,
        initialPosition: InitialPosition.RightAlmostBottom,
        isCreationMode: ValueNotifier<bool>(true),
        originalWidgetKey: originalPageKey,
        createOriginalWidget: () {
          // Button for the wizard
          return MyDecoratedWidget(
            isCreationMode: _isCreationMode,
            originalWidgetKey: originalPageKey,
            createOriginalWidget: () {
              // Button for the app
              return MyDecoratedWidget(
                isCreationMode: _isCreationMode,
                originalWidgetKey: originalPageKey,
                createOriginalWidget: () {
                  if (app != null) {
                    return MyDecoratedWidget(
                      isCreationMode: _isCreationMode,
                      originalWidgetKey: originalPageKey,
                      createOriginalWidget: createOriginalPage,
                      icon: Icon(
                        Icons.palette_outlined,
                        color: Constants.ICON_COLOR,
                        size: CreatorButton.BUTTON_HEIGHT * .7,
                      ),
                      action: SingleAction(() {
                        openComplexDialog(
                            app, context, app.documentID + '/_style',
                            widthFraction: .5,
                            includeHeading: false,
                            child: StyleSelectionWidget.getIt(
                                context, app, true, false, false),
                            title: 'Style');
                      }),
                      ensureHeight: false,
                      initialPosition: InitialPosition.RightBottom,
                    );
                  } else {
                    return text(app, context, 'No app');
                  }
                },
                action: SingleAction(() {
                  openFlexibleDialog(
                    app,
                    context,
                    app.documentID + '/_appcreate',
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
            action: SingleAction(() {
              var member = AccessBloc.member(context);
              if (member != null) {
                newWizard(
                  context,
                  member,
                  app,
                  fraction: .9,
                );
              }
            }),
            ensureHeight: false,
            initialPosition: InitialPosition.LeftAlmostBottom,
            label: 'wizard',
          );
        },
      );
    });
  }

  @override
  deco.CreateWidget createDecoratedApp(
      AppModel app,
      BuildContext context,
      Key? originalAppkey,
      deco.CreateWidget createOriginalApp,
      AppModel model) {
    return createOriginalApp;
  }

  @override
  deco.CreateWidget createDecoratedDialog(
      AppModel app,
      BuildContext context,
      Key? originalDialogKey,
      deco.CreateWidget createOriginalDialog,
      DialogModel model) {
    if (!AccessBloc.isOwner(context, app)) return createOriginalDialog;

    return (() {
      return MyDecoratedWidget(
        isCreationMode: _isCreationMode,
        originalWidgetKey: originalDialogKey,
        createOriginalWidget: createOriginalDialog,
        action: MultipleActions(app, [
          ActionWithLabel('Update dialog', () {
            openDialog(
              context,
              app,
              false,
              model,
              'Update Page',
            );
          }),
          ActionWithLabel('Create dialog', () {
            openDialog(context, app, true, newDialogDefaults(app.documentID),
                'Create dialog');
          }),
        ]),
        ensureHeight: false,
        initialPosition: InitialPosition.LeftCenter,
        label: 'dialog',
      );
    });
  }
}
