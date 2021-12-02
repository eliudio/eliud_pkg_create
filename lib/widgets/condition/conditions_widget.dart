import 'package:eliud_core/core/blocs/access/helper/access_helpers.dart';
import 'package:eliud_core/model/conditions_model.dart';
import 'package:eliud_core/package/packages.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_pkg_create/widgets/condition/package_condition_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../utils/combobox_widget.dart';

const comment2 = """
(**) It's worth remembering that when a member is blocked, that person is not blocked from public view, as that person can always logoff and open the site anonymously.
""";

const String menuItemComment = """
A menu item condition allows to limit access to a menu item. However, because access conditions can also be specified on the level of a page / dialog, in case a menu item refers to a page or dialog, it's condition also depends on that page / dialog condition. Because of this, we recommend not to use conditions on the level of menu item for a page or dialog and use it for workflows or other actions, e.g. login/logout, ...

(*) Privilege and display conditions for menu items are both display only conditions, in contrast to conditions for pages and dialogs. If you want to protect you data, set the privilege of the page, dialog and most importantly the component itself, which is where your actual data sits.
""" +
    comment2;

const String pageAndDialogComment = """
(*) Privilege vs 'Display' condition. A privilege is data secured data, i.e. the storage mechanism secures the access. Whereas a 'Display' condition can be used to further restrict the visibility of this page in the app, i.e. this is secured by the app, not cloud secured and so therefore theoretically this rule can bypassed, e.g. by a hacker
(**) It's worth remembering that when a member is blocked, that person is not blocked from public view, as that person can always logoff and open the site anonymously.
""" +
    comment2;

class ConditionsWidget extends StatefulWidget {
  final String ownerType; // page, dialog, menu item
  final ConditionsModel value;
  final String comment;

  // see firestore rules
  String? packageCondition;

  // see firestore rules
  ConditionOverride? conditionOverride;

  ConditionsWidget({
    Key? key,
    required this.value,
    required this.ownerType,
    required this.comment,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ConditionPrivilegeState();
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

class _ConditionPrivilegeState extends State<ConditionsWidget> {
  _ConditionPrivilegeState();

  Widget _aBitSpace() => Container(height: 15);

  @override
  Widget build(BuildContext context) {
    var prefix = widget.ownerType;
    return topicContainer(context,
        title: 'Access rights',
        collapsible: true,
        collapsed: true,
        children: [
          getListTile(
            context,
            leading: const Icon(Icons.security),
            title: ComboboxWidget(
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
              feedback: (value) => widget.value.privilegeLevelRequired =
                  toPrivilegeLevelRequired(value),
              title: "Privilege Condition (*)",
            ),
          ),
          _aBitSpace(),
          getListTile(
            context,
            leading: const Icon(Icons.security),
            title: PackageConditionWidget(
                initialPackageCondition: widget.value.packageCondition,
                packageInfos: getAllPackageConditionsAsPackageInfos2(),
                feedback: (value) => widget.value.packageCondition = value),
          ),
          _aBitSpace(),
          getListTile(
            context,
            leading: const Icon(Icons.security),
            title: ComboboxWidget(
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
          text(context, widget.comment),
        ]);
  }
}
