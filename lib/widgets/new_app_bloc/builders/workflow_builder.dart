import 'package:eliud_core/model/display_conditions_model.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_pkg_membership/membership_package.dart';
import 'package:eliud_pkg_membership/tasks/approve_membership_task_model.dart';
import 'package:eliud_pkg_membership/tasks/request_membership_task_model.dart';
import 'package:eliud_pkg_pay/tasks/context_amount_pay_model.dart';
import 'package:eliud_pkg_pay/tasks/creditcard_pay_type_model.dart';
import 'package:eliud_pkg_pay/tasks/fixed_amount_pay_model.dart';
import 'package:eliud_pkg_pay/tasks/manual_pay_type_model.dart';
import 'package:eliud_pkg_pay/tasks/pay_type_model.dart';
import 'package:eliud_pkg_pay/tasks/review_and_ship_task_model.dart';
import 'package:eliud_pkg_shop/shop_package.dart';
import 'package:eliud_pkg_workflow/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_workflow/model/workflow_model.dart';
import 'package:eliud_pkg_workflow/model/workflow_notification_model.dart';
import 'package:eliud_pkg_workflow/model/workflow_task_model.dart';
import 'package:eliud_pkg_workflow/tools/action/workflow_action_model.dart';

class Workflows {
  final WorkflowModel? manuallyPaidMembershipWorkflow;
  final WorkflowModel? membershipPaidByCardWorkflow;
  final WorkflowModel? manualPaymentCartWorkflow;
  final WorkflowModel? creditCardPaymentCartWorkflow;

  Workflows({
    required this.manuallyPaidMembershipWorkflow,
    required this.membershipPaidByCardWorkflow,
    required this.manualPaymentCartWorkflow,
    required this.creditCardPaymentCartWorkflow,
  });
}

class WorkflowBuilder {
  final String appId;
  final bool manuallyPaidMembership;
  final bool membershipPaidByCard;
  final bool manualPaymentCart;
  final bool creditCardPaymentCart;

  WorkflowBuilder(this.appId,
      {required this.manuallyPaidMembership,
      required this.membershipPaidByCard,
      required this.manualPaymentCart,
      required this.creditCardPaymentCart});

  Future<Workflows> create() async {
    WorkflowModel? manuallyPaidMembershipWorkflow;
    WorkflowModel? membershipPaidByCardWorkflow;
    WorkflowModel? manualPaymentCartWorkflow;
    WorkflowModel? creditCardPaymentCartWorkflow;

    if (manuallyPaidMembership) {
      manuallyPaidMembershipWorkflow = await workflowRepository(appId: appId)!
          .add(_workflowForManuallyPaidMembership());
    }
    if (membershipPaidByCard) {
      membershipPaidByCardWorkflow = await workflowRepository(appId: appId)!
          .add(_workflowForMembershipPaidByCard());
    }
    if (manualPaymentCart) {
      manualPaymentCartWorkflow = await workflowRepository(appId: appId)!
          .add(_workflowForManualPaymentCart());
    }
    if (creditCardPaymentCart) {
      creditCardPaymentCartWorkflow = await workflowRepository(appId: appId)!
          .add(_workflowForCreditCardPaymentCart());
    }

    return Workflows(
      manuallyPaidMembershipWorkflow: manuallyPaidMembershipWorkflow,
      membershipPaidByCardWorkflow: membershipPaidByCardWorkflow,
      manualPaymentCartWorkflow: manualPaymentCartWorkflow,
      creditCardPaymentCartWorkflow: creditCardPaymentCartWorkflow,
    );
  }

  static double amount = 20;
  static String ccy = 'gbp';
  static String payTo = "Mr Minkey";
  static String country = "United Kingdom";
  static String bankIdentifierCode = "Bank ID Code";
  static String payeeIBAN = "IBAN 543232187632167";
  static String bankName = "Bank Of America";

  WorkflowModel _workflowForManuallyPaidMembership() {
    return workflowForManuallyPaidMembership(
        amount: amount,
        ccy: ccy,
        payTo: payTo,
        country: country,
        bankIdentifierCode: bankIdentifierCode,
        payeeIBAN: payeeIBAN,
        bankName: bankName);
  }

  WorkflowModel _workflowForMembershipPaidByCard() {
    return workflowForMembershipPaidByCard(
      amount: amount,
      ccy: ccy,
    );
  }

  WorkflowModel _workflowForManualPaymentCart() {
    return workflowForManualPaymentCart(
        payTo: payTo,
        country: country,
        bankIdentifierCode: bankIdentifierCode,
        payeeIBAN: payeeIBAN,
        bankName: bankName);
  }

  WorkflowModel _workflowForCreditCardPaymentCart() {
    return workflowForCreditCardPaymentCart();
  }

  WorkflowActionModel requestMembershipAction(String appId) =>
      WorkflowActionModel(appId,
          conditions: DisplayConditionsModel(
            privilegeLevelRequired: PrivilegeLevelRequired.NoPrivilegeRequired,
            packageCondition: MembershipPackage.MEMBER_HAS_NO_MEMBERSHIP_YET,
          ),
          workflow: _workflowForManuallyPaidMembership());

