import 'package:eliud_core_main/model/app_model.dart';
import 'package:eliud_core_main/model/body_component_model.dart';
import 'package:eliud_core_main/apis/style/frontend/has_container.dart';
import 'package:eliud_core_main/apis/style/frontend/has_list_tile.dart';
import 'package:eliud_core_main/apis/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/tools/component_title_helper.dart';
import 'package:eliud_core_main/tools/component/update_component.dart';
import 'package:eliud_pkg_create/widgets/bodycomponents/plugins_widget.dart';
import 'package:eliud_pkg_create/widgets/utils/popup_menu_item_choices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart';
import 'bodycomponents__bloc/bodycomponents_create_bloc.dart';
import 'bodycomponents__bloc/bodycomponents_create_event.dart';
import 'bodycomponents__bloc/bodycomponents_create_state.dart';

class BodyComponentsCreateWidget extends StatefulWidget {
  final int containerPrivilege;
  final double widgetWidth;
  final AppModel app;

  BodyComponentsCreateWidget._({
    required this.containerPrivilege,
    required this.app,
    required this.widgetWidth,
  });

  @override
  State<StatefulWidget> createState() {
    return _BodyComponentsCreateWidgetState();
  }

  static Widget getIt(
    BuildContext context,
    int containerPrivilege,
    AppModel app,
    List<BodyComponentModel> bodyComponents,
    double widgetWidth,
    /*double widgetHeight
      */
  ) {
//    if (app == null) throw Exception("No app selected");
    return BlocProvider<BodyComponentsCreateBloc>(
      create: (context) => BodyComponentsCreateBloc(
        app,
        bodyComponents,
      )..add(BodyComponentsCreateInitialiseEvent(bodyComponents)),
      child: BodyComponentsCreateWidget._(
        app: app,
        containerPrivilege: containerPrivilege,
        widgetWidth: widgetWidth,
      ),
    );
  }
}

class _BodyComponentsCreateWidgetState extends State<BodyComponentsCreateWidget>
    with SingleTickerProviderStateMixin {
  final int active = 0;
  GlobalKey? currentVisible = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BodyComponentsCreateBloc, BodyComponentsCreateState>(
        builder: (context, state) {
      if (state is BodyComponentsCreateInitialised) {
        currentVisible = GlobalKey();
        ensureCurrentIsVisible();
        int count = 0;
        int size = state.bodyComponentModels.length;
        return Column(
          children: [
            topicContainer(widget.app, context,
                title: 'Components',
                collapsible: true,
                collapsed: true,
                children: [
                  Container(
                      height: 200, //heightUnit() * 1,
                      width: widget.widgetWidth,
                      child: SingleChildScrollView(
                          physics: ScrollPhysics(),
                          child: Column(
                              children: state.bodyComponentModels.map((item) {
                            GlobalKey<State<StatefulWidget>>? theKey;
                            if (item == state.currentlySelected) {
                              theKey = currentVisible;
                            }
                            count++;
                            return getListTile(context, widget.app,
                                key: theKey,
                                onTap: () => details(context, item),
                                trailing: PopupMenuItemChoices(
                                  app: widget.app,
                                  isFirst: (count != 1),
                                  isLast: (count != size),
                                  actionUp: () =>
                                      BlocProvider.of<BodyComponentsCreateBloc>(
                                              context)
                                          .add(BodyComponentsMoveItem(
                                              item, MoveItemDirection.up)),
                                  actionDown: () =>
                                      BlocProvider.of<BodyComponentsCreateBloc>(
                                              context)
                                          .add(BodyComponentsMoveItem(
                                              item, MoveItemDirection.down)),
                                  actionDetails: () => details(context, item),
                                  actionDelete: () => BlocProvider.of<
                                          BodyComponentsCreateBloc>(context)
                                      .add(BodyComponentsCreateDeleteMenuItem(
                                          item)),
                                ),
                                title: ComponentTitleHelper.title(
                                    context,
                                    widget.app,
                                    item.componentName!,
                                    item.componentId!));
                          }).toList())))
                ]),
            topicContainer(widget.app, context,
                title: 'Available components',
                collapsible: true,
                collapsed: true,
                children: [
                  PluginsWidget(
                    app: widget.app,
                    widgetHeight: 200, //max(heightUnit() * 2, 150) - 10,
                    widgetWidth: widget.widgetWidth,
                    containerPrivilege: widget.containerPrivilege,
                    pluginsWidthComponents: state.pluginWithComponents,
                  )
                ]),
          ],
        );
      } else {
        return progressIndicator(widget.app, context);
      }
    });
  }

  void details(BuildContext context, BodyComponentModel bodyComponentModel) {
    updateComponent(context, widget.app, bodyComponentModel.componentName,
        bodyComponentModel.componentId, (_, __) {});
  }

  void ensureCurrentIsVisible() {
    if (currentVisible != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        var context = currentVisible!.currentContext;
        if (context != null) {
          Scrollable.ensureVisible(context);
        }
      });
    }
  }
}
