import 'dart:math';

import 'package:eliud_core/core/registry.dart';
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_pkg_create/widgets/bodycomponents/plugins_widget.dart';
import 'package:eliud_pkg_create/tools/help_functions.dart';
import 'package:eliud_pkg_create/widgets/utils/popup_menu_item_choices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/core/access/bloc/access_bloc.dart';
import 'package:flutter/widgets.dart';
import 'bodycomponents__bloc/bodycomponents_create_bloc.dart';
import 'bodycomponents__bloc/bodycomponents_create_event.dart';
import 'bodycomponents__bloc/bodycomponents_create_state.dart';

class BodyComponentsCreateWidget extends StatefulWidget {
  final double widgetWidth;

  BodyComponentsCreateWidget._({
    Key? key,
    required this.widgetWidth,

  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BodyComponentsCreateWidgetState();
  }

  static Widget getIt(
      BuildContext context,
      List<BodyComponentModel> bodyComponents,
      double widgetWidth,
      /*double widgetHeight
      */) {
    var app = AccessBloc.app(context);
    if (app == null) throw Exception("No app selected");
    return BlocProvider<BodyComponentsCreateBloc>(
      create: (context) => BodyComponentsCreateBloc(
        app,
        bodyComponents,
      )..add(BodyComponentsCreateInitialiseEvent(bodyComponents)),
      child: BodyComponentsCreateWidget._(
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
    var app = AccessBloc.app(context);
    if (app == null) throw Exception("No app");
    return BlocBuilder<BodyComponentsCreateBloc, BodyComponentsCreateState>(
        builder: (context, state) {
      if (state is BodyComponentsCreateInitialised) {
        currentVisible = GlobalKey();
        ensureCurrentIsVisible();
        int count = 0;
        int size = state.bodyComponentModels.length;
        return Column(
          children: [
            topicContainer(context,
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
                            var theKey;
                            if (item == state.currentlySelected)
                              theKey = currentVisible;
                            count++;
                            return getListTile(context,
                                key: theKey,
                                onTap: () => details(context, item),
                                trailing: PopupMenuItemChoices(
                                  isFirst: (count != 1),
                                  isLast: (count != size),
                                  actionUp: () =>
                                      BlocProvider.of<BodyComponentsCreateBloc>(
                                              context)
                                          .add(BodyComponentsMoveItem(
                                              item, MoveItemDirection.Up)),
                                  actionDown: () =>
                                      BlocProvider.of<BodyComponentsCreateBloc>(
                                              context)
                                          .add(BodyComponentsMoveItem(
                                              item, MoveItemDirection.Down)),
                                  actionDetails: () => details(context, item),
                                  actionDelete: () => BlocProvider.of<
                                          BodyComponentsCreateBloc>(context)
                                      .add(BodyComponentsCreateDeleteMenuItem(
                                          item)),
                                ),
                                title: text(
                                    context,
                                    item.componentName! +
                                        " - " +
                                        item.componentId!));
                          }).toList())))
                ]),
            topicContainer(context,
                title: 'Available components',
                collapsible: true,
                collapsed: true,
                children: [
                  PluginsWidget(
                    widgetHeight: 200, //max(heightUnit() * 2, 150) - 10,
                    widgetWidth: widget.widgetWidth,
                    pluginsWidthComponents: state.pluginWithComponents,
                  )
                ]),
          ],
        );
      } else {
        return progressIndicator(context);
      }
    });
  }

  void details(BuildContext context, BodyComponentModel bodyComponentModel) {
    updateComponent(context, bodyComponentModel.componentName,
        bodyComponentModel.componentId, (_) {});
  }

  void ensureCurrentIsVisible() {
    if (currentVisible != null) {
      if (WidgetsBinding.instance != null) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          var context = currentVisible!.currentContext;
          if (context != null) {
            Scrollable.ensureVisible(context);
          }
        });
      }
    }
  }

}
