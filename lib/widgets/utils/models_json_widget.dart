import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_dialog_field.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_pkg_create/platform/create_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'models_json_bloc/models_json_bloc.dart';
import 'models_json_bloc/models_json_event.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart';
import 'models_json_bloc/models_json_state.dart';
import 'models_json_destination_widget.dart';

typedef Future<
    List<AbstractModelWithInformation>> AbstractModelWithInformationsProvider();

typedef ModelsJsonConstructJsonEventToClipboard ModelsJsonConstructJsonEventToClipboardCreator();
typedef ModelsJsonConstructJsonEventToMemberMediumModel ModelsJsonConstructJsonEventToMemberMediumModelCreator(
    String baseName);

class ModelsJsonWidget extends StatefulWidget {
  final AppModel app;
  final ModelsJsonConstructJsonEventToClipboardCreator
      modelsJsonConstructJsonEventToClipboardCreator;
  final ModelsJsonConstructJsonEventToMemberMediumModelCreator
      modelsJsonConstructJsonEventToMemberMediumModelCreator;
  final String initialBaseName;

  ModelsJsonWidget._({
    Key? key,
    required this.app,
    required this.modelsJsonConstructJsonEventToClipboardCreator,
    required this.modelsJsonConstructJsonEventToMemberMediumModelCreator,
    required this.initialBaseName,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ModelsJsonWidgetState();
  }

  static Widget getIt(
      BuildContext context,
      AppModel app,
      ModelsJsonConstructJsonEventToClipboardCreator
          modelsJsonConstructJsonEventToClipboardCreator,
      ModelsJsonConstructJsonEventToMemberMediumModelCreator
          modelsJsonConstructJsonEventToMemberMediumModelCreator,
      String initialBaseName) {
    return BlocProvider<ModelsJsonBloc>(
      create: (context) =>
          ModelsJsonBloc(app)..add(ModelsJsonInitialiseEvent()),
      child: ModelsJsonWidget._(
        app: app,
        modelsJsonConstructJsonEventToClipboardCreator:
            modelsJsonConstructJsonEventToClipboardCreator,
        modelsJsonConstructJsonEventToMemberMediumModelCreator:
            modelsJsonConstructJsonEventToMemberMediumModelCreator,
        initialBaseName: initialBaseName,
      ),
    );
  }
}

class _ModelsJsonWidgetState extends State<ModelsJsonWidget> {
  late int selected;
  JsonDestination? jsonDestination;
  String? baseName;
  late List<DropdownMenuItem<int>> dropdownMenuItems;
  Widget? location;

  void initState() {
    jsonDestination = JsonDestination.MemberMedium;
    baseName = widget.initialBaseName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModelsJsonBloc, ModelsJsonState>(
        builder: (context, state) {
      return topicContainer(widget.app, context,
          title: 'Json representation',
          collapsible: true,
          collapsed: true,
          children: [
            if (state is ModelsAndJsonError)
              text(widget.app, context, 'Error: ' + state.error),
            if (state is ModelsAndJsonAvailableInClipboard)
              text(widget.app, context,
                  'Json representation available in clipboard'),
            if (state is ModelsAndJsonAvailableAsMemberMedium)
              ListView(children: [
                text(widget.app, context,
                    'Medium document : ' + state.memberMediumModel.documentID),
                text(widget.app, context,
                    'Basename : ' + (state.memberMediumModel.base ?? '?')),
                text(widget.app, context,
                    'Extension : ' + (state.memberMediumModel.ext ?? '?')),
                text(widget.app, context,
                    'Url : ' + (state.memberMediumModel.url ?? '?')),
                Center(
                    child: button(widget.app, context,
                        label: 'Copy url to clipboard', onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: state.memberMediumModel.url));
                }))
              ], shrinkWrap: true, physics: ScrollPhysics()),
            if ((state is ModelsAndJsonError) ||
                (state is ModelsAndJsonAvailableInClipboard) ||
                (state is ModelsAndJsonAvailableAsMemberMedium))
              divider(widget.app, context),
            if ((state is ModelsJsonInitialised) ||
                (state is ModelsAndJsonError) ||
                (state is ModelsAndJsonAvailableInClipboard) ||
                (state is ModelsAndJsonAvailableAsMemberMedium))
              JsonDestinationWidget(
                app: widget.app,
                jsonDestination:
                    jsonDestination ?? JsonDestination.MemberMedium,
                jsonDestinationCallback: (JsonDestination val) {
                  setState(() {
                    jsonDestination = val;
                  });
                },
              ),
            if (((state is ModelsJsonInitialised) ||
                    (state is ModelsAndJsonError) ||
                    (state is ModelsAndJsonAvailableInClipboard) ||
                    (state is ModelsAndJsonAvailableAsMemberMedium)) &&
                (jsonDestination == JsonDestination.MemberMedium))
              getListTile(context, widget.app,
                  leading: Icon(Icons.description),
                  title: dialogField(
                    widget.app,
                    context,
                    initialValue: baseName,
                    valueChanged: (value) {
                      baseName = value;
                    },
                    maxLines: 1,
                    decoration: const InputDecoration(
                      hintText: 'Name',
                      labelText: 'Name',
                    ),
                  )),
            if (((state is ModelsJsonInitialised) ||
                (state is ModelsAndJsonError) ||
                (state is ModelsAndJsonAvailableInClipboard) ||
                (state is ModelsAndJsonAvailableAsMemberMedium)) &&
                (jsonDestination == JsonDestination.Clipboard))
              button(widget.app, context, label: 'Generate', onPressed: () {
                BlocProvider.of<ModelsJsonBloc>(context).add(
                    widget.modelsJsonConstructJsonEventToClipboardCreator());
              }),
            if (((state is ModelsJsonInitialised) ||
                (state is ModelsAndJsonError) ||
                (state is ModelsAndJsonAvailableInClipboard) ||
                (state is ModelsAndJsonAvailableAsMemberMedium)) &&
                (jsonDestination == JsonDestination.MemberMedium))
              button(widget.app, context, label: 'Generate', onPressed: () {
                BlocProvider.of<ModelsJsonBloc>(context).add(widget
                    .modelsJsonConstructJsonEventToMemberMediumModelCreator(
                        baseName ?? '?'));
              }),
            if (state is ModelsJsonProgressed)
              progressIndicatorWithValue(widget.app, context,
                  value: state.progress),
          ]);
    });
  }
}
