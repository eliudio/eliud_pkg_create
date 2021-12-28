import 'dart:math';

import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_core/tools/storage/upload_info.dart';
import 'package:eliud_pkg_medium/platform/access_rights.dart';
import 'package:eliud_pkg_medium/platform/medium_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RandomLogo {
  static var _random = new Random();

  static List<String> randomLogos = [
    'packages/eliud_pkg_create/assets/annoyed.png',
    'packages/eliud_pkg_create/assets/angry.png',
    'packages/eliud_pkg_create/assets/embarassed.png',
    'packages/eliud_pkg_create/assets/excited.png',
    'packages/eliud_pkg_create/assets/frustrated.png',
    'packages/eliud_pkg_create/assets/happy.png',
    'packages/eliud_pkg_create/assets/lonely.png',
    'packages/eliud_pkg_create/assets/loved.png',
    'packages/eliud_pkg_create/assets/nervous.png',
    'packages/eliud_pkg_create/assets/neutral.png',
    'packages/eliud_pkg_create/assets/sad.png',
    'packages/eliud_pkg_create/assets/scared.png',
    'packages/eliud_pkg_create/assets/sick.png',
    'packages/eliud_pkg_create/assets/stressed.png',
    'packages/eliud_pkg_create/assets/surprised.png',
    'packages/eliud_pkg_create/assets/tired.png',
  ];

  RandomLogo();

  static Future<PublicMediumModel> getRandomPhoto(AppModel app, String memberId, MediumAvailable? feedbackFunction, ) async {
    var newRandom = randomLogos[_random.nextInt(randomLogos.length)];
    var photo = await PublicMediumAccessRights()
        .getMediumHelper(
      app,
      memberId,
    )
        .createThumbnailUploadPhotoAsset(newRandomKey(), newRandom,
        feedbackProgress: feedbackFunction);
    return photo;
  }


}
