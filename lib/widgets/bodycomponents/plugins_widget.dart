import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bodycomponents__bloc/bodycomponents_create_bloc.dart';
import 'bodycomponents__bloc/bodycomponents_create_event.dart';
import 'bodycomponents__bloc/bodycomponents_create_state.dart';

class PluginsWidget extends StatefulWidget {
  final double widgetWidth;
  final double widgetHeight;
  List<PluginWithComponents> pluginsWidthComponents;

  PluginsWidget({
    Key? key,
    required this.pluginsWidthComponents,
    required this.widgetWidth,
    required this.widgetHeight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PluginsWidgetState();
}

class _PluginsWidgetState extends State<PluginsWidget>
    with TickerProviderStateMixin {
  List<String>? items;
  List<String>? innerItems;
  int selectedItem = 0;
  int selectedInnerItem = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> listItems = [];
    List<Widget> innerListItems = [];

    if (items != null) {
      for (int i = 0; i < items!.length; i++) {
        listItems.add(getListTile(context,
            title: i == selectedItem
                ? highLight1(context, items![i])
                : text(context, items![i]),
            onTap: () => _handleSelection(i)));
      }
    }

    if (innerItems != null) {
      for (int i = 0; i < innerItems!.length; i++) {
        innerListItems.add(getListTile(context,
            title: i == selectedInnerItem
                ? highLight1(context, innerItems![i])
                : text(context, innerItems![i]),
            onTap: () => _handleInnerSelection(i)));
      }
    }

    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          height: widget.widgetHeight,
          width: oneUnitwidth(),
          child: ListView(
              shrinkWrap: true, physics: ScrollPhysics(), children: listItems)),
      verticalDivider(context, widget.widgetHeight),
      Container(
          height: widget.widgetHeight,
          width: oneUnitwidth(),
          child: ListView(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              children: innerListItems)),
      verticalDivider(context, widget.widgetHeight),
      _selector(context),
    ]);
  }

  @override
  void initState() {
    items = widget.pluginsWidthComponents.map((item) => item.name).toList();
    initInnerItems(0);

    super.initState();
  }

  void initInnerItems(int index) {
    innerItems = widget.pluginsWidthComponents[index].componentSpec
        .map((item) => item.name)
        .toList();
  }

  Widget _selector(BuildContext context) {
    var plugin = widget.pluginsWidthComponents[selectedItem];
    if (plugin.componentSpec.length > selectedInnerItem) {
      var component = plugin.componentSpec[selectedInnerItem];
      return Text(component.name);
      return Container(
          height: widget.widgetHeight,
          width: oneUnitwidth() * 2,
          child: component.selector.createSelectWidget(
              context,
              widget.widgetHeight,
                  (componentId) => _selectedItem(componentId),
              component.editor));
    } else {
      return Container(width: oneUnitwidth() * 2,);
    }
  }

  void _selectedItem(String componentId) {
    var plugin = widget.pluginsWidthComponents[selectedItem];
    var component = plugin.componentSpec[selectedInnerItem];
    BlocProvider.of<BodyComponentsCreateBloc>(context).add(
        BodyComponentsCreateAddBodyComponent(BodyComponentModel(
            documentID: newRandomKey(),
            componentName: component.name,
            componentId: componentId)));
  }

  void _handleSelection(int selection) {
    setState(() {
      selectedItem = selection;
      selectedInnerItem = 0;
      initInnerItems(selection);
    });
  }

  void _handleInnerSelection(int innerSelection) {
    setState(() {
      selectedInnerItem = innerSelection;
    });
  }

  double oneUnitwidth() => (widget.widgetWidth - 52) / 4;
}
