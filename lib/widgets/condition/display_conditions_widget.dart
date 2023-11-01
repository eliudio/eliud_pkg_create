import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/display_conditions_model.dart';
import 'package:eliud_core/package/packages.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_pkg_create/widgets/condition/package_condition_widget.dart';
import 'package:flutter/material.dart';

import '../utils/combobox_widget.dart';

const String _menuItemComment = """
A menu item condition allows to limit access to a menu item. This is a display only condition to improve user experience. To limit access to the data, set the (privilege) condition on the level of the page / dialog / component itself.
""";

/*
const String pageAndDialogComment = """
(*) Privilege vs 'Display' condition. A privilege is data secured data, i.e. the storage mechanism secures the access. Whereas a 'Display' condition can be used to further restrict the visibility of this page in the app, i.e. this is secured by the app, not cloud secured and so therefore theoretically this rule can bypassed, e.g. by a hacker
(**) It's worth remembering that when a member is blocked, that person is not blocked from public view, as that person can always logoff and open the site anonymously.
""";
*/

class DisplayConditionsWidget extends StatefulWidget {
  final DisplayConditionsModel value;
  final AppModel app;

  DisplayConditionsWidget({
    Key? key,
    required this.app,
    required this.value,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DisplayConditionState();
  }
}

class PackageInfo2 {
  final String packageName;
  final String packageCondition;

  PackageInfo2(this.packageName, this.packageCondition);
}

List<PackageInfo2> getAllPackageConditionsAsPackageInfos2() {
  var packageInfos = <PackageInfo2>[];
  for (var i = 0; i < Packages.registeredPackages.length; i++) {
    var package = Packages.registeredPackages[i];
    var packageConditions = package.retrieveAllPackageConditions();
    if (packageConditions != null) {
      for (var j = 0; j < packageConditions.length; j++) {
        packageInfos
            .add(PackageInfo2(package.packageName, packageConditions[j]));
      }
    }
  }
  return packageInfos;
}

class _DisplayConditionState extends State<DisplayConditionsWidget> {
  Widget _aBitSpace() => Container(height: 15);

  @override
  Widget build(BuildContext context) {
    return topicContainer(widget.app, context,
        title: 'Access rights',
        collapsible: true,
        collapsed: true,
        children: [
          getListTile(
            context,widget.app,
            leading: const Icon(Icons.security),
            title: ComboboxWidget(app: widget.app,
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
                'Make this menu item accessible for the public, as well as subscribed members',
                'Make this menu item accessible for level 1 members, i.e. subscribed members with a level 1 access',
                'Make this menu item accessible for level 2 members, i.e. subscribed members with a level 2 access',
                'Make this menu item only accessible to you, as the owner ',
              ],
              feedback: (value) => widget.value.privilegeLevelRequired =
                  toPrivilegeLevelRequired(value),
              title: "Privilege Condition (*)",
            ),
          ),
          _aBitSpace(),
          getListTile(
            context,widget.app,
            leading: const Icon(Icons.security),
            title: PackageConditionWidget(app: widget.app,
                initialPackageCondition: widget.value.packageCondition,
                packageInfos: getAllPackageConditionsAsPackageInfos2(),
                feedback: (value) => widget.value.packageCondition = value),
          ),
          _aBitSpace(),
          getListTile(
            context,widget.app,
            leading: const Icon(Icons.security),
            title: ComboboxWidget(app: widget.app,
              initialValue: (widget.value.conditionOverride == null) ||
                      (widget.value.conditionOverride ==
                          ConditionOverride.Unknown)
                  ? 0
                  : widget.value.conditionOverride!.index + 1,
              options: const [
                'Not set',
                'Exact Privilege',
                'Inclusive For Blocked Members',
                'Exclusive For Blocked Member',
              ],
              descriptions: const [
                'Override not set',
                'In normal circumstances, a member sees all pages with less or equal required privileges than the one this member has. However, if a page is indicated to be visible only for ExactPrivilege only, then those pages with less required privileges are not visible. An example to illustrate where this might work is when we want to create a welcome page for each specific privilege.',
                "Allow for blocked members to see this page (**). This can be used for example to allow blocked members to see his notifications and assignments, allowing to be informed about the fact that he's blocked and take action to fix it.",
                'Allow only blocked members to see this page.',
              ],
              feedback: (value) => widget.value.conditionOverride =
                  toConditionOverride(value - 1),
              title: "Override Condition - display condition",
              //  - This can be used to further restrict the visibility of this page. This is 'display' condition
              //, i.e. this is secured by the app, not cloud secured and so therefore theoretically this rule can bypassed, e.g. by a hacker
            ),
          ),
          _aBitSpace(),
          text(widget.app, context, _menuItemComment),
        ]);
  }
}
