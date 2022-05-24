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
        super(StyleSelectionUninitialized()) {
    on<InitialiseStyleSelectionEvent>((event, emit) {
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
        listenToStyleFamily(app.documentID, styleFamily);
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
          emit(StyleSelectionInitializedWithSelection(
            families: styleFamilyStates,
            currentSelectedStyle: style,
          ));
          return;
        }
      }
      emit(StyleSelectionInitializedWithoutSelection(
        families: styleFamilyStates,
      ));
    });

    on<ChangedStyleFamilyState>((event, emit) {
      if (state is StyleSelectionInitialized) {
        var styleSelectionInitialized = state as StyleSelectionInitialized;
        var styleFamily = event.styleFamily;
        var styles = event.allStyles;
        emit(styleSelectionInitialized.copyWithNewStyleFamily(
            styleFamily, styles));
      }
    });

    on<AddNewStyleEvent>((event, emit) async {
      await event.styleFamily.newStyle(app, event.newStyleName);
    });

    on<SelectStyleEvent>((event, emit) {
      emit(selectStyle(event.style, state as StyleSelectionInitialized));
    });

    on<DeleteStyleEvent>((event, emit) async {
      await event.style.styleFamily.delete(app, event.style);
    });

    on<StyleUpdatedEvent>((event, emit) async {
      await event.style.styleFamily.update(app, event.style);
    });

    on<CopyStyleEvent>((event, emit) async {
      await event.style.copy(app, event.newName);
    });

    on<StyleSelectionApplyChanges>((event, emit) async {
      if (event.save) {
        await appRepository(appId: app.documentID)!.update(app);
      }
    });
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
