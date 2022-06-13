
import 'package:eliud_core/core/base/model_base.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_pkg_create/platform/create_platform.dart';
import 'package:eliud_pkg_create/platform/web_create_platform.dart';

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


  @override
  void init() {
    super.init();
    AbstractCreatePlatform.platform = WebCreatePlatform();
  }
}
