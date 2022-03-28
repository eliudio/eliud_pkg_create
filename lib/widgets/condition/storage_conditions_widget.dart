import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/storage_conditions_model.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../utils/combobox_widget.dart';

const String _pageAndDialogComment = """
A privilege is data secured data, i.e. the storage mechanism secures the access. So, even if a menu item would refer to a page, it's still the page / data that secures the actual access to the page itself.
(*) It's worth remembering that when a member is blocked, that person is not blocked from public view, as that person can always logoff and open the site anonymously.
""";

typedef StorageConditionsFeedback(int value);

class StorageConditionsWidget extends StatefulWidget {
  final AppModel app;
  final String ownerType; // page, dialog
  final StorageConditionsModel value;
  final StorageConditionsFeedback feedback;

  StorageConditionsWidget({
    Key? key,
    required this.app,
    required this.value,
    required this.ownerType,
    required this.feedback,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _StorageConditionState();
  }
}

class _StorageConditionState extends State<StorageConditionsWidget> {
  Widget _aBitSpace() => Container(height: 15);

  @override
  Widget build(BuildContext context) {
    var prefix = widget.ownerType;
    return topicContainer(widget.app, context,
        title: 'Access rights',
        collapsible: true,
        collapsed: true,
        children: [
          getListTile(
            context,
            widget.app,
            leading: const Icon(Icons.security),
            title: ComboboxWidget(
              app: widget.app,
              initialValue: (widget.value.privilegeLevelRequired == null)
                  ? 0
                  : widget.value.privilegeLevelRequired!.index,
              options: const [
                'No Privilege Required',
                'Level 1 Privilege Required',
                'Level 2 Privilege Required',
                'Owner Required'
              ],
              descriptions: [
                'Make this ' +
                    prefix +
                    ' accessible for the public, as well as subscribed members',
                'Make this ' +
                    prefix +
                    ' accessible for level 1 members, i.e. subscribed members with a level 1 access',
                'Make this ' +
                    prefix +
                    ' accessible for level 2 members, i.e. subscribed members with a level 2 access',
                'Make this ' +
                    prefix +
                    ' only accessible to you, as the owner ',
              ],
              feedback: (value) {
                widget.value.privilegeLevelRequired =
                    toPrivilegeLevelRequiredSimple(value);
                widget.feedback(value);
              },
              title: "Privilege Condition (*)",
            ),
          ),
          _aBitSpace(),
          text(widget.app, context, _pageAndDialogComment),
        ]);
  }
}
