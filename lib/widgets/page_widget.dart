import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/style/frontend/has_dialog_field.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_core/tools/widgets/editor/page_layout_widget.dart';
import 'package:eliud_core/tools/widgets/grid_view/select_grid_view_widget.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'package:eliud_pkg_create/widgets/page_bloc/page_bloc.dart';
import 'package:eliud_pkg_create/widgets/page_bloc/page_event.dart';
import 'package:eliud_pkg_create/widgets/page_bloc/page_state.dart';
import 'package:eliud_pkg_create/widgets/privilege_widget.dart';
import 'package:eliud_pkg_create/widgets/utils/models_json_bloc/models_json_bloc.dart';
import 'package:eliud_pkg_create/widgets/utils/models_json_bloc/models_json_event.dart';
import 'package:eliud_pkg_create/widgets/utils/models_json_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../jsontomodeltojson/modeltojsonhelper.dart';
import 'bodycomponents/bodycomponents_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'condition/storage_conditions_widget.dart';

void openPage(BuildContext context, AppModel app, bool create, PageModel model,
    String title,
    {double? fraction}) {
  openFlexibleDialog(
    app,
    context,
    app.documentID + '/_page',
    includeHeading: false,
    widthFraction: fraction,
    child: PageCreateWidget.getIt(
      context,
      app,
      model,
      create,
      fullScreenWidth(context) * (fraction ?? 1),
      //fullScreenHeight(context) - 100,
    ),
  );
}

class PageCreateWidget extends StatefulWidget {
  final double widgetWidth;
  final bool create;
  final AppModel app;

  PageCreateWidget._({
    Key? key,
    required this.app,
    required this.create,
    required this.widgetWidth,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageCreateWidgetState();
  }

  static Widget getIt(
    BuildContext context,
    AppModel app,
    PageModel pageModel,
    bool create,
    double widgetWidth,
  ) {
    var accessBloc = BlocProvider.of<AccessBloc>(context);
    return BlocProvider<PageCreateBloc>(
      create: (context) => PageCreateBloc(
        app,
        accessBloc,
      )..add(PageCreateEventValidateEvent(pageModel)),
      child: PageCreateWidget._(
        app: app,
        create: create,
        widgetWidth: widgetWidth,
      ),
    );
  }
}

class _PageCreateWidgetState extends State<PageCreateWidget> {
  @override
  Widget build(BuildContext context) {
    // Don't know:
    // layout
    // gridview
    // widgetWrapper

    var member = AccessBloc.member(context);

    return BlocBuilder<PageCreateBloc, PageCreateState>(
        builder: (context, state) {
      if (state is PageCreateValidated) {
        return ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
          HeaderWidget(
            app: widget.app,
            cancelAction: () async {
              return true;
            },
            okAction: () async {
              BlocProvider.of<PageCreateBloc>(context)
                  .add(PageCreateEventApplyChanges(true));
              return true;
            },
            title: widget.create
                ? 'Create new page'
                : 'Change page ' + state.pageModel.documentID,
          ),
          divider(widget.app, context),
          topicContainer(widget.app, context,
              title: 'General',
              collapsible: true,
              collapsed: true,
              children: [
                getListTile(context, widget.app,
                    leading: Icon(Icons.vpn_key),
                    title: widget.create
                        ? dialogField(
                            widget.app,
                            context,
                            initialValue: state.pageModel.documentID,
                            valueChanged: (value) {
                              state.pageModel.documentID = value;
                            },
                            readOnly: !widget.create,
                            decoration: const InputDecoration(
                              hintText: 'Identifier',
                              labelText: 'Identifier',
                            ),
                          )
                        : text(
                            widget.app, context, state.pageModel.documentID)),
                getListTile(context, widget.app,
                    leading: Icon(Icons.description),
                    title: dialogField(
                      widget.app,
                      context,
                      initialValue: state.pageModel.description,
                      valueChanged: (value) {
                        state.pageModel.description = value;
                      },
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Description',
                        labelText: 'Description',
                      ),
                    )),
                getListTile(context, widget.app,
                    leading: Icon(Icons.description),
                    title: dialogField(
                      widget.app,
                      context,
                      initialValue: state.pageModel.title,
                      valueChanged: (value) {
                        state.pageModel.title = value;
                      },
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        labelText: 'Title',
                      ),
                    )),
              ]),
          topicContainer(widget.app, context,
              title: 'Layout',
              collapsible: true,
              collapsed: true,
              children: [
//                BackgroundWidget(app: widget.app, label: 'Background override', value: state.pageModel.backgroundOverride, memberId: memberId);
                PageLayoutWidget(
                  app: widget.app,
                  pageLayoutCallback: (PageLayout pageLayout) {
                    setState(() {
                      state.pageModel.layout = pageLayout;
                    });
                  },
                  pageLayout: state.pageModel.layout ?? PageLayout.ListView,
                ),
                if (state.pageModel.layout == PageLayout.GridView)
                  selectGridViewWidget(
                      context,
                      widget.app,
                      state.pageModel.conditions,
                      state.pageModel.gridView, (newGridView) {
                    setState(() {
                      state.pageModel.gridView = newGridView;
                    });
                  }),
              ]),
          BodyComponentsCreateWidget.getIt(
            context,
            ((state.pageModel.conditions == null) ||
                    (state.pageModel.conditions!.privilegeLevelRequired ==
                        null))
                ? 0
                : state.pageModel.conditions!.privilegeLevelRequired!.index,
            widget.app,
            state.pageModel.bodyComponents!,
            widget.widgetWidth,
          ),
          StorageConditionsWidget(
              app: widget.app,
              value: state.pageModel.conditions!,
              ownerType: 'page',
              feedback: (_) {
                setState(() {});
              }),
          if (member == null)
            text(widget.app, context,
                "Not logged on, hence can't copy the widget to member medium"),
          if (member != null)
            ModelsJsonWidget.getIt(
                context,
                widget.app,
                () => getModelsJsonConstructJsonEventToClipboard(
                    widget.app.documentID, state),
                (baseName) =>
                    getModelsJsonConstructJsonEventToMemberMediumModel(
                        widget.app.documentID, state, member, baseName),
                getFilename(state)),
        ]);
      } else {
        return progressIndicator(widget.app, context);
      }
    });
  }

  String getFilename(PageCreateValidated state) =>
      getJsonFilename(state.pageModel.documentID, 'page');

  ModelsJsonConstructJsonEventToClipboard
      getModelsJsonConstructJsonEventToClipboard(
          String appId, PageCreateInitialised pageCreateInitialised) {
    List<AbstractModelWithInformation> data = [];
    return ModelsJsonConstructJsonEventToClipboard(
        () => getTasks(appId, pageCreateInitialised, data), data);
  }

  ModelsJsonConstructJsonEventToMemberMediumModel
      getModelsJsonConstructJsonEventToMemberMediumModel(
          String appId,
          PageCreateInitialised pageCreateInitialised,
          MemberModel member,
          String baseName) {
    List<AbstractModelWithInformation> data = [];
    return ModelsJsonConstructJsonEventToMemberMediumModel(
        () => getTasks(appId, pageCreateInitialised, data),
        data,
        member,
        baseName);
  }

  Future<List<ModelsJsonTask>> getTasks(
      String appId,
      PageCreateInitialised pageCreateInitialised,
      List<AbstractModelWithInformation> data) async {
    return ModelsToJsonHelper.getTasksForPage(
        appId, pageCreateInitialised.pageModel, data);
  }
}
