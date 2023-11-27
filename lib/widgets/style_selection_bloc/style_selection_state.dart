import 'package:eliud_core_main/apis/style/style.dart';
import 'package:eliud_core_main/apis/style/style_family.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';

@immutable
abstract class StyleSelectionState extends Equatable {
  const StyleSelectionState();

  @override
  List<Object?> get props => [];
}

class StyleSelectionUninitialized extends StyleSelectionState {
  @override
  List<Object?> get props => [];

  @override
  String toString() {
    return '''StyleSelectionUninitialized()''';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StyleSelectionUninitialized && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class StyleFamilyState {
  final StyleFamily styleFamily;
  final List<Style> allStyles;

  StyleFamilyState(this.styleFamily, this.allStyles);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StyleFamilyState &&
          styleFamily == other.styleFamily &&
          const ListEquality().equals(allStyles, other.allStyles) &&
          runtimeType == other.runtimeType;

  String familyName() => styleFamily.familyName;

  @override
  int get hashCode => styleFamily.hashCode ^ allStyles.hashCode;
}

abstract class StyleSelectionInitialized extends StyleSelectionState {
  final List<StyleFamilyState> families;

  @override
  List<Object?> get props => [families];

  StyleSelectionInitialized({required List<StyleFamilyState> initFamilies})
      : families = sortIt(initFamilies);

  static List<StyleFamilyState> sortIt(List<StyleFamilyState> initFamilies) {
    initFamilies.sort((a, b) => a.familyName().compareTo(b.familyName()));
    return initFamilies;
  }

  StyleSelectionInitialized copyWith(List<StyleFamilyState> newFamilies);

  StyleSelectionInitialized copyWithNewStyleFamily(
      StyleFamily styleFamily, List<Style> allStyles);

  static List<StyleFamilyState> copyAndReplace(
      List<StyleFamilyState> toReplace, StyleFamilyState replaceWith) {
    List<StyleFamilyState> newFamilies = [];
    for (var styleFamilyState in toReplace) {
      if (styleFamilyState.styleFamily.familyName != replaceWith.familyName()) {
        newFamilies.add(styleFamilyState);
      }
    }
    newFamilies.add(replaceWith);
    return newFamilies;
  }
}

class StyleSelectionInitializedWithSelection extends StyleSelectionInitialized {
  final Style currentSelectedStyle;

  @override
  List<Object?> get props => [currentSelectedStyle, families];

  StyleSelectionInitializedWithSelection(
      {required List<StyleFamilyState> families,
      required this.currentSelectedStyle /*, required this.count*/})
      : super(initFamilies: families);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StyleSelectionInitializedWithSelection &&
          runtimeType == other.runtimeType &&
          currentSelectedStyle == other.currentSelectedStyle &&
          ListEquality().equals(families, other.families);

  @override
  StyleSelectionInitializedWithSelection copyWith(
      List<StyleFamilyState> newFamilies) {
    return StyleSelectionInitializedWithSelection(
        currentSelectedStyle: currentSelectedStyle, families: newFamilies);
  }

  @override
  StyleSelectionInitialized copyWithNewStyleFamily(
      StyleFamily styleFamily, List<Style> allStyles) {
    var newOne = StyleSelectionInitializedWithSelection(
        families: StyleSelectionInitialized.copyAndReplace(
            families, StyleFamilyState(styleFamily, allStyles)),
        currentSelectedStyle: currentSelectedStyle);
    return newOne;
  }

  @override
  int get hashCode => currentSelectedStyle.hashCode ^ families.hashCode;
}

class StyleSelectionInitializedWithoutSelection
    extends StyleSelectionInitialized {
  @override
  List<Object?> get props => [families];

  StyleSelectionInitializedWithoutSelection(
      {required List<StyleFamilyState> families})
      : super(initFamilies: families);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StyleSelectionInitializedWithoutSelection &&
          runtimeType == other.runtimeType &&
          ListEquality().equals(families, other.families);

  @override
  StyleSelectionInitializedWithoutSelection copyWith(
      List<StyleFamilyState> newFamilies) {
    return StyleSelectionInitializedWithoutSelection(families: newFamilies);
  }

  @override
  StyleSelectionInitialized copyWithNewStyleFamily(
      StyleFamily styleFamily, List<Style> allStyles) {
    return StyleSelectionInitializedWithoutSelection(
        families: StyleSelectionInitialized.copyAndReplace(
            families, StyleFamilyState(styleFamily, allStyles)));
  }

  @override
  int get hashCode => families.hashCode;
}
