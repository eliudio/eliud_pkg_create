import 'package:eliud_pkg_create/platform/create_platform.dart';
import 'package:eliud_pkg_create/platform/mobile_create_platform.dart';

import 'creator_package.dart';

CreatorPackage getCreatorPackage() => CreatorMobilePackage();

class CreatorMobilePackage extends CreatorPackage {
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatorMobilePackage && runtimeType == other.runtimeType;

  @override
  void init() {
    super.init();
    AbstractCreatePlatform.platform = MobileCreatePlatform();
  }

  @override
  int get hashCode => 0;
}
