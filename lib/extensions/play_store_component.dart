import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/blocs/access/state/access_determined.dart';
import 'package:eliud_core/core/blocs/access/state/access_state.dart';
import 'package:eliud_core/core/widgets/alert_widget.dart';
import 'package:eliud_core/model/app_list_bloc.dart';
import 'package:eliud_core/model/app_list_event.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/tools/component/component_constructor.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import 'package:eliud_pkg_create/extensions/widgets/playstore.dart';
import 'package:eliud_pkg_create/model/play_store_list_bloc.dart';
import 'package:eliud_pkg_create/model/play_store_list_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:eliud_pkg_create/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_create/model/play_store_component.dart';
import 'package:eliud_pkg_create/model/play_store_model.dart';
import 'package:eliud_pkg_create/model/play_store_repository.dart';

class PlayStoreComponentConstructorDefault implements ComponentConstructor {
  @override
  Widget createNew({Key? key, required AppModel app, required String id, Map<String, dynamic>? parameters}) {
    return PlayStoreBase(id: id, app: app, key: key);
  }

  @override
  Future<dynamic> getModel({required AppModel app, required String id}) async => await playStoreRepository(appId: app.documentID!)!.get(id);
}

class PlayStoreBase extends AbstractPlayStoreComponent {
  final String id;

  PlayStoreBase({required AppModel app, required this.id, Key? key, }) : super(key: key, app: app, playStoreId: id);

  @override
  Widget yourWidget(BuildContext context, PlayStoreModel? value) {
    return BlocBuilder<AccessBloc, AccessState>(
        builder: (context, accessState) {
          if (accessState is AccessDetermined) {
            return BlocProvider<AppListBloc>(
                create: (context) =>
                AppListBloc(
                  detailed: true,
                  eliudQuery: null, // for now all
                  appRepository: appRepository(
                      appId: app.documentID)!,
                )
                  ..add(LoadAppList()),
                child: PlayStore(app, value!));
          } else {
            return progressIndicator(app, context);
          }
        });
  }
}