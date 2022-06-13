
import 'dart:io';

import 'package:eliud_core/core/base/model_base.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/package/package.dart';
import 'package:eliud_pkg_create/platform/create_platform.dart';
import 'package:eliud_pkg_create/platform/mobile_create_platform.dart';
import 'package:path_provider/path_provider.dart';

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

  @override
  void init() {
    super.init();
    AbstractCreatePlatform.platform = MobileCreatePlatform();
  }
}
