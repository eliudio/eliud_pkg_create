import 'package:eliud_core/core/access/bloc/access_bloc.dart';
import 'package:eliud_core/core/access/bloc/access_event.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/style/frontend/has_dialog_field.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/new_app_bloc.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/new_app_event.dart';
import 'package:eliud_pkg_create/widgets/style_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'logo_widget.dart';
import 'new_app_bloc/action_specification.dart';
import 'new_app_bloc/new_app_state.dart';

typedef BlocProvider BlocProviderProvider(Widget child);

void newApp(
  BuildContext context, {
  double? fraction,
}) {
  openFlexibleDialog(
    context,
    includeHeading: false,
    widthFraction: fraction == null ? .5 : fraction,
    child: Container(
        width: 10,
        child: NewAppCreateWidget.getIt(
          context,
          fullScreenWidth(context) * ((fraction == null) ? .5 : fraction),
          fullScreenHeight(context) - 100,
        )),
  );
}

class NewAppCreateWidget extends StatefulWidget {
  final double widgetWidth;
  final double widgetHeight;

  NewAppCreateWidget._({
    Key? key,
    required this.widgetWidth,
    required this.widgetHeight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NewAppCreateWidgetState();
  }

  static Widget getIt(
      BuildContext context, double widgetWidth, double widgetHeight) {
    var member = AccessBloc.member(context);
    if (member != null) {
      return BlocProvider<NewAppCreateBloc>(
        create: (context) => NewAppCreateBloc()
          ..add(NewAppCreateEventInitialise('YOUR_APP_ID', member)),
        child: NewAppCreateWidget._(
          widgetWidth: widgetWidth,
          widgetHeight: widgetHeight,
        ),
      );
    } else {
      return text(context, "Member should be logged on");
    }
  }
}

class _NewAppCreateWidgetState extends State<NewAppCreateWidget> {
  var shopActionSpecifications = ShopActionSpecifications(
    paymentType: ShopPaymentType.Card,
    availableInLeftDrawer: true,
    availableInRightDrawer: false,
    availableInAppBar: false,
    availableInHomeMenu: true,
    available: false,
  );
  var welcomeSpecifications = ActionSpecification(
    availableInLeftDrawer: true,
    availableInRightDrawer: false,
    availableInAppBar: false,
    availableInHomeMenu: true,
    available: false,
  );
  var blockedSpecifications = ActionSpecification(
    availableInLeftDrawer: false,
    availableInRightDrawer: false,
    availableInAppBar: false,
    availableInHomeMenu: false,
    available: true,
  );
  var aboutSpecifications = ActionSpecification(
    availableInLeftDrawer: true,
    availableInRightDrawer: false,
    availableInAppBar: false,
    availableInHomeMenu: true,
    available: false,
  );
  var feedSpecifications = ActionSpecification(
    availableInLeftDrawer: true,
    availableInRightDrawer: false,
    availableInAppBar: false,
    availableInHomeMenu: true,
    available: false,
  );
  var chatSpecifications = ActionSpecification(
    availableInLeftDrawer: false,
    availableInRightDrawer: false,
    availableInAppBar: true,
    availableInHomeMenu: false,
    available: false,
  );
  var memberDashboardSpecifications = ActionSpecification(
    availableInLeftDrawer: false,
    availableInRightDrawer: true,
    availableInAppBar: false,
    availableInHomeMenu: false,
    available: false,
  );
  var examplePolicySpecifications = ActionSpecification(
    availableInLeftDrawer: true,
    availableInRightDrawer: false,
    availableInAppBar: false,
    availableInHomeMenu: false,
    available: false,
  );
  var signoutSpecifications = ActionSpecification(
    availableInLeftDrawer: false,
    availableInRightDrawer: true,
    availableInAppBar: false,
    availableInHomeMenu: false,
    available: false,
  );
  var flushSpecifications = ActionSpecification(
    availableInLeftDrawer: false,
    availableInRightDrawer: false,
    availableInAppBar: false,
    availableInHomeMenu: false,
    available: false,
  );
  var includeJoinAction = JoinActionSpecifications(
    paymentType: JoinPaymentType.Card,
    availableInLeftDrawer: false,
    availableInRightDrawer: false,
    availableInAppBar: true,
    availableInHomeMenu: false,
    available: false,
  );
  var membershipDashboardDialogSpecifications = JoinActionSpecifications(
    paymentType: JoinPaymentType.Card,
    availableInLeftDrawer: false,
    availableInRightDrawer: false,
    availableInAppBar: true,
    availableInHomeMenu: false,
    available: false,
  );
  var notificationDashboardDialogSpecifications = JoinActionSpecifications(
    paymentType: JoinPaymentType.Card,
    availableInLeftDrawer: false,
    availableInRightDrawer: false,
    availableInAppBar: true,
    availableInHomeMenu: false,
    available: false,
  );
  var assignmentDashboardDialogSpecifications = JoinActionSpecifications(
    paymentType: JoinPaymentType.Card,
    availableInLeftDrawer: false,
    availableInRightDrawer: false,
    availableInAppBar: true,
    availableInHomeMenu: false,
    available: false,
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewAppCreateBloc, NewAppCreateState>(
        builder: (context, state) {
      if (state is SwitchApp) {
        BlocProvider.of<AccessBloc>(context)
            .add(SwitchAppEvent(state.appToBeCreated.documentID));
      } else if (state is NewAppCreateInitialised) {
        return Container(
            width: widget.widgetWidth,
            child:
                ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
              HeaderWidget(
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
                          includeShop: shopActionSpecifications,
                          includeChat: chatSpecifications,
                          includeFeed: feedSpecifications,
                          includeMemberDashboard: memberDashboardSpecifications,
                          includeExamplePolicy: examplePolicySpecifications,
                          includeSignoutButton: signoutSpecifications,
                          includeFlushButton: flushSpecifications,
                          includeJoinAction: includeJoinAction,
                          membershipDashboardDialogSpecifications: membershipDashboardDialogSpecifications,
                          notificationDashboardDialogSpecifications: notificationDashboardDialogSpecifications,
                          assignmentDashboardDialogSpecifications: assignmentDashboardDialogSpecifications,
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
      return progressIndicator(context);
    });
  }

  Widget enterDetails(NewAppCreateInitialised state) {
    return ListView(shrinkWrap: true, physics: ScrollPhysics(),
        children: [
        divider(context),
        _general(context, state),
        _contents(context, state),
        _logo(state.appToBeCreated),
        StyleSelectionWidget.getIt(
            context, state.appToBeCreated, false, true),
      ]
    )   ;
  }

  Widget _logo(AppModel appModel) {
    return LogoWidget(appModel: appModel, collapsed: false);
  }

  Widget _general(BuildContext context, NewAppCreateInitialised state) {
    if (state is NewAppCreateAllowEnterDetails) {
      return topicContainer(context,
          width: widget.widgetWidth,
          title: 'General',
          collapsible: true,
          collapsed: false,
          children: [
            getListTile(context,
                leading: Icon(Icons.vpn_key),
                title: dialogField(
                  context,
                  initialValue: state.appToBeCreated.documentID,
                  valueChanged: (value) {
                    state.appToBeCreated.documentID = value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Identifier',
                    labelText: 'Identifier',
                  ),
                ))
          ]);
    } else {
      return text(context, 'no contents');
    }
  }

  Widget _progress(NewAppCreateCreateInProgress state) {
    return Container(
        height: 100,
        width: widget.widgetWidth,
        child: progressIndicatorWithValue(context, value: state.progress));
  }

  Widget _contents(BuildContext context, NewAppCreateInitialised state) {
    return ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
      ActionSpecificationWidget(
          enabled: true,
          actionSpecification: welcomeSpecifications,
          label: 'Generate Welcome Page'),
      ActionSpecificationWidget(
          enabled: true,
          actionSpecification: blockedSpecifications,
          label: 'Generate Page for Blocked members'),
      ActionSpecificationWidget(
          enabled: true,
          actionSpecification: aboutSpecifications,
          label: 'Generate About Page'),
      ActionSpecificationWidget(
          enabled: true,
          actionSpecification: shopActionSpecifications,
          label: 'Generate Shop'),
      ActionSpecificationWidget(
          enabled: true,
          actionSpecification: feedSpecifications, label: 'Generate Feed'),

      ActionSpecificationWidget(
          enabled: true,
          actionSpecification: chatSpecifications,
          label: 'Generate Chat Dialog '),
      ActionSpecificationWidget(
          enabled: true,
          actionSpecification: memberDashboardSpecifications,
          label: 'Generate Member Dashboard Dialog'),

      ActionSpecificationWidget(
          enabled: true,
          actionSpecification: examplePolicySpecifications,
          label: 'Generate Example Policy'),

      ActionSpecificationWidget(
          enabled: true,
          actionSpecification: signoutSpecifications,
          label: 'Generate signout button'),
      ActionSpecificationWidget(
          enabled: true,
          actionSpecification: flushSpecifications,
          label: 'Generate flush button'),
      ActionSpecificationWidget(
          enabled: true,
          actionSpecification: includeJoinAction,
          label: 'Generate join button'),
      ActionSpecificationWidget(
          enabled: true,
          actionSpecification: membershipDashboardDialogSpecifications,
          label: 'Generate membership dashboard dialog'),
      ActionSpecificationWidget(
          enabled: true,
          actionSpecification: notificationDashboardDialogSpecifications,
          label: 'Generate notification dashboard dialog'),
      ActionSpecificationWidget(
          enabled: true,
          actionSpecification: assignmentDashboardDialogSpecifications,
          label: 'Generate assignment dashboard dialog'),
    ]);
  }
}

class ActionSpecificationWidget extends StatefulWidget {
  final String label;
  final bool enabled;
  final ActionSpecification actionSpecification;

  ActionSpecificationWidget({
    Key? key,
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
    return topicContainer(context,
        title: widget.label,
        collapsible: true,
        collapsed: true,
        children: [
          checkboxListTile(
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
