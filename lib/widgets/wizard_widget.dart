import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/blocs/access/access_event.dart';
import 'package:eliud_core/core/wizards/registry/action_specification.dart';
import 'package:eliud_core/core/wizards/registry/registry.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'package:eliud_pkg_create/widgets/style_selection_widget.dart';
import 'package:eliud_pkg_create/widgets/wizard_bloc/wizard_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'logo_widget.dart';
import 'wizard_bloc/wizard_event.dart';
import 'wizard_bloc/wizard_state.dart';

typedef BlocProvider BlocProviderProvider(Widget child);

void newWizard(
  BuildContext context,
  MemberModel member,
  AppModel app, {
  double? fraction,
}) {
  openFlexibleDialog(
    app,
    context,
    app.documentID! + '/_wizard',
    includeHeading: false,
    widthFraction: fraction == null ? .5 : fraction,
    child: Container(
        width: 10,
        child: WizardWidget.getIt(
          context,
          member,
          app,
          fullScreenWidth(context) * ((fraction == null) ? .5 : fraction),
          fullScreenHeight(context) - 100,
        )),
  );
}

class WizardWidget extends StatefulWidget {
  final AppModel app;
  final double widgetWidth;
  final double widgetHeight;

  WizardWidget._({
    Key? key,
    required this.app,
    required this.widgetWidth,
    required this.widgetHeight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WizardWidgetState();
  }

  static Widget getIt(BuildContext context, MemberModel member, AppModel app,
      double widgetWidth, double widgetHeight) {
    return BlocProvider<WizardBloc>(
      create: (context) => WizardBloc(app)
        ..add(WizardInitialise(member)),
      child: WizardWidget._(
        app: app,
        widgetWidth: widgetWidth,
        widgetHeight: widgetHeight,
      ),
    );
  }
}

class _WizardWidgetState extends State<WizardWidget> {
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
    return BlocBuilder<WizardBloc, WizardState>(
        builder: (context, state) {
      if (state is WizardSwitchApp) {
        BlocProvider.of<AccessBloc>(context).add(SwitchAppWithIDEvent(
            appId: state.app.documentID!, goHome: true));
      } else if (state is WizardInitialised) {
        return Container(
            width: widget.widgetWidth,
            child:
                ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
              HeaderWidget(
                app: widget.app,
                cancelAction: () async {
                  if (state is WizardCreateInProgress) {
                    BlocProvider.of<WizardBloc>(context)
                        .add(WizardCancelled());
                    return false;
                  } else {
                    return true;
                  }
                },
                okAction: (state is WizardAllowEnterDetails)
                    ? () async {
                        BlocProvider.of<WizardBloc>(context)
                            .add(WizardConfirm(
                          logo: state.app.logo,
                          newAppWizardParameters: newAppWizardParameterss,
                          includeSigninButton: signinSpecifications,
                          includeSignoutButton: signoutSpecifications,
                        ));
                        return false;
                      }
                    : null,
                title: 'Run Wizard',
              ),
              if (state is WizardAllowEnterDetails) enterDetails(state),
              if (state is WizardCreateInProgress) _progress(state),
            ]));
      }
      return progressIndicator(widget.app, context);
    });
  }

  Widget enterDetails(WizardInitialised state) {
    return ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
      divider(widget.app, context),
      _contents(context, state),
      _logo(context, state.app),
      _inContainer(context, 'Style', [
        StyleSelectionWidget.getIt(context, state.app, false, true, true,
            feedbackSelection: (styleFamily, styleName) {
          state.app.styleFamily = styleFamily;
          state.app.styleName = styleName;
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
        context, 'Logo', [LogoWidget(app: appModel, collapsed: false)]);
  }

  Widget _progress(WizardCreateInProgress state) {
    return Container(
        height: 100,
        width: widget.widgetWidth,
        child: progressIndicatorWithValue(widget.app, context,
            value: state.progress));
  }

  Widget _contents(BuildContext context, WizardInitialised state) {
    List<Widget> children = [
      ActionSpecificationWidget(
          app: widget.app,
          enabled: true,
          actionSpecification: signinSpecifications,
          label: 'Generate Sign-in Button'),
      ActionSpecificationWidget(
          app: widget.app,
          enabled: true,
          actionSpecification: signoutSpecifications,
          label: 'Generate Sign-out Button'),
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
