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
import 'package:eliud_pkg_create/registry/registry.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/new_app_bloc.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/new_app_event.dart';
import 'package:eliud_pkg_create/widgets/style_selection_widget.dart';
import 'package:eliud_pkg_medium/platform/medium_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'logo_widget.dart';
import 'new_app_bloc/action_specification.dart';
import 'new_app_bloc/new_app_state.dart';

typedef BlocProvider BlocProviderProvider(Widget child);

void newApp(
  BuildContext context,
  MemberModel member,
  AppModel app, {
  double? fraction,
}) {
  openFlexibleDialog(
    app,
    context,
    app.documentID! + '/_newapp',
    includeHeading: false,
    widthFraction: fraction == null ? .5 : fraction,
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
    Key? key,
    required this.app,
    required this.widgetWidth,
    required this.widgetHeight,
  }) : super(key: key);

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
  static bool hasAccessToLocalFileSystem =
      AbstractMediumPlatform.platform!.hasAccessToLocalFilesystem();
  var shopActionSpecifications = ShopActionSpecifications(
    requiresAccessToLocalFileSystem: false,
    paymentType: ShopPaymentType.Manual,
    availableInLeftDrawer: true,
    availableInRightDrawer: false,
    availableInAppBar: false,
    availableInHomeMenu: true,
    available: false,
  );
  var welcomeSpecifications = ActionSpecification(
    requiresAccessToLocalFileSystem: false,
    availableInLeftDrawer: true,
    availableInRightDrawer: false,
    availableInAppBar: false,
    availableInHomeMenu: true,
    available: false,
  );
  var blockedSpecifications = ActionSpecification(
    requiresAccessToLocalFileSystem: false,
    availableInLeftDrawer: false,
    availableInRightDrawer: false,
    availableInAppBar: false,
    availableInHomeMenu: false,
    available: true,
  );
  var aboutSpecifications = ActionSpecification(
    requiresAccessToLocalFileSystem: false,
    availableInLeftDrawer: true,
    availableInRightDrawer: false,
    availableInAppBar: false,
    availableInHomeMenu: true,
    available: false,
  );
  var albumSpecifications = ActionSpecification(
    requiresAccessToLocalFileSystem: false,
    availableInLeftDrawer: hasAccessToLocalFileSystem,
    availableInRightDrawer: false,
    availableInAppBar: false,
    availableInHomeMenu: hasAccessToLocalFileSystem,
    available: false,
  );
  var chatSpecifications = ActionSpecification(
    requiresAccessToLocalFileSystem: false,
    availableInLeftDrawer: false,
    availableInRightDrawer: false,
    availableInAppBar: true,
    availableInHomeMenu: false,
    available: false,
  );
  var memberDashboardSpecifications = ActionSpecification(
    requiresAccessToLocalFileSystem: false,
    availableInLeftDrawer: false,
    availableInRightDrawer: true,
    availableInAppBar: false,
    availableInHomeMenu: false,
    available: false,
  );
  var signoutSpecifications = ActionSpecification(
    requiresAccessToLocalFileSystem: false,
    availableInLeftDrawer: false,
    availableInRightDrawer: true,
    availableInAppBar: false,
    availableInHomeMenu: false,
    available: false,
  );
  var signinSpecifications = ActionSpecification(
    requiresAccessToLocalFileSystem: false,
    availableInLeftDrawer: false,
    availableInRightDrawer: false,
    availableInAppBar: true,
    availableInHomeMenu: false,
    available: false,
  );
  var flushSpecifications = ActionSpecification(
    requiresAccessToLocalFileSystem: false,
    availableInLeftDrawer: false,
    availableInRightDrawer: false,
    availableInAppBar: false,
    availableInHomeMenu: false,
    available: false,
  );
  var includeJoinAction = JoinActionSpecifications(
    requiresAccessToLocalFileSystem: false,
    paymentType: JoinPaymentType.Manual,
    availableInLeftDrawer: false,
    availableInRightDrawer: false,
    availableInAppBar: true,
    availableInHomeMenu: false,
    available: false,
  );
  var membershipDashboardDialogSpecifications = JoinActionSpecifications(
    requiresAccessToLocalFileSystem: false,
    paymentType: JoinPaymentType.Manual,
    availableInLeftDrawer: false,
    availableInRightDrawer: false,
    availableInAppBar: true,
    availableInHomeMenu: false,
    available: false,
  );
  var notificationDashboardDialogSpecifications = JoinActionSpecifications(
    requiresAccessToLocalFileSystem: false,
    paymentType: JoinPaymentType.Manual,
    availableInLeftDrawer: false,
    availableInRightDrawer: false,
    availableInAppBar: true,
    availableInHomeMenu: false,
    available: false,
  );
  var assignmentDashboardDialogSpecifications = JoinActionSpecifications(
    requiresAccessToLocalFileSystem: false,
    paymentType: JoinPaymentType.Manual,
    availableInLeftDrawer: false,
    availableInRightDrawer: false,
    availableInAppBar: true,
    availableInHomeMenu: false,
    available: false,
  );

  final Map<String, NewAppWizardParameters> newAppWizardParameterss = {};

  @override
  void initState() {
    for (var wizard in NewAppWizardRegistry.registry().registeredNewAppWizardInfos) {
      var newAppWizardName = wizard.newAppWizardName;
      var newAppWizardParameters = wizard.newAppWizardParameters();
      newAppWizardParameterss[newAppWizardName] = newAppWizardParameters;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewAppCreateBloc, NewAppCreateState>(
        builder: (context, state) {
      if (state is SwitchApp) {
        BlocProvider.of<AccessBloc>(context).add(SwitchAppWithIDEvent(
            appId: state.appToBeCreated.documentID!, goHome: true));
      } else if (state is NewAppCreateInitialised) {
        return Container(
            width: widget.widgetWidth,
            child:
                ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
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
                okAction: (state is NewAppCreateAllowEnterDetails)
                    ? () async {
                        BlocProvider.of<NewAppCreateBloc>(context)
                            .add(NewAppCreateConfirm(
                          logo: state.appToBeCreated.logo,
                          includeWelcome: welcomeSpecifications,
                          includeblocked: blockedSpecifications,
                          aboutPageSpecifications: aboutSpecifications,
                          albumPageSpecifications: albumSpecifications,
                          includeShop: shopActionSpecifications,
                          includeChat: chatSpecifications,
                          includeMemberDashboard: memberDashboardSpecifications,
                          newAppWizardParameters: newAppWizardParameterss,
                          includeSigninButton: signinSpecifications,
                          includeSignoutButton: signoutSpecifications,
                          includeFlushButton: flushSpecifications,
                          includeJoinAction: includeJoinAction,
                          membershipDashboardDialogSpecifications:
                              membershipDashboardDialogSpecifications,
                          notificationDashboardDialogSpecifications:
                              notificationDashboardDialogSpecifications,
                          assignmentDashboardDialogSpecifications:
                              assignmentDashboardDialogSpecifications,
                        ));
                        return false;
                      }
                    : null,
                title: 'Create new App',
              ),
              if (state is NewAppCreateAllowEnterDetails) enterDetails(state),
              if (state is NewAppCreateCreateInProgress) _progress(state),
            ]));
      }
      return progressIndicator(widget.app, context);
    });
  }

  Widget enterDetails(NewAppCreateInitialised state) {
    return ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
      divider(widget.app, context),
      _general(context, state),
      _contents(context, state),
      _logo(context, state.appToBeCreated),
      _inContainer(context, 'Style', [
        StyleSelectionWidget.getIt(context, state.appToBeCreated, false, true, true,
            feedbackSelection: (styleFamily, styleName) {
          state.appToBeCreated.styleFamily = styleFamily;
          state.appToBeCreated.styleName = styleName;
        }),
      ]),
    ]);
  }

  Widget _inContainer(
      BuildContext context, String label, List<Widget> widgets) {
    return topicContainer(widget.app, context,
        title: label, collapsible: true, collapsed: true, children: widgets);
  }

  Widget _logo(BuildContext context, AppModel appModel) {
    return _inContainer(
        context, 'Logo' + (!hasAccessToLocalFileSystem ? ' (not available on web)' : ''), [LogoWidget(app: appModel, collapsed: false)]);
  }

  Widget _general(BuildContext context, NewAppCreateInitialised state) {
    if (state is NewAppCreateAllowEnterDetails) {
      return topicContainer(widget.app, context,
          width: widget.widgetWidth,
          title: 'General',
          collapsible: true,
          collapsed: false,
          children: [
            getListTile(context, widget.app,
                leading: Icon(Icons.vpn_key),
                title: dialogField(
                  widget.app,
                  context,
                  initialValue: state.appToBeCreated.documentID,
                  valueChanged: (value) {
                    state.appToBeCreated.documentID = value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Identifier',
                    labelText: 'Identifier',
                  ),
                )),
            checkboxListTile(
                widget.app,
                context,
                'Auto privilege level 1 for new members?',
                state.appToBeCreated.autoPrivileged1 ?? false,
                    (value) {
                  setState(() {
                    state.appToBeCreated.autoPrivileged1 =
                        value ?? false;
                  });
                }),
          ]);
    } else {
      return text(widget.app, context, 'no contents');
    }
  }

  Widget _progress(NewAppCreateCreateInProgress state) {
    return Container(
        height: 100,
        width: widget.widgetWidth,
        child: progressIndicatorWithValue(widget.app, context,
            value: state.progress));
  }

  Widget _contents(BuildContext context, NewAppCreateInitialised state) {
    var suffix = !hasAccessToLocalFileSystem ? ' (not available on web)' : '';
    List<Widget> children = [
      ActionSpecificationWidget(
          app: widget.app,
          enabled: true,
          actionSpecification: welcomeSpecifications,
          label: 'Generate Welcome Page'),
      ActionSpecificationWidget(
          app: widget.app,
          enabled: true,
          actionSpecification: blockedSpecifications,
          label: 'Generate Page for Blocked members'),
      ActionSpecificationWidget(
          app: widget.app,
          enabled: true,
          actionSpecification: aboutSpecifications,
          label: 'Generate About Page'),
      ActionSpecificationWidget(
          app: widget.app,
          enabled: hasAccessToLocalFileSystem,
          actionSpecification: albumSpecifications,
          label: 'Generate Example Album Page'),
      ActionSpecificationWidget(
          app: widget.app,
          enabled: true,
          actionSpecification: shopActionSpecifications,
          label: 'Generate Shop'),
      ActionSpecificationWidget(
          app: widget.app,
          enabled: true,
          actionSpecification: chatSpecifications,
          label: 'Generate Chat Dialog'),
      ActionSpecificationWidget(
          app: widget.app,
          enabled: true,
          actionSpecification: memberDashboardSpecifications,
          label: 'Generate Member Dashboard Dialog'),
      ActionSpecificationWidget(
          app: widget.app,
          enabled: true,
          actionSpecification: signinSpecifications,
          label: 'Generate signin button'),
      ActionSpecificationWidget(
          app: widget.app,
          enabled: true,
          actionSpecification: signoutSpecifications,
          label: 'Generate signout button'),
      ActionSpecificationWidget(
          app: widget.app,
          enabled: true,
          actionSpecification: flushSpecifications,
          label: 'Generate flush button'),
      ActionSpecificationWidget(
          app: widget.app,
          enabled: true,
          actionSpecification: includeJoinAction,
          label: 'Generate join button'),
      ActionSpecificationWidget(
          app: widget.app,
          enabled: true,
          actionSpecification: membershipDashboardDialogSpecifications,
          label: 'Generate membership dashboard dialog'),
      ActionSpecificationWidget(
          app: widget.app,
          enabled: true,
          actionSpecification: notificationDashboardDialogSpecifications,
          label: 'Generate notification dashboard dialog'),
      ActionSpecificationWidget(
          app: widget.app,
          enabled: true,
          actionSpecification: assignmentDashboardDialogSpecifications,
          label: 'Generate assignment dashboard dialog'),
    ];
    for (var wizard in NewAppWizardRegistry.registry().registeredNewAppWizardInfos) {
      var newAppWizardName = wizard.newAppWizardName;
      var newAppWizardParameters = newAppWizardParameterss[newAppWizardName];
      if (newAppWizardParameters != null) {
        children.add(wizard.wizardParametersWidget(
            widget.app, context, newAppWizardParameters));
      }
    }
    return ListView(shrinkWrap: true, physics: ScrollPhysics(), children: children);
  }
}

