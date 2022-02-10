import 'package:eliud_pkg_workflow/model/workflow_model.dart';

class ActionSpecification {
  bool requiresAccessToLocalFileSystem;
  bool availableInLeftDrawer;
  bool availableInRightDrawer;
  bool availableInAppBar;
  bool availableInHomeMenu;
  bool available; // available but not from any menu

  ActionSpecification(
      {
        required this.requiresAccessToLocalFileSystem,
        required this.availableInLeftDrawer,
      required this.availableInRightDrawer,
        required this.availableInAppBar,
        required this.availableInHomeMenu,
        required this.available});

  bool shouldCreatePageDialogOrWorkflow() =>
      availableInLeftDrawer ||
      availableInRightDrawer ||
      availableInAppBar ||
      availableInHomeMenu ||
      available;
}

enum ShopPaymentType { Manual, Card }

class ShopActionSpecifications extends ActionSpecification {
  final ShopPaymentType paymentType;

  ShopActionSpecifications({
    required this.paymentType,
    required bool requiresAccessToLocalFileSystem,
    required bool availableInLeftDrawer,
    required bool availableInRightDrawer,
    required bool availableInAppBar,
    required bool availableInHomeMenu,
    required bool available,
  }) : super(
      requiresAccessToLocalFileSystem: requiresAccessToLocalFileSystem,
      availableInLeftDrawer: availableInLeftDrawer,
      availableInRightDrawer: availableInRightDrawer,
      availableInAppBar: availableInAppBar,
      availableInHomeMenu: availableInHomeMenu,
      available: available);
}



enum JoinPaymentType { Manual, Card }

class JoinActionSpecifications extends ActionSpecification {
  final JoinPaymentType paymentType;

  JoinActionSpecifications({
    required this.paymentType,
    required bool requiresAccessToLocalFileSystem,
    required bool availableInLeftDrawer,
    required bool availableInRightDrawer,
    required bool availableInAppBar,
    required bool availableInHomeMenu,
    required bool available,
  }) : super(
      requiresAccessToLocalFileSystem: requiresAccessToLocalFileSystem,
      availableInLeftDrawer: availableInLeftDrawer,
      availableInRightDrawer: availableInRightDrawer,
      availableInAppBar: availableInAppBar,
      availableInHomeMenu: availableInHomeMenu,
      available: available);
}