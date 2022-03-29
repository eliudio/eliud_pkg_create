/*
       _ _           _ 
      | (_)         | |
   ___| |_ _   _  __| |
  / _ \ | | | | |/ _` |
 |  __/ | | |_| | (_| |
  \___|_|_|\__,_|\__,_|
                       
 
 play_store_form_state.dart
                       
 This code is generated. This is read only. Don't touch!

*/

import 'play_store_model.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class PlayStoreFormState extends Equatable {
  const PlayStoreFormState();

  @override
  List<Object?> get props => [];
}

// Startup: menu has not been initialised yet and so we should show a "loading indicator" or something
class PlayStoreFormUninitialized extends PlayStoreFormState {
  @override
  List<Object?> get props => [];

  @override
  String toString() {
    return '''PlayStoreFormState()''';
  }
}

// PlayStoreModel has been initialised and hence PlayStoreModel is available
class PlayStoreFormInitialized extends PlayStoreFormState {
  final PlayStoreModel? value;

  @override
  List<Object?> get props => [ value ];

  const PlayStoreFormInitialized({ this.value });
}

// Menu has been initialised and hence a menu is available
abstract class PlayStoreFormError extends PlayStoreFormInitialized {
  final String? message;

  @override
  List<Object?> get props => [ message, value ];

  const PlayStoreFormError({this.message, PlayStoreModel? value }) : super(value: value);

  @override
  String toString() {
    return '''PlayStoreFormError {
      value: $value,
      message: $message,
    }''';
  }
}
class DocumentIDPlayStoreFormError extends PlayStoreFormError { 
  const DocumentIDPlayStoreFormError({ String? message, PlayStoreModel? value }): super(message: message, value: value);

  @override
  List<Object?> get props => [ message, value ];

  @override
  String toString() {
    return '''DocumentIDPlayStoreFormError {
      value: $value,
      message: $message,
    }''';
  }
}


class AppIdPlayStoreFormError extends PlayStoreFormError { 
  const AppIdPlayStoreFormError({ String? message, PlayStoreModel? value }): super(message: message, value: value);

  @override
  List<Object?> get props => [ message, value ];

  @override
  String toString() {
    return '''AppIdPlayStoreFormError {
      value: $value,
      message: $message,
    }''';
  }
}


class DescriptionPlayStoreFormError extends PlayStoreFormError { 
  const DescriptionPlayStoreFormError({ String? message, PlayStoreModel? value }): super(message: message, value: value);

  @override
  List<Object?> get props => [ message, value ];

  @override
  String toString() {
    return '''DescriptionPlayStoreFormError {
      value: $value,
      message: $message,
    }''';
  }
}


class ConditionsPlayStoreFormError extends PlayStoreFormError { 
  const ConditionsPlayStoreFormError({ String? message, PlayStoreModel? value }): super(message: message, value: value);

  @override
  List<Object?> get props => [ message, value ];

  @override
  String toString() {
    return '''ConditionsPlayStoreFormError {
      value: $value,
      message: $message,
    }''';
  }
}


class PlayStoreFormLoaded extends PlayStoreFormInitialized { 
  const PlayStoreFormLoaded({ PlayStoreModel? value }): super(value: value);

  @override
  List<Object?> get props => [ value ];

  @override
  String toString() {
    return '''PlayStoreFormLoaded {
      value: $value,
    }''';
  }
}


class SubmittablePlayStoreForm extends PlayStoreFormInitialized { 
  const SubmittablePlayStoreForm({ PlayStoreModel? value }): super(value: value);

  @override
  List<Object?> get props => [ value ];

  @override
  String toString() {
    return '''SubmittablePlayStoreForm {
      value: $value,
    }''';
  }
}


