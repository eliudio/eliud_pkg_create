import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/platform_medium_model.dart';
import 'package:eliud_core/model/storage_conditions_model.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_core/tools/storage/platform_medium_helper.dart';
import 'package:eliud_core/tools/storage/upload_info.dart';

class PolicyMediumBuilder {
  final FeedbackProgress feedbackProgress;
  final AppModel app;
  final String memberId;

  PolicyMediumBuilder(this.feedbackProgress, this.app, this.memberId);

// Policy
  String policiesAssetLocation() =>
      'packages/eliud_pkg_create/assets/new_app/legal/policies.pdf';

  Future<PlatformMediumModel> create() async {
    var policyID = 'policy_id';
    var policy = await _uploadPublicPdf(
        app, memberId, policiesAssetLocation(), policyID, feedbackProgress);
    return policy;
  }

  Future<PlatformMediumModel> _uploadPublicPdf(
      AppModel app,
      String memberId,
      String assetPath,
      String documentID,
      FeedbackProgress? feedbackProgress) async {
    String memberMediumDocumentID = newRandomKey();
    return await PlatformMediumHelper(app, memberId,
        PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple)
        .createThumbnailUploadPdfAsset(
        memberMediumDocumentID, assetPath, documentID,
        feedbackProgress: feedbackProgress);
  }
}
