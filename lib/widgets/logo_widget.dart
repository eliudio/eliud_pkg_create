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
  final AppModel app;
  final bool collapsed;

  const LogoWidget({Key? key, required this.app, required this.collapsed})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _LogoWidgetState();
}

class _LogoWidgetState extends State<LogoWidget> {
  double? _progress;

  @override
  Widget build(BuildContext context) {
    return topicContainer(widget.app, context,
        title: 'Logo',
        collapsible: true,
        collapsed: widget.collapsed,
        children: [
          getListTile(context,widget.app,
              trailing: PopupMenuButton<int>(
                  child: Icon(Icons.more_vert),
                  elevation: 10,
                  itemBuilder: (context) => [
                        if (AbstractMediumPlatform.platform!.hasCamera())
                          PopupMenuItem(
                            value: 0,
                            child: text(widget.app, context, 'Take photo'),
                          ),
                        PopupMenuItem(
                          value: 1,
                          child: text(widget.app, context, 'Upload logo'),
                        ),
                    if (AbstractMediumPlatform.platform!.hasAccessToLocalFilesystem()) PopupMenuItem(
                          value: 2,
                          child: text(widget.app, context, 'Random logo'),
                        ),
                        PopupMenuItem(
                          value: 3,
                          child: text(widget.app, context, 'Clear image'),
                        ),
                      ],
                  onSelected: (value) async {
                    if (value == 0) {
                      AbstractMediumPlatform.platform!.takePhoto(
                          context,
                          widget.app,
                          widget.app.ownerID!,
                          () => PublicMediumAccessRights(),
                          (photo) =>
                              _photoFeedbackFunction(widget.app, photo),
                          _photoUploading,
                          allowCrop: false);
                    } else if (value == 1) {
                      AbstractMediumPlatform.platform!.uploadPhoto(
                          context,
                          widget.app,
                          widget.app.ownerID!,
                          () => PublicMediumAccessRights(),
                          (photo) =>
                              _photoFeedbackFunction(widget.app, photo),
                          _photoUploading,
                          allowCrop: false);
                    } else if (value == 2) {
                      var photo = await RandomLogo.getRandomPhoto(widget.app,
                          widget.app.ownerID!, _photoUploading);
                      _photoFeedbackFunction(widget.app, photo);
                    } else if (value == 3) {
                      _photoFeedbackFunction(widget.app, null);
                    }
                  }),
              title: _progress != null
                  ? progressIndicatorWithValue(widget.app, context, value: _progress!)
                  : widget.app.logo == null ||
                          widget.app.logo!.url == null
                      ? Center(child: text(widget.app, context, 'No image set'))
                      : Image.network(
                          widget.app.logo!.url!,
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
