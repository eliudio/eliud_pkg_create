import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_policy_item_model.dart';
import 'package:eliud_core/model/app_policy_model.dart';
import 'package:eliud_core/model/conditions_simple_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/model/platform_medium_model.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_core/tools/storage/platform_medium_helper.dart';
import 'package:eliud_core/tools/storage/upload_info.dart';

class AppPolicyHelper {
  final String appId;
  final String memberId;
  PlatformMediumModel policy;

  AppPolicyHelper(this.appId, this.memberId, this.policy, );

  Future<AppPolicyModel> _getAppPolicy() async {
    return AppPolicyModel(
        documentID: 'policies',
        appId: appId,
        comments: 'All policies of the app',
        policies: [
          AppPolicyItemModel(
            documentID: newRandomKey(),
            name: 'Policy',
            policy: policy,
          ),
        ]);
  }

  Future<AppPolicyModel> create() async {
    var policyModel = await _getAppPolicy();
    await appPolicyRepository(appId: appId)!.add(policyModel);
    return policyModel;
  }
}




