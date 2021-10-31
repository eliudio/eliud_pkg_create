import 'package:eliud_core/model/abstract_repository_singleton.dart'
    as corerepo;
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/model_export.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_core/tools/storage/platform_medium_helper.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/page/page_builder.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/page/page_with_text.dart';
import 'package:eliud_pkg_fundamentals/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_fundamentals/model/booklet_component.dart';
import 'package:eliud_pkg_fundamentals/model/booklet_model.dart';
import 'package:eliud_pkg_fundamentals/model/section_model.dart';

class BlockedPageBuilder extends PageBuilder {
  final String? blockedAssetLocation;
  final String componentId;

  BlockedPageBuilder(
      this.componentId,
      this.blockedAssetLocation,
      String pageId,
      String appId,
      String memberId,
      HomeMenuModel theHomeMenu,
      AppBarModel theAppBar,
      DrawerModel leftDrawer,
      DrawerModel rightDrawer)
      : super(pageId, appId, memberId, theHomeMenu, theAppBar, leftDrawer,
            rightDrawer);

  Future<PageModel> _setupPage() async {
    return await corerepo.AbstractRepositorySingleton.singleton
        .pageRepository(appId)!
        .add(_page());
  }

  PageModel _page() {
    List<BodyComponentModel> components = [];
    components.add(BodyComponentModel(
        documentID: "1",
        componentName: AbstractBookletComponent.componentName,
        componentId: blockedIdentifier));

    return PageModel(
        documentID: pageId,
        appId: appId,
        title: "Blocked !",
        drawer: leftDrawer,
        endDrawer: rightDrawer,
        appBar: theAppBar,
        homeMenu: theHomeMenu,
        layout: PageLayout.ListView,
        conditions: ConditionsModel(
          privilegeLevelRequired: PrivilegeLevelRequired.NoPrivilegeRequired,
        ),
        bodyComponents: components);
  }

  static String blockedIdentifier = "blocked";

  Future<PlatformMediumModel> uploadBlockedImage() async {
    return await PlatformMediumHelper(appId, memberId,
            PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple)
        .createThumbnailUploadPhotoAsset(
      newRandomKey(),
      blockedAssetLocation!,
    );
  }

  BookletModel _blocked(PlatformMediumModel blockedImage) {
    List<SectionModel> entries = [];
    {
      entries.add(SectionModel(
          documentID: "1",
          title: "Blocked!",
          description: "Unfortunately you are blocked.",
          image: blockedImage,
          imagePositionRelative: RelativeImagePosition.Aside,
          imageAlignment: SectionImageAlignment.Right,
          imageWidth: .33,
          links: []));
    }

    return BookletModel(
      documentID: blockedIdentifier,
      name: "Blocked!",
      sections: entries,
      appId: appId,
      conditions: ConditionsSimpleModel(
          privilegeLevelRequired:
              PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple),
    );
  }

  Future<void> _setupBlocked(PlatformMediumModel blockedImage) async {
    await AbstractRepositorySingleton.singleton
        .bookletRepository(appId)!
        .add(_blocked(blockedImage));
  }

  Future<PageModel> create() async {
    if (blockedAssetLocation != null) {
      var blockedImage = await uploadBlockedImage();
      await _setupBlocked(blockedImage);
      return await _setupPage();
    } else {
      return PageWithTextBuilder(
          'Blocked',
          'You are blocked',
          pageId,
          appId,
          memberId,
          theHomeMenu,
          theAppBar,
          leftDrawer,
          rightDrawer)
          .create();
    }
  }
}
