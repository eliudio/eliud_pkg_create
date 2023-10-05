import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_medium_list.dart';
import 'package:eliud_core/model/member_medium_list_bloc.dart';
import 'package:eliud_core/model/member_medium_list_event.dart';
import 'package:eliud_core/model/member_medium_list_state.dart';
import 'package:eliud_core/model/member_medium_model.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/query/query_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef JsonMemberMediumCallback = Function(MemberMediumModel? memberMedium);

class JsonMemberMediumWidget extends StatefulWidget {
  final JsonMemberMediumCallback jsonMemberMediumCallback;
  final MemberMediumModel? initialValue;
  final String ext;
  final AppModel app;

  JsonMemberMediumWidget({
    Key? key,
    required this.app,
    required this.ext,
    required this.initialValue,
    required this.jsonMemberMediumCallback,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _JsonMemberMediumWidgetState();
  }
}

class _JsonMemberMediumWidgetState extends State<JsonMemberMediumWidget> {
  @override
  Widget build(BuildContext context) {
    var currentMember = AccessBloc.member(context);
    if (currentMember != null) {
      return BlocProvider<MemberMediumListBloc>(
          create: (context) => MemberMediumListBloc(
                eliudQuery: EliudQuery(theConditions: [
                  EliudQueryCondition('readAccess',
                      arrayContains: currentMember.documentID),
                  EliudQueryCondition('mediumType',
                      isEqualTo: MediumType.Text.index),
                  EliudQueryCondition('ext', isEqualTo: widget.ext),
                ]),
                orderBy: 'base',
                descending: true,
                memberMediumRepository:
                    memberMediumRepository(appId: widget.app.documentID)!,
              )..add(LoadMemberMediumList()),
          child: memberMediumDropDown());
    } else {
      return text(widget.app, context, 'No member logged on');
    }
  }

  Widget memberMediumDropDown() {
    var accessState = AccessBloc.getState(context);
    return BlocBuilder<MemberMediumListBloc, MemberMediumListState>(
        builder: (context, state) {
      if (state is MemberMediumListLoaded) {
        final items = <DropdownMenuItem<MemberMediumModel>>[];
        if (state.values!.isNotEmpty) {
          state.values!.forEach((element) {
            items.add(new DropdownMenuItem<MemberMediumModel>(
                value: element,
                child: new Container(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  height: 100.0,
                  child: text(widget.app, context,
                        (element!.base ?? 'no filename') + '.' + (element.ext ?? '.')),
/*
                    text(widget.app, context,
                        element.documentID)
                  ]),
*/
                )));
          });
        }
        return dropdownButton<MemberMediumModel>(
          widget.app, context,
          isDense: false,
          isExpanded: true,
          items: items,
          value: widget.initialValue,
          hint: text(widget.app, context, 'Select a medium'),
          onChanged: _onValueChange,
        );
      } else {
        return progressIndicator(widget.app, context);
      }
    });
  }

  void _onValueChange(MemberMediumModel? value) {
    widget.jsonMemberMediumCallback(value);
  }
}
