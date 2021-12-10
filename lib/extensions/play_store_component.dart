import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/blocs/access/state/access_determined.dart';
import 'package:eliud_core/core/blocs/access/state/access_state.dart';
import 'package:eliud_core/core/widgets/alert_widget.dart';
import 'package:eliud_core/model/app_list_bloc.dart';
import 'package:eliud_core/model/app_list_event.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/tools/component/component_constructor.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import 'package:eliud_pkg_create/extensions/playstore/playstore.dart';
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
  Widget createNew({Key? key, required String appId, required String id, Map<String, dynamic>? parameters}) {
    return PlayStoreBase(id: id, appId: appId, key: key);
  }

  @override
  Future<dynamic> getModel({required String appId, required String id}) async => await playStoreRepository(appId: appId)!.get(id);
}

class PlayStoreBase extends AbstractPlayStoreComponent {
  final String id;

  PlayStoreBase({required String appId, required this.id, Key? key, }) : super(key: key, theAppId: appId, playStoreId: id);

  @override
  Widget yourWidget(BuildContext context, PlayStoreModel? value) {
    return BlocBuilder<AccessBloc, AccessState>(
        builder: (context, accessState) {
          if (accessState is AccessDetermined) {
            var appId = accessState.currentApp.documentID!;
            return BlocProvider<AppListBloc>(
                create: (context) =>
                AppListBloc(
                  detailed: true,
                  eliudQuery: null, // for now all
                  appRepository: appRepository(
                      appId: appId)!,
                )
                  ..add(LoadAppList()),
                child: PlayStore(value!));
          } else {
            return progressIndicator(context);
          }
        });
  }
}