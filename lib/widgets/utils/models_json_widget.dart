import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_dialog_field.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models_json_bloc/models_json_bloc.dart';
import 'models_json_bloc/models_json_event.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'models_json_bloc/models_json_state.dart';
import 'models_json_destination_widget.dart';
import 'package:intl/intl.dart';

typedef AbstractModelWithInformationsProvider
    = Future<List<AbstractModelWithInformation>> Function();

typedef ModelsJsonConstructJsonEventToClipboardCreator
    = ModelsJsonConstructJsonEventToClipboard Function();
typedef ModelsJsonConstructJsonEventToMemberMediumModelCreator
    = ModelsJsonConstructJsonEventToMemberMediumModel Function(String baseName);

String getJsonFilename(String documentId, String extension) {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('EEE d MMM y kk:mm:ss').format(now);
  return '$documentId $formattedDate.$extension.json';
}

class ModelsJsonWidget extends StatefulWidget {
  final AppModel app;
  final ModelsJsonConstructJsonEventToClipboardCreator
      modelsJsonConstructJsonEventToClipboardCreator;
  final ModelsJsonConstructJsonEventToMemberMediumModelCreator
      modelsJsonConstructJsonEventToMemberMediumModelCreator;
  final String initialBaseName;

  ModelsJsonWidget._({
    required this.app,
    required this.modelsJsonConstructJsonEventToClipboardCreator,
    required this.modelsJsonConstructJsonEventToMemberMediumModelCreator,
    required this.initialBaseName,
  });

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

  @override
  void initState() {
    jsonDestination = JsonDestination.memberMedium;
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
              text(widget.app, context, 'Error: ${state.error}'),
            if (state is ModelsAndJsonAvailableInClipboard)
              text(widget.app, context,
                  'Json representation available in clipboard'),
            if (state is ModelsAndJsonAvailableAsMemberMedium)
              topicContainer(
                widget.app,
                context,
                title: 'Results',
                collapsible: true,
                collapsed: true,
                children: [
                  text(widget.app, context,
                      'Medium document : ${state.memberMediumModel.documentID}'),
                  text(widget.app, context,
                      'Basename : ${state.memberMediumModel.base ?? '?'}'),
                  text(widget.app, context,
                      'Extension : ${state.memberMediumModel.ext ?? '?'}'),
                  text(widget.app, context,
                      'Url : ${state.memberMediumModel.url ?? '?'}'),
                  Center(
                      child: button(widget.app, context,
                          label: 'Copy url to clipboard', onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: state.memberMediumModel.url ?? ''));
                  }))
                ],
              ),
            if ((state is ModelsJsonInitialised) ||
                (state is ModelsAndJsonError) ||
                (state is ModelsAndJsonAvailableInClipboard) ||
                (state is ModelsAndJsonAvailableAsMemberMedium))
              topicContainer(widget.app, context,
                  title: 'Destination type',
                  collapsible: true,
                  collapsed: true,
                  children: [
                    JsonDestinationWidget(
                      app: widget.app,
                      jsonDestination:
                          jsonDestination ?? JsonDestination.memberMedium,
                      jsonDestinationCallback: (JsonDestination val) {
                        setState(() {
                          jsonDestination = val;
                        });
                      },
                    ),
                  ]),
            if (((state is ModelsJsonInitialised) ||
                    (state is ModelsAndJsonError) ||
                    (state is ModelsAndJsonAvailableInClipboard) ||
                    (state is ModelsAndJsonAvailableAsMemberMedium)) &&
                (jsonDestination == JsonDestination.memberMedium))
              topicContainer(widget.app, context,
                  title: 'Name',
                  collapsible: true,
                  collapsed: true,
                  children: [
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
                  ]),
            if (((state is ModelsJsonInitialised) ||
                    (state is ModelsAndJsonError) ||
                    (state is ModelsAndJsonAvailableInClipboard) ||
                    (state is ModelsAndJsonAvailableAsMemberMedium)) &&
                (jsonDestination == JsonDestination.clipboard))
              Center(
                  child: button(widget.app, context, label: 'Generate',
                      onPressed: () {
                BlocProvider.of<ModelsJsonBloc>(context).add(
                    widget.modelsJsonConstructJsonEventToClipboardCreator());
              })),
            if (((state is ModelsJsonInitialised) ||
                    (state is ModelsAndJsonError) ||
                    (state is ModelsAndJsonAvailableInClipboard) ||
                    (state is ModelsAndJsonAvailableAsMemberMedium)) &&
                (jsonDestination == JsonDestination.memberMedium))
              Center(
                  child: button(widget.app, context, label: 'Generate',
                      onPressed: () {
                BlocProvider.of<ModelsJsonBloc>(context).add(widget
                    .modelsJsonConstructJsonEventToMemberMediumModelCreator(
                        baseName ?? '?'));
              })),
            if (state is ModelsJsonProgressed)
              progressIndicatorWithValue(widget.app, context,
                  value: state.progress),
          ]);
    });
  }
}
