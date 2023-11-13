/*
       _ _           _ 
      | (_)         | |
   ___| |_ _   _  __| |
  / _ \ | | | | |/ _` |
 |  __/ | | |_| | (_| |
  \___|_|_|\__,_|\__,_|
                       
 
 play_store_form.dart
                       
 This code is generated. This is read only. Don't touch!

*/

import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/core/blocs/access/state/access_state.dart';
import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import '../tools/bespoke_models.dart';
import 'package:eliud_core/core/navigate/router.dart' as eliudrouter;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/style/style_registry.dart';

import 'package:eliud_core/tools/enums.dart';

import 'package:eliud_core/model/model_export.dart';
import 'package:eliud_pkg_create/model/model_export.dart';

import 'package:eliud_pkg_create/model/play_store_list_bloc.dart';
import 'package:eliud_pkg_create/model/play_store_list_event.dart';
import 'package:eliud_pkg_create/model/play_store_model.dart';
import 'package:eliud_pkg_create/model/play_store_form_bloc.dart';
import 'package:eliud_pkg_create/model/play_store_form_event.dart';
import 'package:eliud_pkg_create/model/play_store_form_state.dart';

class PlayStoreForm extends StatelessWidget {
  final AppModel app;
  final FormAction formAction;
  final PlayStoreModel? value;
  final ActionModel? submitAction;

  PlayStoreForm(
      {super.key,
      required this.app,
      required this.formAction,
      required this.value,
      this.submitAction});

  /// Build the PlayStoreForm
  @override
  Widget build(BuildContext context) {
    //var accessState = AccessBloc.getState(context);
    var appId = app.documentID;
    if (formAction == FormAction.showData) {
      return BlocProvider<PlayStoreFormBloc>(
        create: (context) => PlayStoreFormBloc(
          appId,
          formAction: formAction,
        )..add(InitialisePlayStoreFormEvent(value: value)),
        child: _MyPlayStoreForm(
            app: app, submitAction: submitAction, formAction: formAction),
      );
    }
    if (formAction == FormAction.showPreloadedData) {
      return BlocProvider<PlayStoreFormBloc>(
        create: (context) => PlayStoreFormBloc(
          appId,
          formAction: formAction,
        )..add(InitialisePlayStoreFormNoLoadEvent(value: value)),
        child: _MyPlayStoreForm(
            app: app, submitAction: submitAction, formAction: formAction),
      );
    } else {
      return Scaffold(
          appBar: StyleRegistry.registry()
              .styleWithApp(app)
              .adminFormStyle()
              .appBarWithString(app, context,
                  title: formAction == FormAction.updateAction
                      ? 'Update PlayStore'
                      : 'Add PlayStore'),
          body: BlocProvider<PlayStoreFormBloc>(
            create: (context) => PlayStoreFormBloc(
              appId,
              formAction: formAction,
            )..add((formAction == FormAction.updateAction
                ? InitialisePlayStoreFormEvent(value: value)
                : InitialiseNewPlayStoreFormEvent())),
            child: _MyPlayStoreForm(
                app: app, submitAction: submitAction, formAction: formAction),
          ));
    }
  }
}

class _MyPlayStoreForm extends StatefulWidget {
  final AppModel app;
  final FormAction? formAction;
  final ActionModel? submitAction;

  _MyPlayStoreForm({required this.app, this.formAction, this.submitAction});

  @override
  State<_MyPlayStoreForm> createState() => _MyPlayStoreFormState(formAction);
}

class _MyPlayStoreFormState extends State<_MyPlayStoreForm> {
  final FormAction? formAction;
  late PlayStoreFormBloc _myFormBloc;

  final TextEditingController _documentIDController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  _MyPlayStoreFormState(this.formAction);

  @override
  void initState() {
    super.initState();
    _myFormBloc = BlocProvider.of<PlayStoreFormBloc>(context);
    _documentIDController.addListener(_onDocumentIDChanged);
    _descriptionController.addListener(_onDescriptionChanged);
  }

