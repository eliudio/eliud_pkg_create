
import 'package:eliud_pkg_create/platform/create_platform.dart';
import 'package:eliud_pkg_create/platform/web_create_platform.dart';

import 'creator_package.dart';

CreatorPackage getCreatorPackage() => CreatorWebPackage();

class CreatorWebPackage extends CreatorPackage {

  @override
  List<Object?> get props => [
  ];

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
          other is CreatorWebPackage &&
              runtimeType == other.runtimeType;


  @override
  void init() {
    super.init();
    AbstractCreatePlatform.platform = WebCreatePlatform();
  }

}
