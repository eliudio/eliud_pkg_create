import 'package:equatable/equatable.dart';

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

  @override
  int get hashCode => 0;
}

class FromJsonInitialised extends FromJsonState {
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FromJsonInitialised;

  @override
  int get hashCode => 0;
}

class FromJsonProgress extends FromJsonState {
  final double progress;

  FromJsonProgress(this.progress);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FromJsonProgress && other.progress == progress;

  @override
  int get hashCode => progress.hashCode;
}

class FromJsonActionCancelled extends FromJsonState {
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FromJsonState;

  @override
  int get hashCode => 0;
}
