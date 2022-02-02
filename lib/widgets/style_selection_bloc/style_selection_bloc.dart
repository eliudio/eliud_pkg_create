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
  Map<String, StreamSubscription?> _styleFamilySubscription = {};

  void listenToStyleFamily(String appId, StyleFamily styleFamily) {
    // todo: listen to the app, if the style changes, then re-listen to the style
    _styleFamilySubscription[styleFamily.familyName]?.cancel();
    _styleFamilySubscription[styleFamily.familyName] =
        styleFamily.listenToStyles(appId, (list) {
          add(ChangedStyleFamilyState(styleFamily, list));
        });
  }

  StyleSelectionBloc(AppModel initialiseWithApp, this.feedbackSelection)
      : app = initialiseWithApp.copyWith(),
        super(StyleSelectionUninitialized());

  @override
  Stream<StyleSelectionState> mapEventToState(
      StyleSelectionEvent event) async* {
    if (event is InitialiseStyleSelectionEvent) {
      styleName = app.styleName;
      StyleFamily? styleFamily;
      if (event.family != null) {
        styleFamily = StyleRegistry.registry().styleFamily(event.family!);
      } else {
        styleFamily = StyleRegistry.registry()
            .styleFamily(DefaultStyleFamily.defaultStyleFamilyName);
      }
      var families =
          StyleRegistry.registry().registeredStyleFamilies.values.toList();

      var styleFamilyStates = families.map((styleFamily) {
        listenToStyleFamily(app.documentID!, styleFamily);
        return StyleFamilyState(styleFamily, []);
      }).toList();
      if (styleFamily != null) {
        var style;
        if (event.styleName != null) {
          style = styleFamily.getStyle(app, event.styleName!);
        } else {
          style = styleFamily.getStyle(app, DefaultStyle.defaultStyleName);
        }
        if (style != null) {
          yield StyleSelectionInitializedWithSelection(
            families: styleFamilyStates,
            currentSelectedStyle: style,
          );
          return;
        }
      }
      yield StyleSelectionInitializedWithoutSelection(
        families: styleFamilyStates,
      );

    }
    if (event is ChangedStyleFamilyState) {
      if (state is StyleSelectionInitialized) {
        var styleSelectionInitialized = state as StyleSelectionInitialized;
        var styleFamily = event.styleFamily;
        var styles = event.allStyles;
        yield styleSelectionInitialized.copyWithNewStyleFamily(styleFamily, styles);
      }
    }
    if (event is GenerateDefaults) {
      await event.family.installDefaults(app);
      if (state is StyleSelectionInitializedWithSelection) {
        var theState = state as StyleSelectionInitializedWithSelection;
        add(InitialiseStyleSelectionEvent(family: theState.currentSelectedStyle.styleFamily.familyName, styleName: theState.currentSelectedStyle.styleName));
      } else if (state is StyleSelectionInitializedWithoutSelection) {
        add(InitialiseStyleSelectionEvent());
      }
    }
    if (state is StyleSelectionInitialized) {
      var theState = state as StyleSelectionInitialized;
      if (event is SelectStyleEvent) {
        yield selectStyle(event.style, state as StyleSelectionInitialized);
      } else if (event is DeleteStyleEvent) {
        event.style.styleFamily.delete(app, event.style);
      } else if (event is StyleUpdatedEvent) {
        event.style.styleFamily.update(app, event.style);
      } else if (event is CopyStyleEvent) {
/*
TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
        var newStyle = event.style.copy(event.newName);
        if (newStyle != null) {
          newStyle.styleFamily.styles[event.newName] = newStyle;
          yield theState.copyWith(theState.families);
        }
*/
      } else if (event is StyleSelectionApplyChanges) {
        if (event.save) {
          appRepository(appId: app.documentID)!.update(app);
        }
      }
    }
  }

  StyleSelectionInitializedWithSelection selectStyle(
      Style style, StyleSelectionInitialized state) {
    app.styleFamily = style.styleFamily.familyName;
    app.styleName = style.styleName;
    if (this.feedbackSelection != null) {
      this.feedbackSelection!(app.styleFamily, app.styleName);
    }
    return StyleSelectionInitializedWithSelection(
      families: state.families,
      currentSelectedStyle: style,
    );
  }
}
