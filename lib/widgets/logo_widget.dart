import 'package:eliud_core/core/registry.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/public_medium_model.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_pkg_create/widgets/utils/random_logo.dart';
import 'package:eliud_core/package/access_rights.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef LogoFeedback(PublicMediumModel? logo);

class LogoWidget extends StatefulWidget {
  final bool isCollapsable;
  final bool collapsed;
  final AppModel app;
  final PublicMediumModel? logo;
  final LogoFeedback logoFeedback;

  const LogoWidget({Key? key, required this.app, required this.isCollapsable, required this.logo, required this.logoFeedback, required this.collapsed})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _LogoWidgetState();
}

class _LogoWidgetState extends State<LogoWidget> {
  double? _progress;

  @override
  Widget build(BuildContext context) {
    if (widget.isCollapsable) {
      return topicContainer(widget.app, context,
          title: 'Logo',
          collapsible: true,
          collapsed: widget.collapsed,
          children: [
            tile(),
          ]);
    } else{
      return ListView(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          children: [
            h4(widget.app, context, 'Logo'),
            tile(),
          ]);
    }
  }

  Widget tile() {
    return getListTile(context,widget.app,
        trailing: popupMenuButton<int>(
            widget.app, context,
            child: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              if (Registry.registry()!.getMediumApi().hasCamera())
                popupMenuItem(
                  widget.app, context,
                  value: 0,
                  label: 'Take photo',
                ),
              popupMenuItem(
                widget.app, context,
                value: 1,
                label: 'Upload logo',
              ),
              popupMenuItem(
                widget.app, context,
                value: 2,
                label: 'Random logo',
              ),
              popupMenuItem(
                widget.app, context,
                value: 3,
                label: 'Clear image',
              ),
            ],
            onSelected: (value) async {
              if (value == 0) {
                Registry.registry()!.getMediumApi().takePhoto(
                    context,
                    widget.app,
                        () => PublicMediumAccessRights(),
                        (photo) =>
                        _photoFeedbackFunction(photo),
                    _photoUploading,
                    allowCrop: false);
              } else if (value == 1) {
                Registry.registry()!.getMediumApi().uploadPhoto(
                    context,
                    widget.app,
                        () => PublicMediumAccessRights(),
                        (photo) =>
                        _photoFeedbackFunction(photo),
                    _photoUploading,
                    allowCrop: false);
              } else if (value == 2) {
                var photo = await RandomLogo.getRandomPhoto(widget.app,
                    widget.app.ownerID, _photoUploading);
                _photoFeedbackFunction(photo);
              } else if (value == 3) {
                _photoFeedbackFunction(null);
              }
            }),
        title: _progress != null
            ? progressIndicatorWithValue(widget.app, context, value: _progress!)
            : widget.logo == null ||
            widget.logo!.url == null
            ? Center(child: text(widget.app, context, 'No image set'))
            : Image.network(
          widget.logo!.url!,
          height: 100,
        ));
  }

  void _photoFeedbackFunction(PublicMediumModel? platformMediumModel) {
    setState(() {
      _progress = null;
      widget.logoFeedback(platformMediumModel);
    });
  }

  void _photoUploading(dynamic progress) {
    if (progress != null) {}
    setState(() {
      _progress = progress;
    });
  }
}
