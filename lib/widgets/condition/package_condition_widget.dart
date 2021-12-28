import 'package:eliud_core/core/blocs/access/helper/access_helpers.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'display_conditions_widget.dart';

typedef Feedback(String? packageCondition);

class PackageConditionWidget extends StatefulWidget {
  final AppModel app;
  final String? initialPackageCondition;
  final List<PackageInfo2> packageInfos;
  final Feedback feedback;

  PackageConditionWidget({
    Key? key,
    required this.app,
    required this.packageInfos,
    required this.initialPackageCondition,
    required this.feedback,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PackageConditionWidgetState();
  }
}

class _PackageConditionWidgetState extends State<PackageConditionWidget> {
  late int selected;
  late List<DropdownMenuItem<int>> dropdownMenuItems;

  @override
  void initState() {
    selected = 0;
    dropdownMenuItems = [];
    dropdownMenuItems.add(DropdownMenuItem<int>(
        value: 0, child: text(widget.app, context, 'No package condition')));
    for (int i = 0; i < widget.packageInfos.length; i++) {
      var packageCondition = widget.packageInfos[i].packageCondition;
      if ((widget.initialPackageCondition != null) &&
          (packageCondition == widget.initialPackageCondition)) {
        selected = i + 1;
      }
      dropdownMenuItems.add(DropdownMenuItem<int>(
          value: i + 1,
          child: text(widget.app, context, widget.packageInfos[i].packageCondition)));
    }

    super.initState();
  }

  void _onChange(int? newValue) {
    if (newValue != null) {
      setState(() {
        selected = newValue;
        if (selected == 0) {
          widget.feedback(null);
        } else {
          var selectedPackageInfo = widget.packageInfos[selected - 1];
          widget.feedback(selectedPackageInfo.packageCondition);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Align(alignment: Alignment.centerLeft, child: inputDecorationLabel(widget.app, context, "Select package condition - Display condition (*)")),
      Align(alignment: Alignment.centerLeft, child: DropdownButton<int>(
        isDense: false,
        isExpanded: false,
        items: dropdownMenuItems,
        value: selected,
        hint: text(widget.app, context, 'Select package condition'),
        onChanged: (value) => _onChange(value),
      ))
    ]);
  }
}
