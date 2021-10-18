/*
       _ _           _ 
      | (_)         | |
   ___| |_ _   _  __| |
  / _ \ | | | | |/ _` |
 |  __/ | | |_| | (_| |
  \___|_|_|\__,_|\__,_|
                       
 
 play_store_component.dart
                       
 This code is generated. This is read only. Don't touch!

*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/style/style_registry.dart';

import 'package:eliud_pkg_create/model/play_store_component_bloc.dart';
import 'package:eliud_pkg_create/model/play_store_component_event.dart';
import 'package:eliud_pkg_create/model/play_store_model.dart';
import 'package:eliud_pkg_create/model/play_store_repository.dart';
import 'package:eliud_pkg_create/model/play_store_component_state.dart';

abstract class AbstractPlayStoreComponent extends StatelessWidget {
  static String componentName = "playStores";
  final String? playStoreID;

  AbstractPlayStoreComponent({Key? key, this.playStoreID}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlayStoreComponentBloc> (
          create: (context) => PlayStoreComponentBloc(
            playStoreRepository: getPlayStoreRepository(context))
        ..add(FetchPlayStoreComponent(id: playStoreID)),
      child: _playStoreBlockBuilder(context),
    );
  }

  Widget _playStoreBlockBuilder(BuildContext context) {
    return BlocBuilder<PlayStoreComponentBloc, PlayStoreComponentState>(builder: (context, state) {
      if (state is PlayStoreComponentLoaded) {
        if (state.value == null) {
          return alertWidget(title: 'Error', content: 'No PlayStore defined');
        } else {
          return yourWidget(context, state.value);
        }
      } else if (state is PlayStoreComponentPermissionDenied) {
        return Icon(
          Icons.highlight_off,
          color: Colors.red,
          size: 30.0,
        );
      } else if (state is PlayStoreComponentError) {
        return alertWidget(title: 'Error', content: state.message);
      } else {
        return Center(
          child: StyleRegistry.registry().styleWithContext(context).frontEndStyle().progressIndicatorStyle().progressIndicator(context),
        );
      }
    });
  }

  Widget yourWidget(BuildContext context, PlayStoreModel? value);
  Widget alertWidget({ title: String, content: String});
  PlayStoreRepository getPlayStoreRepository(BuildContext context);
}

