import 'package:eliud_core/style/style.dart';
import 'package:eliud_core/style/style_family.dart';
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
  bool operator == (Object other) =>
      identical(this, other) ||
          other is StyleSelectionUninitialized &&
              runtimeType == other.runtimeType;
}

abstract class StyleSelectionInitialized extends StyleSelectionState {
  late List<StyleFamily> families;

  @override
  List<Object?> get props => [families];

  StyleSelectionInitialized({required List<StyleFamily> initFamilies}) {
    initFamilies.sort((a, b) => a.familyName.compareTo(b.familyName));
    families = initFamilies;
  }

  StyleSelectionInitialized copyWith(List<StyleFamily> newFamilies);
}

class StyleSelectionInitializedWithSelection extends StyleSelectionInitialized {
  final Style style;

  @override
  List<Object?> get props => [style, families];

  StyleSelectionInitializedWithSelection(
      {required List<StyleFamily> families, required this.style/*, required this.count*/})
      : super(initFamilies: families);

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
          other is StyleSelectionInitializedWithSelection &&
              runtimeType == other.runtimeType &&
              style == other.style &&
              ListEquality().equals(families, other.families);

  @override
  StyleSelectionInitializedWithSelection copyWith(List<StyleFamily> newFamilies) {
    return StyleSelectionInitializedWithSelection(style: style, families: newFamilies);
  }
}

class StyleSelectionInitializedWithoutSelection
    extends StyleSelectionInitialized {
  @override
  List<Object?> get props => [families];

  StyleSelectionInitializedWithoutSelection(
      {required List<StyleFamily> families})
      : super(initFamilies: families);

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
          other is StyleSelectionInitializedWithoutSelection &&
              runtimeType == other.runtimeType &&
              ListEquality().equals(families, other.families);

  @override
  StyleSelectionInitializedWithoutSelection copyWith(List<StyleFamily> newFamilies) {
    return StyleSelectionInitializedWithoutSelection(families: newFamilies);
  }
}
