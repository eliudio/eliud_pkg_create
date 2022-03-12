import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/blocs/access/access_event.dart';
import 'package:eliud_core/core/wizards/registry/action_specification.dart';
import 'package:eliud_core/core/wizards/registry/registry.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'package:eliud_pkg_create/widgets/style_selection_widget.dart';
import 'package:eliud_pkg_create/widgets/wizard_bloc/wizard_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    includeHeading: true,
    widthFraction: fraction == null ? .5 : fraction,
    title: 'Run Wizard',
    buttons: [
      dialogButton(app, context, label: 'Close', onPressed: () {
        Navigator.of(context).pop();

        // the wizard might have created a new home page. Go home
        var accessBloc = BlocProvider.of<AccessBloc>(context);
        accessBloc.add(GoHome(app: app, redetermine: true));
      }),
    ],
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
    var accessBloc = BlocProvider.of<AccessBloc>(context);
    return BlocProvider<WizardBloc>(
      create: (context) => WizardBloc(
        app,
        accessBloc,
      )..add(WizardInitialise(member)),
      child: WizardWidget._(
        app: app,
        widgetWidth: widgetWidth,
        widgetHeight: widgetHeight,
      ),
    );
  }
}

class CurrentActiveWizardData {
  final NewAppWizardInfo wizard;
  final String wizardName;
  final NewAppWizardParameters parameters;

  CurrentActiveWizardData(this.wizard, this.wizardName, this.parameters);
}

class _WizardWidgetState extends State<WizardWidget> {
  var autoPrivileged1 = true;
  String? styleFamily;
  String? styleName;
  CurrentActiveWizardData? currentActiveWizardData = null;

  final Map<String, NewAppWizardParameters> newAppWizardParameterss = {};

  @override
  void initState() {
    for (var wizard
        in NewAppWizardRegistry.registry().registeredNewAppWizardInfos) {
      var newAppWizardName = wizard.newAppWizardName;
      var newAppWizardParameters = wizard.newAppWizardParameters();
      newAppWizardParameterss[newAppWizardName] = newAppWizardParameters;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WizardBloc, WizardState>(builder: (context, state) {
      if (state is WizardInitialised) {
        return Container(
            width: widget.widgetWidth,
            child:
                ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
              _contents(context, state),
              if (state is WizardCreateInProgress) _progress(state),
              if (!(state is WizardCreateInProgress))
                _currentActiveWizard(),
              if (state is WizardCreated) _finished(state)
            ]));
      }
      return progressIndicator(widget.app, context);
    });
  }

  Widget _progress(WizardCreateInProgress state) {
    return Container(
        height: 100,
        width: widget.widgetWidth,
        child: progressIndicatorWithValue(widget.app, context,
            value: state.progress));
  }

  Widget _finished(WizardCreated state) {
    return Container();
/*
    return ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
      divider(
        widget.app,
        context,
      ),
      Center(
          child: text(
              widget.app,
              context,
              state.wizardMessage +
                  ' finished' +
                  (state.success ? 'with success' : ', but failed')))
    ]);
*/
  }

  Widget _currentActiveWizard() {
    if (currentActiveWizardData != null) {
      return ListView(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        children: [
          currentActiveWizardData!.wizard.wizardParametersWidget(
              widget.app, context, currentActiveWizardData!.parameters),
          divider(
            widget.app,
            context,
          ),
          Center(
              child: button(widget.app, context, label: 'Go!', onPressed: () {
            Map<String, NewAppWizardParameters> theAppWizardParameters = {};
            theAppWizardParameters[currentActiveWizardData!.wizardName] =
                currentActiveWizardData!.parameters;
            BlocProvider.of<WizardBloc>(context).add(WizardConfirm(
              wizardMessage: currentActiveWizardData!.wizardName,
              newAppWizardParameters: theAppWizardParameters,
              autoPrivileged1: autoPrivileged1,
              styleFamily: styleFamily,
              styleName: styleName,
            ));
            currentActiveWizardData = null;
          })),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _contents(BuildContext context, WizardInitialised state) {
    List<Widget> children = [
/*
todo: create wizard for these 2:
      topicContainer(widget.app, context,
          title: 'Set Auto privilege',
          collapsible: true,
          collapsed: true,
          children: [
            checkboxListTile(
                widget.app,
                context,
                'Auto privilege level 1 for new members?',
                autoPrivileged1, (value) {
              setState(() {
                autoPrivileged1 = value ?? false;
              });
            }),
          ]),
      StyleSelectionWidget.getIt(context, state.app, false, true, true,
          feedbackSelection: (newStyleFamily, newStyleName) {
        styleFamily = newStyleFamily;
        styleName = newStyleName;
      }),
*/
    ];
    for (var wizard
        in NewAppWizardRegistry.registry().registeredNewAppWizardInfos) {
      var newAppWizardName = wizard.newAppWizardName;
      var newAppWizardParameters = newAppWizardParameterss[newAppWizardName];
      if (newAppWizardParameters != null) {
        children.add(
            button(widget.app, context, label: newAppWizardName, onPressed: () {
          setState(() {
            currentActiveWizardData = CurrentActiveWizardData(
                wizard, newAppWizardName, newAppWizardParameters);
          });
        }));
      }
    }
    return Center(child: Wrap(children: children));
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
