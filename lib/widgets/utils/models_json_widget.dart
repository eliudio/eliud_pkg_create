import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
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

typedef Future<
    List<AbstractModelWithInformation>> AbstractModelWithInformationsProvider();

class ModelsJsonWidget extends StatefulWidget {
  final AppModel app;
  final ModelsJsonConstructJsonEvent constructEvent;

  ModelsJsonWidget._({
    Key? key,
    required this.app,
    required this.constructEvent,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ModelsJsonWidgetState();
  }

  static Widget getIt(
    BuildContext context,
    AppModel app,
    ModelsJsonConstructJsonEvent constructEvent,
  ) {
    return BlocProvider<ModelsJsonBloc>(
      create: (context) => ModelsJsonBloc(app)..add(ModelsJsonInitialiseEvent()),
      child: ModelsJsonWidget._(
        app: app,
        constructEvent: constructEvent,
      ),
    );
  }
}

class _ModelsJsonWidgetState extends State<ModelsJsonWidget> {
  late int selected;
  late List<DropdownMenuItem<int>> dropdownMenuItems;
  Widget? location;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModelsJsonBloc, ModelsJsonState>(
        builder: (context, state) {
          return topicContainer(widget.app, context,
              title: 'Json representation',
              collapsible: true,
              collapsed: true,
              children: [
                if (state is ModelsJsonInitialised)
                  iconButton(widget.app, context, icon: Icon(Icons.run_circle),
                      onPressed: () async {
                        BlocProvider.of<ModelsJsonBloc>(context).add(
                            widget.constructEvent);
                      }),
                if (state is ModelsJsonProgressed)
                  progressIndicatorWithValue(widget.app, context, value: state.progress),
                if (state is ModelsAndJsonAvailable)
                  Row(children: [
                    AbstractCreatePlatform.platform.openJsonAsLink(
                        context, widget.app, state.jsonString),
                    iconButton(widget.app, context, icon: Icon(Icons.copy),
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: state.jsonString));
                        }),
                  ]),
              ]
          );
    });
  }

}
