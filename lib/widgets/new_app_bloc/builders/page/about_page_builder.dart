import 'package:eliud_core/model/abstract_repository_singleton.dart'
    as corerepo;
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/model/platform_medium_model.dart';
import 'package:eliud_core/model/storage_conditions_model.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_core/tools/storage/platform_medium_helper.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/page/page_with_text.dart';
import 'package:eliud_pkg_fundamentals/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_fundamentals/model/booklet_component.dart';
import 'package:eliud_pkg_fundamentals/model/booklet_model.dart';
import 'package:eliud_pkg_fundamentals/model/link_model.dart';
import 'package:eliud_pkg_fundamentals/model/section_model.dart';
import 'page_builder.dart';

class AboutPageBuilder extends PageBuilder {
  final String componentId;
  final String? aboutAssetLocation;
  final double imageWidth = 0.3;
  final RelativeImagePosition imagePosition = RelativeImagePosition.Aside;
  final SectionImageAlignment alignment = SectionImageAlignment.Left;

  AboutPageBuilder(
      this.componentId,
    this.aboutAssetLocation,
    String pageId,
    AppModel app,
    String memberId,
    HomeMenuModel theHomeMenu,
    AppBarModel theAppBar,
    DrawerModel leftDrawer,
    DrawerModel rightDrawer,
  ) : super(pageId, app, memberId, theHomeMenu, theAppBar, leftDrawer,
            rightDrawer);

  Future<PageModel> _setupPage() async {
    return await corerepo.AbstractRepositorySingleton.singleton
        .pageRepository(app.documentID!)!
        .add(_page());
  }

  PageModel _page() {
    List<BodyComponentModel> components = [];
    components.add(BodyComponentModel(
      documentID: "1",
      componentName: AbstractBookletComponent.componentName,
      componentId: componentId,
    ));

    return PageModel(
        documentID: pageId,
        appId: app.documentID!,
        title: "About",
        drawer: leftDrawer,
        endDrawer: rightDrawer,
        appBar: theAppBar,
        homeMenu: theHomeMenu,
        layout: PageLayout.ListView,
        conditions: StorageConditionsModel(
          privilegeLevelRequired: PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple,
        ),
        bodyComponents: components);
  }

  Future<String?> _store(PlatformMediumModel platformMediumModel) async {
    return (await AbstractRepositorySingleton.singleton
            .bookletRepository(app.documentID!)!
            .add(_header(platformMediumModel)))
        .documentID;
  }

  Future<PlatformMediumModel> installAboutImage() async {
    return await PlatformMediumHelper(app, memberId,
            PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple)
        .createThumbnailUploadPhotoAsset(
      newRandomKey(),
      aboutAssetLocation!
    );
  }

  static String title = 'About me';
  static String description = "Welcome to my new app. .\n\nMy name is X. .\n\nI am the founder of Y. I enjoy making nice things and people love my litte pieces of art. So, one day I decided to share my products with the wider world. That's how Y was created. I hope you enjoy my shop.\n\nX";

  BookletModel _header(PlatformMediumModel memberMediumModel) {
    List<SectionModel> entries = [];
    {
      List<LinkModel> links = [];
      entries.add(SectionModel(
          documentID: "1",
          title: "About me",
          description: description,
          image: memberMediumModel,
          imagePositionRelative: imagePosition,
          imageAlignment: alignment,
          imageWidth: imageWidth,
          links: links));
    }

    return BookletModel(
      documentID: componentId,
      name: "About",
      sections: entries,
      appId: app.documentID!,
      conditions: StorageConditionsModel(
          privilegeLevelRequired:
              PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple),
    );
  }

  Future<PageModel> create() async {
    if (aboutAssetLocation != null) {
      var image = await installAboutImage();
      await _store(image);
      return await _setupPage();
    } else {
      return PageWithTextBuilder(
          title,
          description,
          pageId,
          app,
          memberId,
          theHomeMenu,
          theAppBar,
          leftDrawer,
          rightDrawer)
          .create();
    }
  }
}
