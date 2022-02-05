import 'package:eliud_core/style/style.dart';
import 'package:eliud_core/style/style_family.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class StyleSelectionEvent extends Equatable {
  const StyleSelectionEvent();

  @override
  List<Object?> get props => [];
}

class InitialiseStyleSelectionEvent extends StyleSelectionEvent {
  final String? family;
  final String? styleName;

  @override
  List<Object?> get props => [ family, styleName ];

  InitialiseStyleSelectionEvent({this.family, this.styleName});
}

class ChangedStyleFamilyState extends StyleSelectionEvent {
  final StyleFamily styleFamily;
  final List<Style> allStyles;

  ChangedStyleFamilyState(this.styleFamily, this.allStyles);
}

class SelectedStyleEvent extends StyleSelectionEvent {
  final Style style;

  SelectedStyleEvent(this.style);

  @override
  List<Object?> get props => [ style ];

  @override
  String toString() => 'SelectedStyleEvent{ style: $style }';
}

class SelectStyleEvent extends StyleSelectionEvent {
  final Style style;

  @override
  List<Object?> get props => [ style ];

  SelectStyleEvent({required this.style});
}

class CopyStyleEvent extends StyleSelectionEvent {
  final Style style;
  final String newName;

  @override
  List<Object?> get props => [ style, newName ];

  CopyStyleEvent({required this.style, required this.newName});
}

class AddNewStyleEvent extends StyleSelectionEvent {
  final StyleFamily styleFamily;
  final String newStyleName;

  @override
  List<Object?> get props => [ styleFamily, newStyleName ];

  AddNewStyleEvent({required this.styleFamily, required this.newStyleName});
}

class StyleUpdatedEvent extends StyleSelectionEvent {
  final Style style;

  @override
  List<Object?> get props => [ style ];

  StyleUpdatedEvent({required this.style});
}

class DeleteStyleEvent extends StyleSelectionEvent {
  final Style style;

  @override
  List<Object?> get props => [ style ];

  DeleteStyleEvent({required this.style});
}

class InsertNewStyleEvent extends StyleSelectionEvent {
  // to determine

  @override
  List<Object?> get props => [];

  InsertNewStyleEvent();
}

class StyleSelectionApplyChanges extends StyleSelectionEvent {
  final bool save;

  StyleSelectionApplyChanges(this.save);

  @override
  List<Object?> get props => [save];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is StyleSelectionApplyChanges &&
              save == other.save;
}