  @override
  Widget build(BuildContext context) {
    var accessState = AccessBloc.getState(context);
    return BlocBuilder<PlayStoreFormBloc, PlayStoreFormState>(
        builder: (context, state) {
      if (state is PlayStoreFormUninitialized) {
        return Center(
          child: StyleRegistry.registry()
              .styleWithApp(widget.app)
              .adminListStyle()
              .progressIndicator(widget.app, context),
        );
      }

      if (state is PlayStoreFormLoaded) {
        _documentIDController.text = state.value!.documentID.toString();
        _descriptionController.text = state.value!.description.toString();
      }
      if (state is PlayStoreFormInitialized) {
        List<Widget> children = [];
        children.add(Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: StyleRegistry.registry()
                .styleWithApp(widget.app)
                .adminFormStyle()
                .groupTitle(widget.app, context, 'General')));

        children.add(StyleRegistry.registry()
            .styleWithApp(widget.app)
            .adminFormStyle()
            .textFormField(widget.app, context,
                labelText: 'Document ID',
                icon: Icons.vpn_key,
                readOnly: (formAction == FormAction.updateAction),
                textEditingController: _documentIDController,
                keyboardType: TextInputType.text,
                validator: (_) => state is DocumentIDPlayStoreFormError
                    ? state.message
                    : null,
                hintText: null));

        children.add(StyleRegistry.registry()
            .styleWithApp(widget.app)
            .adminFormStyle()
            .textFormField(widget.app, context,
                labelText: 'description',
                icon: Icons.text_format,
                readOnly: _readOnly(accessState, state),
                textEditingController: _descriptionController,
                keyboardType: TextInputType.text,
                validator: (_) => state is DescriptionPlayStoreFormError
                    ? state.message
                    : null,
                hintText: null));

        children.add(Container(height: 20.0));
        children.add(StyleRegistry.registry()
            .styleWithApp(widget.app)
            .adminFormStyle()
            .divider(widget.app, context));

        children.add(Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: StyleRegistry.registry()
                .styleWithApp(widget.app)
                .adminFormStyle()
                .groupTitle(widget.app, context, 'Background')));

        children.add(Container(height: 20.0));
        children.add(StyleRegistry.registry()
            .styleWithApp(widget.app)
            .adminFormStyle()
            .divider(widget.app, context));

        children.add(Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: StyleRegistry.registry()
                .styleWithApp(widget.app)
                .adminFormStyle()
                .groupTitle(widget.app, context, 'Conditions')));

        children.add(Container(height: 20.0));
        children.add(StyleRegistry.registry()
            .styleWithApp(widget.app)
            .adminFormStyle()
            .divider(widget.app, context));

        if ((formAction != FormAction.showData) &&
            (formAction != FormAction.showPreloadedData)) {
          children.add(StyleRegistry.registry()
              .styleWithApp(widget.app)
              .adminFormStyle()
              .button(
                widget.app,
                context,
                label: 'Submit',
                onPressed: _readOnly(accessState, state)
                    ? null
                    : () {
                        if (state is PlayStoreFormError) {
                          return;
                        } else {
                          if (formAction == FormAction.updateAction) {
                            BlocProvider.of<PlayStoreListBloc>(context)
                                .add(UpdatePlayStoreList(
                                    value: state.value!.copyWith(
                              documentID: state.value!.documentID,
                              appId: state.value!.appId,
                              description: state.value!.description,
                              backgroundIcon: state.value!.backgroundIcon,
                              conditions: state.value!.conditions,
                            )));
                          } else {
                            BlocProvider.of<PlayStoreListBloc>(context)
                                .add(AddPlayStoreList(
                                    value: PlayStoreModel(
                              documentID: state.value!.documentID,
                              appId: state.value!.appId,
                              description: state.value!.description,
                              backgroundIcon: state.value!.backgroundIcon,
                              conditions: state.value!.conditions,
                            )));
                          }
                          if (widget.submitAction != null) {
                            eliudrouter.Router.navigateTo(
                                context, widget.submitAction!);
                          } else {
                            Navigator.pop(context);
                          }
                        }
                      },
              ));
        }

        return StyleRegistry.registry()
            .styleWithApp(widget.app)
            .adminFormStyle()
            .container(
                widget.app,
                context,
                Form(
                  child: ListView(
                      padding: const EdgeInsets.all(8),
                      physics: ((formAction == FormAction.showData) ||
                              (formAction == FormAction.showPreloadedData))
                          ? NeverScrollableScrollPhysics()
                          : null,
                      shrinkWrap: ((formAction == FormAction.showData) ||
                          (formAction == FormAction.showPreloadedData)),
                      children: children),
                ),
                formAction!);
      } else {
        return StyleRegistry.registry()
            .styleWithApp(widget.app)
            .adminListStyle()
            .progressIndicator(widget.app, context);
      }
    });
  }

  void _onDocumentIDChanged() {
    _myFormBloc
        .add(ChangedPlayStoreDocumentID(value: _documentIDController.text));
  }

  void _onDescriptionChanged() {
    _myFormBloc
        .add(ChangedPlayStoreDescription(value: _descriptionController.text));
  }

  @override
  void dispose() {
    _documentIDController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Is the form read-only?
  bool _readOnly(AccessState accessState, PlayStoreFormInitialized state) {
    return (formAction == FormAction.showData) ||
        (formAction == FormAction.showPreloadedData) ||
        (!accessState.memberIsOwner(widget.app.documentID));
  }
}