class ActionSpecificationWidget extends StatefulWidget {
  final AppModel app;
  final String label;
  final bool enabled;
  final ActionSpecification actionSpecification;

  ActionSpecificationWidget({
    Key? key,
    required this.app,
    required this.label,
    required this.enabled,
    required this.actionSpecification,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ActionSpecificationWidgetState();
  }
}

class _ActionSpecificationWidgetState extends State<ActionSpecificationWidget> {
  @override
  Widget build(BuildContext context) {
    return topicContainer(widget.app, context,
        title: widget.label,
        collapsible: true,
        collapsed: true,
        children: [
          checkboxListTile(
              widget.app,
              context,
              'AppBar',
              widget.actionSpecification.availableInAppBar,
              widget.enabled
                  ? (value) {
                      setState(() {
                        widget.actionSpecification.availableInAppBar =
                            value ?? false;
                      });
                    }
                  : null),
          checkboxListTile(
              widget.app,
              context,
              'Home menu',
              widget.actionSpecification.availableInHomeMenu,
              widget.enabled
                  ? (value) {
                      setState(() {
                        widget.actionSpecification.availableInHomeMenu =
                            value ?? false;
                      });
                    }
                  : null),
          checkboxListTile(
              widget.app,
              context,
              'Left drawer',
              widget.actionSpecification.availableInLeftDrawer,
              widget.enabled
                  ? (value) {
                      setState(() {
                        widget.actionSpecification.availableInLeftDrawer =
                            value ?? false;
                      });
                    }
                  : null),
          checkboxListTile(
              widget.app,
              context,
              'Right drawer',
              widget.actionSpecification.availableInRightDrawer,
              widget.enabled
                  ? (value) {
                      setState(() {
                        widget.actionSpecification.availableInRightDrawer =
                            value ?? false;
                      });
                    }
                  : null),
          checkboxListTile(
              widget.app,
              context,
              'Available (not through menu)',
              widget.actionSpecification.available,
              widget.enabled
                  ? (value) {
                      setState(() {
                        widget.actionSpecification.available = value ?? false;
                      });
                    }
                  : null),
        ]);
  }
}
