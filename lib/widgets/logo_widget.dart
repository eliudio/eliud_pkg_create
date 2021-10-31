import 'dart:math';

import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_pkg_create/widgets/utils/random_logo.dart';
import 'package:eliud_pkg_medium/platform/access_rights.dart';
import 'package:eliud_pkg_medium/platform/medium_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LogoWidget extends StatefulWidget {
  final AppModel appModel;
  final bool collapsed;

  const LogoWidget({Key? key, required this.appModel, required this.collapsed})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _LogoWidgetState();
}

class _LogoWidgetState extends State<LogoWidget> {
  double? _progress;

  @override
  Widget build(BuildContext context) {
    return topicContainer(context,
        title: 'Logo',
        collapsible: true,
        collapsed: widget.collapsed,
        children: [
          getListTile(context,
              trailing: PopupMenuButton<int>(
                  child: Icon(Icons.more_vert),
                  elevation: 10,
                  itemBuilder: (context) => [
                        if (AbstractMediumPlatform.platform!.hasCamera())
                          PopupMenuItem(
                            value: 0,
                            child: text(context, 'Take photo'),
                          ),
                        PopupMenuItem(
                          value: 1,
                          child: text(context, 'Upload logo'),
                        ),
                    if (AbstractMediumPlatform.platform!.hasAccessToLocalFilesystem()) PopupMenuItem(
                          value: 2,
                          child: text(context, 'Random logo'),
                        ),
                        PopupMenuItem(
                          value: 3,
                          child: text(context, 'Clear image'),
                        ),
                      ],
                  onSelected: (value) async {
                    if (value == 0) {
                      AbstractMediumPlatform.platform!.takePhoto(
                          context,
                          widget.appModel.documentID!,
                          widget.appModel.ownerID!,
                          PublicMediumAccessRights(),
                          (photo) =>
                              _photoFeedbackFunction(widget.appModel, photo),
                          _photoUploading,
                          allowCrop: false);
                    } else if (value == 1) {
                      AbstractMediumPlatform.platform!.uploadPhoto(
                          context,
                          widget.appModel.documentID!,
                          widget.appModel.ownerID!,
                          PublicMediumAccessRights(),
                          (photo) =>
                              _photoFeedbackFunction(widget.appModel, photo),
                          _photoUploading,
                          allowCrop: false);
                    } else if (value == 2) {
                      var photo = await RandomLogo.getRandomPhoto(widget.appModel.documentID!,
                          widget.appModel.ownerID!, _photoUploading);
                      _photoFeedbackFunction(widget.appModel, photo);
                    } else if (value == 3) {
                      _photoFeedbackFunction(widget.appModel, null);
                    }
                  }),
              title: _progress != null
                  ? progressIndicatorWithValue(context, value: _progress!)
                  : widget.appModel.logo == null ||
                          widget.appModel.logo!.url == null
                      ? Center(child: text(context, 'No image set'))
                      : Image.network(
                          widget.appModel.logo!.url!,
                          height: 100,
                        ))
        ]);
  }

  void _photoFeedbackFunction(
      AppModel appModel, PublicMediumModel? platformMediumModel) {
    setState(() {
      _progress = null;
      appModel.logo = platformMediumModel;
    });
  }

  void _photoUploading(dynamic progress) {
    if (progress != null) {}
    setState(() {
      _progress = progress;
    });
  }
}
