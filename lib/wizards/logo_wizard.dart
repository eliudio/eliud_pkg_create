import 'package:eliud_core/core/wizards/registry/registry.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_pkg_create/widgets/logo_widget.dart';
import 'package:flutter/material.dart';

class LogoWizard extends NewAppWizardInfoDefaultImpl {
  LogoWizard()
      : super(
          'logo',
          'Logo',
        );

  @override
  NewAppWizardParameters newAppWizardParameters() => LogoParameters();

  @override
  Widget wizardParametersWidget(
      AppModel app, BuildContext context, NewAppWizardParameters parameters) {
    if (parameters is LogoParameters) {
      return _LogoWizardWidget(app: app, parameters: parameters);
    } else {
      return text(app, context,
          'Unexpected class for parameters: ' + parameters.toString());
    }
  }

  @override
  PublicMediumModel? getPublicMediumModel(
      String uniqueId, NewAppWizardParameters parameters, String pageType) {
    if (parameters is LogoParameters) {
      if (pageType == 'logo') return parameters.logo;
    }
    return null;
  }

  @override
  String getPackageName() => "eliud_pkg_create";
}

class LogoParameters extends NewAppWizardParameters {
  PublicMediumModel? logo;

  LogoParameters();
}

class _LogoWizardWidget extends StatefulWidget {
  final AppModel app;
  final LogoParameters parameters;

  const _LogoWizardWidget(
      {Key? key, required this.app, required this.parameters})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _LogoWizardWidgetState();
}

class _LogoWizardWidgetState extends State<_LogoWizardWidget> {
  @override
  Widget build(BuildContext context) => LogoWidget(
    isCollapsable: false,
      app: widget.app,
      logo: widget.parameters.logo,
      collapsed: false,
      logoFeedback: (newLogo) {
        setState(() {
          widget.parameters.logo = newLogo;
        });
      });
}