  WorkflowActionModel payCart(String appId) => WorkflowActionModel(appId,
      conditions: DisplayConditionsModel(
        privilegeLevelRequired: PrivilegeLevelRequired.NoPrivilegeRequired,
        packageCondition: ShopPackage.CONDITION_CARTS_HAS_ITEMS,
      ),
      workflow: _workflowForCreditCardPaymentCart());

  // helper methods
  WorkflowModel workflowForManualPaymentCart(
      {required String payTo,
      required String country,
      required String bankIdentifierCode,
      required String payeeIBAN,
      required String bankName}) {
    return _workflowForPaymentCart(
        "cat_paid_manually",
        "Manual Cart Payment",
        ManualPayTypeModel(
            payTo: payTo,
            country: country,
            bankIdentifierCode: bankIdentifierCode,
            payeeIBAN: payeeIBAN,
            bankName: bankName));
  }

  WorkflowModel workflowForCreditCardPaymentCart() {
    return _workflowForPaymentCart("cart_paid_by_card",
        "Cart Payment with Card", CreditCardPayTypeModel());
  }

  WorkflowModel workflowForManuallyPaidMembership(
      {required double amount,
      required String ccy,
      required String payTo,
      required String country,
      required String bankIdentifierCode,
      required String payeeIBAN,
      required String bankName}) {
    return _workflowForMembership(
        "membership_paid_manually",
        "Paid Membership (manually paid)",
        20,
        "GBP",
        ManualPayTypeModel(
            payTo: payTo,
            country: country,
            bankIdentifierCode: bankIdentifierCode,
            payeeIBAN: payeeIBAN,
            bankName: bankName));
  }

  WorkflowModel workflowForMembershipPaidByCard({double? amount, String? ccy}) {
    return _workflowForMembership(
        "membership_paid_manually",
        "Paid Membership (Credit card payment)",
        20,
        "GBP",
        CreditCardPayTypeModel(requiresConfirmation: true));
  }

  WorkflowModel _workflowForPaymentCart(
      String documentID, String name, PayTypeModel payTypeModel) {
    return WorkflowModel(
        appId: appId,
        documentID: "cart_paid_manually",
        name: "Manual Cart Payment",
        workflowTask: [
          WorkflowTaskModel(
            seqNumber: 1,
            documentID: "workflow_task_payment",
            responsible: WorkflowTaskResponsible.CurrentMember,
            task: ContextAmountPayModel(
              identifier: newRandomKey(),
              executeInstantly: false,
              description: 'Please pay for your buy',
              paymentType: payTypeModel,
            ),
          ),
          WorkflowTaskModel(
            seqNumber: 2,
            documentID: "review_payment_and_ship",
            responsible: WorkflowTaskResponsible.Owner,
            confirmMessage: WorkflowNotificationModel(
                message:
                    "Your payment has been reviewed and approved and your order is being prepared for shipment. Feedback from the shop: ",
                addressee: WorkflowNotificationAddressee.CurrentMember),
            rejectMessage: WorkflowNotificationModel(
                message:
                    "Your payment has been reviewed and rejected. Feedback from the shop: ",
                addressee: WorkflowNotificationAddressee.CurrentMember),
            task: ReviewAndShipTaskModel(
              identifier: newRandomKey(),
              executeInstantly: false,
              description: 'Review the payment and ship the products',
            ),
          ),
        ]);
  }

  WorkflowModel _workflowForMembership(String documentID, String name,
      double amount, String ccy, PayTypeModel payTypeModel) {
    return WorkflowModel(
        appId: appId,
        documentID: documentID,
        name: name,
        workflowTask: [
          WorkflowTaskModel(
            seqNumber: 1,
            documentID: "request_membership",
            responsible: WorkflowTaskResponsible.CurrentMember,
            task: RequestMembershipTaskModel(
              identifier: newRandomKey(),
              executeInstantly: false,
              description: 'Please join. It costs 20 GBP, 1 time cost',
            ),
          ),
          WorkflowTaskModel(
            seqNumber: 2,
            documentID: "pay_membership",
            responsible: WorkflowTaskResponsible.CurrentMember,
            confirmMessage: WorkflowNotificationModel(
                message:
                    "Your payment and membership request is now with the owner for review. You will be notified soon",
                addressee: WorkflowNotificationAddressee.CurrentMember),
            rejectMessage: null,
            task: FixedAmountPayModel(
                identifier: newRandomKey(),
                executeInstantly: true,
                description: 'To join, pay 20 GBP',
                paymentType: payTypeModel,
                ccy: ccy,
                amount: amount),
          ),
          WorkflowTaskModel(
            seqNumber: 3,
            documentID: "confirm_membership",
            responsible: WorkflowTaskResponsible.Owner,
            confirmMessage: WorkflowNotificationModel(
                message:
                    "You payment has been verified and you're now a member. Welcome! Feedback: ",
                addressee: WorkflowNotificationAddressee.First),
            rejectMessage: WorkflowNotificationModel(
                message:
                    "You payment has been verified and unfortunately something went wrong. Feedback: ",
                addressee: WorkflowNotificationAddressee.First),
            task: ApproveMembershipTaskModel(
              identifier: newRandomKey(),
              executeInstantly: false,
              description: 'Verify payment and confirm membership',
            ),
          ),
        ]);
  }
}
