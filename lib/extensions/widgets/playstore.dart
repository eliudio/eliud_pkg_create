import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/blocs/access/state/access_determined.dart';
import 'package:eliud_core/core/blocs/access/state/access_state.dart';
import 'package:eliud_core/core/navigate/router.dart' as EliudRouter;
import 'package:eliud_core/core/widgets/alert_widget.dart';
import 'package:eliud_core/model/app_list_bloc.dart';
import 'package:eliud_core/model/app_list_state.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/tools/action/action_model.dart';
import 'package:eliud_pkg_create/model/play_store_model.dart';
import 'package:eliud_pkg_create/widgets/new_app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';

class PlayStore extends StatefulWidget {
  final AppModel app;
  final PlayStoreModel playStoreModel;

  const PlayStore(this.app, this.playStoreModel, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PlayStoreState();
  }
}

class PlayStoreState extends State<PlayStore> {
  static double size = 100.0;
  PlayStoreState();

  Widget alertWidget({title = String, content = String}) {
    return AlertWidget(app: widget.app, title: title, content: content);
  }

  @override
  Widget build(BuildContext context) {
    var app = widget.app;
    var currentAppId = widget.app.documentID!;
    return BlocBuilder<AccessBloc, AccessState>(
        builder: (context, accessState) {
      if (accessState is AccessDetermined) {
        var member = accessState.getMember();
        return BlocBuilder<AppListBloc, AppListState>(
            builder: (context, state) {
          if (state is AppListLoaded) {
            var components = <Widget>[];
            if (member != null) {
              components.add(GestureDetector(
                  onTap: () async {
                    newApp(context, member, app);
                  },
                  child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              Colors.orange,
                              Colors.orangeAccent,
                              Colors.red,
                              Colors.redAccent
                              //add more colors for gradient
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: [0, 0.2, 0.5, 0.8]),
                      ),
                      child: const Icon(Icons.add))));
            }
            for (var model in state.values!) {
              if (model != null) {
                var logo = Container(
                  color: Colors.red,
                  child: ((model.logo != null) && (model.logo!.url != null))
                      ? Image.network(model.logo!.url!)
                      : const Icon(Icons.help),
                );
                Widget component;
                if (model.documentID != currentAppId) {
                  component = GestureDetector(
                      onTap: () async {
                        EliudRouter.Router.navigateTo(context,
                            SwitchApp(app, toAppID: model.documentID!));
                      },
                      child: logo);
                } else {
                  component = Stack(children: [
                    logo,
                    Center(
                        child: ClipRect(
                            child: SizedBox(
                                height: size,
                                width: size,
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 5,
                                    sigmaY: 5,
                                  ),
                                  child: Container(
                                    color: Colors.black.withOpacity(.3),
                                  ),
                                )))),
                  ]);
                }
                components.add(component);
              }
            }

            return Container(
                padding: const EdgeInsets.all(16.0),
                child: GridView.extent(
                    maxCrossAxisExtent: size,
                    padding: const EdgeInsets.all(0),
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    physics: const ScrollPhysics(),
                    // to disable GridView's scrolling
                    shrinkWrap: true,
                    children: components));
          } else {
            return progressIndicator(app, context);
          }
        });
      } else {
        return progressIndicator(app, context);
      }
    });
  }
}
