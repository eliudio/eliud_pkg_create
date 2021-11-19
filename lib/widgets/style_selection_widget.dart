import 'dart:convert';

import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_dialog.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/style/style.dart';
import 'package:eliud_core/style/style_family.dart';
import 'package:eliud_core/style/style_registry.dart';
import 'package:eliud_core/tools/widgets/header_widget.dart';
import 'new_app_bloc/new_app_state.dart';
import 'style_selection_bloc/style_selection_bloc.dart';
import 'style_selection_bloc/style_selection_event.dart';
import 'style_selection_bloc/style_selection_state.dart';
import 'style_selection_bloc/style_selection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StyleSelectionWidget extends StatefulWidget {
  static double SIZE_SMALL = 15;
  static double SIZE_BIG = 18;

  final bool withHeader;
  final bool collapsed;

  StyleSelectionWidget._(this.withHeader, this.collapsed);

  _StyleSelectionWidgetState createState() => _StyleSelectionWidgetState();

  static Widget getIt(BuildContext context, AppModel app, bool withHeader, bool collapsed,) {
    return BlocProvider<StyleSelectionBloc>(
      create: (context) => StyleSelectionBloc(app)
        ..add(InitialiseStyleSelectionEvent(
            family: app.styleFamily, styleName: app.styleName)),
      child: StyleSelectionWidget._(withHeader, collapsed),
    );
  }
}

class _StyleSelectionWidgetState extends State<StyleSelectionWidget> {
  _StyleSelectionWidgetState();

  Widget _getStyleFamilies(List<StyleFamily> childDocuments,
      Style? currentlySelected) {
    return Container(
      margin: EdgeInsets.only(left: 8),
      child: ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: childDocuments.length,
        itemBuilder: (context, position) {
          var styleFamily = childDocuments[position];
          var isCurrent = currentlySelected != null &&
              currentlySelected.styleFamily == styleFamily;
          List<Widget> buttons = _getStyles(styleFamily.styles.values.toList(), currentlySelected);
          if (styleFamily.canInsert) {
            buttons.add(ListTile(
              leading: Icon(Icons.add),
              title: GestureDetector(
                  child: text(
                    context,
                    'Add',
                  ),
                  onTap: () {
                    // todo:
                    // ask for the name of the new style (search for 'Provide new name for copy of style' below)
                    // add a InsertNewStyle to the bloc
                    // deal with this in the bloc i.e.:
                    // use the styleFamily.defaultNew(new name)
                    // use the style.update(context) to update the style
                  }),
              subtitle: text(context, "Add a new style"),
            ));
          }
          return ExpansionTile(
            iconColor: Colors.black,
            collapsedIconColor: Colors.black,
            title: isCurrent
                ? highLight1(context, '${childDocuments[position].familyName}')
                : text(context, '${childDocuments[position].familyName}'),
            onExpansionChanged: (value) {
              setState(() {});
            },
            children: buttons,
            leading: Icon(
              (Icons.circle),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _getStyles(List<Style> childDocuments, Style? currentlySelected) {
    return childDocuments.map((style) {
      var isCurrent = currentlySelected != null && currentlySelected == style;
      return ListTile(
          leading: Icon(Icons.arrow_right_alt),
          title: PopupMenuButton<int>(
              child: isCurrent
                  ? highLight1(context, '${style.styleName}')
                  : text(context, '${style.styleName}'),
              elevation: 10,
              itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Text(
                          style.styleFamily.familyName +
                              ' - ' +
                              style.styleName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: StyleSelectionWidget.SIZE_SMALL)),
                    ),
                    PopupMenuDivider(
                      height: 10,
                    ),
                    PopupMenuItem(
                      value: 1,
                      child: Text("Select style",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: StyleSelectionWidget.SIZE_SMALL)),
                    ),
                    if (style.allowedUpdates.canUpdate)
                      PopupMenuItem(
                          value: 2,
                          child: Text("Update style",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: StyleSelectionWidget.SIZE_SMALL))),
                    if (style.allowedUpdates.canCopy)
                      PopupMenuItem(
                          value: 3,
                          child: Text("Copy style",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: StyleSelectionWidget.SIZE_SMALL))),
                    if (style.allowedUpdates.canDelete)
                      PopupMenuItem(
                          value: 4,
                          child: Text("Delete style",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: StyleSelectionWidget.SIZE_SMALL))),
                  ],
              onSelected: (value) {
                if (value == 1) {
                  BlocProvider.of<StyleSelectionBloc>(context)
                      .add(SelectStyleEvent(style: style));
                } else if (value == 2) {
                  style.update(context);
/*
                  BlocProvider.of<StyleSelectionBloc>(context)
                      .add(StyleUpdatedEvent(style: style));
*/
                } else if (value == 3) {
                  openEntryDialog(context,
                      title: 'Provide new name for copy of style',
                      hintText: 'Style name',
                      ackButtonLabel: 'Copy',
                      nackButtonLabel: 'Cancel', onPressed: (newName) {
                    if (newName != null) {
                      BlocProvider.of<StyleSelectionBloc>(context)
                          .add(CopyStyleEvent(style: style, newName: newName));
                    }
                  });
                } else if (value == 4) {
                  if (isCurrent) {
                    openMessageDialog(
                      context,
                      title: 'Error',
                      message:
                          'This is the current style of the app, unable to delete',
                    );
                  } else {
                    openAckNackDialog(context,
                        title: 'Confirm',
                        message: 'Confirm deleting style ' +
                            style.styleFamily.familyName +
                            '.' +
                            style.styleName, onSelection: (value) async {
                      if (value == 0) {
                        BlocProvider.of<StyleSelectionBloc>(context)
                            .add(DeleteStyleEvent(style: style));
                      }
                    });
                  }
                }
              }));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
/*
    var app = AccessBloc.app(context);
    if (app == null) throw Exception("No app");
*/
    return BlocBuilder<StyleSelectionBloc, StyleSelectionState>(
        builder: (context, state) {
      if (state is StyleSelectionInitialized) {
        return Container(
//            width: widget.widgetWidth,
            child:
                ListView(shrinkWrap: true, physics: ScrollPhysics(), children: [
          if (widget.withHeader) HeaderWidget(
            cancelAction: () async {
              return true;
            },
            okAction: () async {
              BlocProvider.of<StyleSelectionBloc>(context)
                  .add(StyleSelectionApplyChanges(true));
              return true;
            },
            title: 'Change style',
          ),
          divider(context),
          topicContainer(context,
              title: 'Styles',
              collapsible: true,
              collapsed: widget.collapsed,
              children: [
                ListView(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  children: <Widget>[
                    Container(
                        height: 200,
                        child: _getStyleFamilies(
                            /*app,
*/                            state.families,
                            state is StyleSelectionInitializedWithSelection
                                ? state.style
                                : null)),
                  ],
                )
              ]),
        ]));
      } else {
        return progressIndicator(context);
      }
    });
  }
}

