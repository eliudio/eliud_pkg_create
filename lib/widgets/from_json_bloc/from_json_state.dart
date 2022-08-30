import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/dialog_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

abstract class FromJsonState extends Equatable {
  const FromJsonState();

  @override
  List<Object?> get props => [];
}

class FromJsonUninitialised extends FromJsonState {
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FromJsonUninitialised;
}

class FromJsonInitialised extends FromJsonState {
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FromJsonInitialised;
}

class FromJsonProgress extends FromJsonState {
  final double progress;

  FromJsonProgress(this.progress);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FromJsonProgress && other.progress == this.progress;
}

class FromJsonActionCancelled extends FromJsonState {

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FromJsonState;
}