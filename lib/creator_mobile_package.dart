
import 'package:eliud_core/package/package.dart';

import 'creator_package.dart';

class CreatorMobilePackage extends CreatorPackage {

  @override
  List<Object?> get props => [
  ];

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
          other is CreatorMobilePackage &&
              runtimeType == other.runtimeType;

}
