import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:eliud_core/style/_default/default_style_family.dart';
import 'package:eliud_core/style/style.dart';
import 'package:eliud_core/style/style_family.dart';
import 'package:eliud_core/style/style_registry.dart';
import 'package:eliud_core/tools/firestore/firestore_tools.dart';
import 'style_selection_event.dart';
import 'style_selection_state.dart';
import 'package:flutter/cupertino.dart';

import 'package:eliud_core/tools/enums.dart';
import 'package:eliud_core/tools/common_tools.dart';

import 'package:eliud_core/model/rgb_model.dart';

import 'package:eliud_core/tools/string_validator.dart';

import 'package:eliud_core/model/repository_export.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import 'package:eliud_core/model/model_export.dart';
import 'package:eliud_core/model/entity_export.dart';
import 'package:eliud_pkg_etc/widgets/decorator/can_refresh.dart';

class StyleSelectionBloc
    extends Bloc<StyleSelectionEvent, StyleSelectionState> {
  String? originalStyleFamily;
  String? styleName;
  final AppModel app;
  final CanRefresh? canRefresh;

  StyleSelectionBloc(this.app, this.canRefresh) : super(StyleSelectionUninitialized());
  @override
  Stream<StyleSelectionState> mapEventToState(
      StyleSelectionEvent event) async* {
    if (event is InitialiseStyleSelectionEvent) {
      originalStyleFamily = app.styleFamily;
      styleName = app.styleName;
      var styleFamily;
      if (event.family != null) {
        styleFamily = StyleRegistry.registry().styleFamily(event.family!);
      } else {
        styleFamily = StyleRegistry.registry().styleFamily(DefaultStyleFamily.defaultStyleFamilyName);
      }
      var families = StyleRegistry.registry()
          .registeredStyleFamilies
          .values
          .toList();
      if (styleFamily != null) {
        var style;
        if (event.styleName != null) {
          style = styleFamily.style(event.styleName);
        } else {
          style = styleFamily.style(DefaultStyle.defaultStyleName);
        }
        if (style != null) {
          yield StyleSelectionInitializedWithSelection(
              families: families,
              style: style,
              );
          return;
        }
      }
      yield StyleSelectionInitializedWithoutSelection(
        families: families,
      );
    }
    if (state is StyleSelectionInitialized) {
      var theState = state as StyleSelectionInitialized;
      if (event is SelectStyleEvent) {
        yield selectStyle(event.style, state as StyleSelectionInitialized);
      } else if (event is DeleteStyleEvent) {
        // find family
        var foundFamily = theState.families
            .where((family) =>
        family.familyName == event.style.styleFamily.familyName)
            .first;
        if (foundFamily != null) {
          // new list of styles
          Map<String, Style> newStyleList = Map.from(
              foundFamily.styles);
          newStyleList.remove(event.style.styleName);

          // new family
          var newFamily = event.style.styleFamily.copyWithNewStyles(
              newStyleList);

          // new families
          List<StyleFamily> newFamilies = List.from(theState.families);
          newFamilies.removeWhere((fam) =>
          fam.familyName == event.style.styleFamily.familyName);
          newFamilies.add(newFamily);

          var newState = theState.copyWith(newFamilies);
          yield newState;
        }
      } else if (event is StyleUpdatedEvent) {
        // make sure the style is updated in the list
      } else if (event is CopyStyleEvent) {
        var newStyle = event.style.copy(event.newName);
        if (newStyle != null) {
          newStyle.styleFamily.styles[event.newName] = newStyle;
          yield theState.copyWith(theState.families);
        }
      } else if (event is StyleSelectionApplyChanges) {
        if (event.save) {
          appRepository(appId: app.documentID)!.update(app);
        }
        if (canRefresh != null) {
          canRefresh!.refresh();
        }
      } else if (event is StyleSelectionRevertChanges) {
        app.styleFamily = originalStyleFamily;
        app.styleName = styleName;
        if (canRefresh != null) {
          canRefresh!.refresh();
        }
      }
    }
  }

  StyleSelectionInitializedWithSelection selectStyle(Style style, StyleSelectionInitialized state) {
    app.styleFamily = style.styleFamily.familyName;
    app.styleName = style.styleName;
    if (canRefresh != null) {
      canRefresh!.refresh();
    }
    return StyleSelectionInitializedWithSelection(
        families: state.families,
        style: style,
    );
  }
}
