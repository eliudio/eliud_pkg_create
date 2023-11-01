import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/blocs/access/state/access_determined.dart';
import 'package:eliud_core/core/blocs/access/state/access_state.dart';
import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_list_bloc.dart';
import 'package:eliud_core/model/app_list_event.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/member_public_info_list_bloc.dart';
import 'package:eliud_core/model/member_public_info_list_event.dart';
import 'package:eliud_core/model/member_public_info_list_state.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/component/component_constructor.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import 'package:eliud_core/tools/query/query_tools.dart';
import 'package:eliud_pkg_create/extensions/widgets/playstore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_pkg_create/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_create/model/play_store_component.dart';
import 'package:eliud_pkg_create/model/play_store_model.dart';

class PlayStoreComponentConstructorDefault implements ComponentConstructor {
  @override
  Widget createNew(
      {Key? key,
      required AppModel app,
      required String id,
      Map<String, dynamic>? parameters}) {
    return PlayStoreBase(id: id, app: app, key: key);
  }

  @override
  Future<dynamic> getModel({required AppModel app, required String id}) async =>
      await playStoreRepository(appId: app.documentID)!.get(id);
}

class PlayStoreBase extends AbstractPlayStoreComponent {
  final String id;

  PlayStoreBase({
    required AppModel app,
    required this.id,
    Key? key,
  }) : super(key: key, app: app, playStoreId: id);

  @override
  Widget yourWidget(BuildContext context, PlayStoreModel? value) {
    if (value != null) {
      return MemberAppsWidget(
        app: app,
        playStoreModel: value,
      );
    } else {
      return text(app, context, 'No playstore');
    }
  }
}

class MemberAppsWidget extends StatefulWidget {
  final AppModel app;
  final PlayStoreModel playStoreModel;
  static String ALL = 'all';
  static String MY_APPS = 'my apps';

  MemberAppsWidget({
    required this.app,
    required this.playStoreModel,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MemberAppsWidgetState();
  }
}

class _MemberAppsWidgetState extends State<MemberAppsWidget> {
  String? selectedMember;
  late bool incName;
  double? width = 300;
  final _buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    incName = false;

//    WidgetsBinding.instance?.addPostFrameCallback(_getWidgetInfo);
  }

/*
  void _getWidgetInfo(_) {
    var renderButtonObject = _buttonKey.currentContext?.findRenderObject();
    if (renderButtonObject is RenderBox) {
      var renderButtonBox = renderButtonObject;

      var sizeButtonBox = renderButtonBox.size;
      setState(() {
        width = sizeButtonBox.width;
      });
    }
  }
*/

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppListBloc>(
        create: (context) => AppListBloc(
              detailed: true,
              eliudQuery: defaultQuery(),
              appRepository: appRepository(appId: widget.app.documentID)!,
            )..add(LoadAppList()),
        child: BlocBuilder<AccessBloc, AccessState>(
            builder: (context, accessState) {
          if (accessState is AccessDetermined) {
            var currentMember = accessState.getMember();
            var currentMemberId =
                currentMember == null ? null : currentMember.documentID;
            return ListView(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                children: [
                  Column(children: [
                    BlocProvider<MemberPublicInfoListBloc>(
                        child: getListTile(context, widget.app,
                            title: MemberPublicInfoDropdownButtonWidget(
                                  app: widget.app,
                                  value: selectedMember,
                                  currentMemberId: currentMemberId,
                                  trigger: (String? value) {
                                    setState(() {
                                      selectedMember = value;
                                      BlocProvider.of<AppListBloc>(context).add(
                                          AppChangeQuery(
                                              newQuery: getQuery(
                                                  value, currentMemberId)));
                                    });
                                  }),
                            ),
                        create: (context) => MemberPublicInfoListBloc(
                              memberPublicInfoRepository:
                                  memberPublicInfoRepository()!,
                            )..add(LoadMemberPublicInfoList())),
                    checkboxListTile(
                        widget.app, context, 'Include name', incName, (value) {
                      setState(() {
                        incName = value ?? false;
                      });
                    }),
                  ]),
                  divider(widget.app, context),
                  PlayStore(widget.app, widget.playStoreModel, incName)
                ]);
          } else {
            return progressIndicator(widget.app, context);
          }
        }));
  }

  EliudQuery defaultQuery() {
    return EliudQuery(theConditions: [
      EliudQueryCondition('isFeatured', isEqualTo: true),
    ]);
  }

  EliudQuery getQuery(String? selectedMember, String? currentMemberId) {
    if ((selectedMember == MemberAppsWidget.ALL) || (selectedMember == null)) {
      return defaultQuery();
    } else if ((selectedMember == MemberAppsWidget.MY_APPS) ||
        (selectedMember == currentMemberId)) {
      return EliudQuery(theConditions: [
        EliudQueryCondition('ownerID', isEqualTo: currentMemberId),
      ]);
    } else {
      return EliudQuery(theConditions: [
        EliudQueryCondition('ownerID', isEqualTo: selectedMember),
        EliudQueryCondition('isFeatured', isEqualTo: true),
      ]);
    }
  }
}

typedef MemberPublicInfoChanged(
  String? value,
);

class MemberPublicInfoDropdownButtonWidget extends StatefulWidget {
  final AppModel app;
  String? value;
  final MemberPublicInfoChanged trigger;
  final String? currentMemberId;

  MemberPublicInfoDropdownButtonWidget(
      {required this.app,
      this.value,
      required this.trigger,
      required this.currentMemberId,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MemberPublicInfoDropdownButtonWidgetState();
  }
}

class MemberPublicInfoDropdownButtonWidgetState
    extends State<MemberPublicInfoDropdownButtonWidget> {
  MemberPublicInfoListBloc? bloc;

  MemberPublicInfoDropdownButtonWidgetState();

  @override
  void didChangeDependencies() {
    bloc = BlocProvider.of<MemberPublicInfoListBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (bloc != null) bloc!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberPublicInfoListBloc, MemberPublicInfoListState>(
        builder: (context, state) {
      if (state is MemberPublicInfoListLoading) {
        return progressIndicator(widget.app, context);
      } else if (state is MemberPublicInfoListLoaded) {
        final items = <DropdownMenuItem<String>>[];
        items.add(new DropdownMenuItem<String>(
            value: 'all', child: text(widget.app, context, 'all')));
        if (widget.currentMemberId != null) {
          items.add(new DropdownMenuItem<String>(
              value: 'my apps', child: text(widget.app, context, 'my apps')));
        }
        if ((state.values != null) && (state.values!.isNotEmpty)) {
          items.add(DropdownMenuItemSeparator());
          state.values!.forEach((element) {
            items.add(new DropdownMenuItem<String>(
                value: element!.documentID,
                child: text(
                    widget.app, context, element.name ?? element.documentID)));
          });
        }
        return dropdownButton<String>(
          widget.app, context,
          isExpanded: true,
          isDense: false,
          items: items,
          value: widget.value,
          hint: text(widget.app, context, 'Select a member'),
          onChanged: (value) => widget.trigger(value),
        );
      } else {
        return progressIndicator(widget.app, context);
      }
    });
  }
}

class DropdownMenuItemSeparator<T> extends DropdownMenuItem<T> {
  DropdownMenuItemSeparator()
      : super(
          enabled: false, // As of Flutter 2.5.
          child: Container(), // Trick the assertion.
        );

  @override
  Widget build(BuildContext context) {
    return Divider(thickness: 3);
  }
}
