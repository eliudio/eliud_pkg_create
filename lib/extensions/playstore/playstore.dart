import 'package:eliud_core/core/access/bloc/access_bloc.dart';
import 'package:eliud_core/core/navigate/router.dart' as EliudRouter;
import 'package:eliud_core/core/access/bloc/access_state.dart';
import 'package:eliud_core/core/widgets/alert_widget.dart';
import 'package:eliud_core/model/app_list_bloc.dart';
import 'package:eliud_core/model/app_list_state.dart';
import 'package:eliud_core/style/frontend/has_container.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/action/action_model.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_pkg_create/model/play_store_model.dart';
import 'package:eliud_pkg_create/tools/defaults.dart';
import 'package:eliud_pkg_create/widgets/app_widget.dart';
import 'package:eliud_pkg_create/widgets/new_app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';

class PlayStore extends StatefulWidget {
  final PlayStoreModel playStoreModel;

  PlayStore(this.playStoreModel);

  @override
  State<StatefulWidget> createState() {
    return PlayStoreState();
  }
}

class PlayStoreState extends State<PlayStore> {
  static double size = 100.0;
  PlayStoreState();

  @override
  Widget alertWidget({title = String, content = String}) {
    return AlertWidget(title: title, content: content);
  }

  @override
  Widget build(BuildContext context) {
    var member = AccessBloc.member(context);
    var state = AccessBloc.getState(context);
    if (state is AppLoaded) {
      var appID = state.app.documentID!;
      return BlocBuilder<AppListBloc, AppListState>(builder: (context, state) {
        if (state is AppListLoaded) {
          var components = <Widget>[];
          if (member != null) {
            components.add(GestureDetector(
                onTap: () async {
//                  createNewApp(context);
                  newApp(context);
                },
                child: Container(
                  //                    color: Colors.red.withOpacity(.55),
                    decoration: BoxDecoration(
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
                    child: Icon(Icons.add))));
          }
          state.values!.forEach((model) {
            if (!AccessBloc.isPlayStoreApp(context, model!.documentID!)) {
              components.add(GestureDetector(
                  onTap: () async {
                    EliudRouter.Router.navigateTo(
                        context, SwitchApp(appID, toAppID: model.documentID));
                  },
                  child: Container(
                    color: Colors.red,
                    child: ((model.logo != null) && (model.logo!.url != null)) ? Image.network(model.logo!.url!) : Icon(Icons.help),
                  )));
              //components.add(Column(children: children));
            }
          });

          return Container(
              padding: EdgeInsets.all(16.0),
              child: GridView.extent(
                  maxCrossAxisExtent: size,
                  padding: const EdgeInsets.all(0),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  physics: ScrollPhysics(), // to disable GridView's scrolling
                  shrinkWrap: true,
                  children: components));
        }
        return progressIndicator(context);
      });
    } else {
      return text(context, 'App not loaded');
    }
  }
}
