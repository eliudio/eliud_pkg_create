import 'package:eliud_core/model/abstract_repository_singleton.dart';
import 'package:eliud_core/model/app_policy_item_model.dart';
import 'package:eliud_core/model/app_policy_model.dart';
import 'package:eliud_core/model/conditions_simple_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/model/platform_medium_model.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_core/tools/storage/platform_medium_helper.dart';
import 'package:eliud_core/tools/storage/upload_info.dart';

class PolicyMediumBuilder {
  final FeedbackProgress feedbackProgress;
  final String appId;
  final String memberId;

  PolicyMediumBuilder(this.feedbackProgress, this.appId, this.memberId);

// Policy
  String policiesAssetLocation() =>
      'packages/eliud_pkg_create/assets/new_app/legal/policies.pdf';

  Future<PlatformMediumModel> create() async {
    var policyID = 'policy_id';
    var policy = await _uploadPublicPdf(
        appId, memberId, policiesAssetLocation(), policyID, feedbackProgress);
    return policy;
  }

  Future<PlatformMediumModel> _uploadPublicPdf(
      String appId,
      String memberId,
      String assetPath,
      String documentID,
      FeedbackProgress? feedbackProgress) async {
    String memberMediumDocumentID = newRandomKey();
    return await PlatformMediumHelper(appId, memberId,
        PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple)
        .createThumbnailUploadPdfAsset(
        memberMediumDocumentID, assetPath, documentID,
        feedbackProgress: feedbackProgress);
  }
}
