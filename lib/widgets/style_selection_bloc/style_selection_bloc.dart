import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:eliud_core/style/_default/default_style_family.dart';
import 'package:eliud_core/style/style.dart';
import 'package:eliud_core/style/style_family.dart';
import 'package:eliud_core/style/style_registry.dart';
import 'style_selection_event.dart';
import 'style_selection_state.dart';




import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import 'package:eliud_core/model/model_export.dart';

typedef FeedbackSelection = Function(String? styleFamily, String? styleName);

class StyleSelectionBloc
    extends Bloc<StyleSelectionEvent, StyleSelectionState> {
  String? styleName;
  final AppModel app;
  final FeedbackSelection? feedbackSelection;

  StyleSelectionBloc(AppModel initialiseWithApp, this.feedbackSelection) : app = initialiseWithApp.copyWith(), super(StyleSelectionUninitialized());
  @override
  Stream<StyleSelectionState> mapEventToState(
      StyleSelectionEvent event) async* {
    if (event is InitialiseStyleSelectionEvent) {
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
      }
    }
  }

  StyleSelectionInitializedWithSelection selectStyle(Style style, StyleSelectionInitialized state) {
    app.styleFamily = style.styleFamily.familyName;
    app.styleName = style.styleName;
    if (this.feedbackSelection != null) {
      this.feedbackSelection!(app.styleFamily, app.styleName);
    }
    return StyleSelectionInitializedWithSelection(
        families: state.families,
        style: style,
    );
  }
}
