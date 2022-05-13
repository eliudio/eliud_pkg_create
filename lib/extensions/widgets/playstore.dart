import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/blocs/access/state/access_determined.dart';
import 'package:eliud_core/core/blocs/access/state/access_state.dart';
import 'package:eliud_core/core/navigate/router.dart' as EliudRouter;
import 'package:eliud_core/core/widgets/alert_widget.dart';
import 'package:eliud_core/model/app_list_bloc.dart';
import 'package:eliud_core/model/app_list_state.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/action/action_model.dart';
import 'package:eliud_core/tools/etc.dart';
import 'package:eliud_pkg_create/model/play_store_model.dart';
import 'package:eliud_pkg_create/widgets/new_app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';

class PlayStore extends StatefulWidget {
  final AppModel app;
  final PlayStoreModel playStoreModel;
  final bool incName;

  const PlayStore(this.app, this.playStoreModel, this.incName, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PlayStoreState();
  }
}

class PlayStoreState extends State<PlayStore> {
  static double size = 150.0;
  static double textHeight = 40.0;
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
                      clipBehavior:
                          (widget.playStoreModel.backgroundIcon == null)
                              ? Clip.none
                              : Clip.hardEdge,
                      decoration: widget.playStoreModel.backgroundIcon == null
                          ? null
                          : BoxDecorationHelper.boxDecoration(app, member,
                              widget.playStoreModel.backgroundIcon),
                      child: const Icon(Icons.add))));
            }
            for (var model in state.values!) {
              if (model != null) {
                var logo = (widget.incName)
                    ? Container(
                        padding: const EdgeInsets.all(5.0),
                        clipBehavior:
                            (widget.playStoreModel.backgroundIcon == null)
                                ? Clip.none
                                : Clip.hardEdge,
                        decoration: widget.playStoreModel.backgroundIcon == null
                            ? null
                            : BoxDecorationHelper.boxDecoration(app, member,
                                widget.playStoreModel.backgroundIcon),
                        child: ListView(
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            children: [
                              Container(
                                  height: 151 - 52,
                                  child: ((model.logo != null) &&
                                          (model.logo!.url != null))
                                      ? Image.network(model.logo!.url!)
                                      : const Icon(Icons.help)),
                              Container(
                                  height: 41,
                                  child: Center(
                                      child: smallText(
                                          widget.app,
                                          context,
                                          model.title ??
                                              model.documentID ??
                                              ''))),
                            ]))
                    : Container(
                        clipBehavior:
                            (widget.playStoreModel.backgroundIcon == null)
                                ? Clip.none
                                : Clip.hardEdge,
                        decoration: widget.playStoreModel.backgroundIcon == null
                            ? null
                            : BoxDecorationHelper.boxDecoration(app, member,
                                widget.playStoreModel.backgroundIcon),
                        child:
                            ((model.logo != null) && (model.logo!.url != null))
                                ? Image.network(model.logo!.url!)
                                : const Icon(Icons.help));
                Widget component;
                if ((model.documentID != currentAppId) &&
                    ((model.appStatus == AppStatus.Live) ||
                        ((member != null) &&
                            (model.ownerID == member.documentID)))) {
                  component = GestureDetector(
                      onTap: () async {
                        EliudRouter.Router.navigateTo(context,
                            SwitchApp(app, toAppID: model.documentID!));
                      },
                      child: logo);
                  components.add(component);
                }
              }
            }

            return Container(
                padding: const EdgeInsets.all(16.0),
                child: GridView.extent(
                    maxCrossAxisExtent: 151,
                    padding: const EdgeInsets.all(20),
                    mainAxisSpacing: 30,
                    crossAxisSpacing: 30,
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
