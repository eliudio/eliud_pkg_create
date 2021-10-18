
import 'creator_package.dart';

class CreatorWebPackage extends CreatorPackage {

  @override
  List<Object?> get props => [
  ];

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
          other is CreatorWebPackage &&
              runtimeType == other.runtimeType;

}
