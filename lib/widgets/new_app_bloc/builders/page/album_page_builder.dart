import 'package:eliud_core/model/abstract_repository_singleton.dart'
    as corerepo;
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';
import 'package:eliud_core/model/model_export.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_pkg_create/widgets/new_app_bloc/builders/page/page_builder.dart';
import 'package:eliud_pkg_feed/model/abstract_repository_singleton.dart';
import 'package:eliud_pkg_feed/model/album_component.dart';
import 'package:eliud_pkg_feed/model/album_model.dart';
import 'package:eliud_pkg_feed/model/post_model.dart';
import 'package:eliud_core/tools/storage/member_medium_helper.dart';
import 'package:eliud_pkg_feed/model/abstract_repository_singleton.dart' as postRepo;
import 'package:eliud_pkg_feed/model/post_medium_model.dart';

class AlbumPageBuilder extends PageBuilder {
  final String examplePhoto1AssetPath;
  final String examplePhoto2AssetPath;
//final String exampleVideoAssetPath;
  final String albumComponentIdentifier;

  AlbumPageBuilder(
      this.albumComponentIdentifier,
      this.examplePhoto1AssetPath,
      this.examplePhoto2AssetPath,
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
        componentName: AbstractAlbumComponent.componentName,
        componentId: albumComponentIdentifier));

    return PageModel(
        documentID: pageId,
        appId: appId,
        title: "Album",
        drawer: leftDrawer,
        endDrawer: rightDrawer,
        appBar: theAppBar,
        homeMenu: theHomeMenu,
        layout: PageLayout.ListView,
        conditions: ConditionsModel(
          privilegeLevelRequired:
              PrivilegeLevelRequired.Level1PrivilegeRequired,
        ),
        bodyComponents: components);
  }

  AlbumModel albumModel(PostModel postModel) {
    return AlbumModel(
      documentID: albumComponentIdentifier,
      appId: appId,
      post: postModel,
      description: "Example Photos",
      conditions: ConditionsSimpleModel(
          privilegeLevelRequired:
              PrivilegeLevelRequiredSimple.NoPrivilegeRequiredSimple),
    );
  }

  Future<AlbumModel> _setupAlbum(PostModel postModel) async {
    return await albumRepository(appId: appId)!
        .add(albumModel(postModel));
  }

  Future<PageModel> create() async {
    PostModel photoAlbum = await ExamplePost(
            appId: appId,
            examplePhoto1AssetPath: examplePhoto1AssetPath,
            examplePhoto2AssetPath: examplePhoto2AssetPath,
//      exampleVideoAssetPath: exampleVideoAssetPath,
    )
        .photoAlbum(memberId);
//    PostModel videoAlbum = await ExamplePost(newAppTools, installApp.appId).videoAlbum(member);
    await _setupAlbum(photoAlbum);
    return await _setupPage();
  }
}


class ExamplePost {
  final String appId;
  final String examplePhoto1AssetPath;
  final String examplePhoto2AssetPath;
//final String exampleVideoAssetPath;

  ExamplePost({
    required this.appId,
    required this.examplePhoto1AssetPath,
    required this.examplePhoto2AssetPath,
    /*required this.exampleVideoAssetPath, */
  });

  Future<PostModel> photoAlbum(String memberId) async {
    return await postRepo.AbstractRepositorySingleton.singleton
        .postRepository(appId)!
        .add(
      PostModel(
        documentID: newRandomKey(),
        authorId: memberId,
        appId: appId,
        archived: PostArchiveStatus.Active,
        description: "These are my photos",
        readAccess: ['PUBLIC', memberId],
        memberMedia: [
          PostMediumModel(
              documentID: newRandomKey(),
              memberMedium: await MemberMediumHelper(
                  appId, memberId, ['PUBLIC', memberId])
                  .createThumbnailUploadPhotoAsset(
                newRandomKey(),
                examplePhoto1AssetPath,
              )),
          PostMediumModel(
              documentID: newRandomKey(),
              memberMedium: await MemberMediumHelper(
                  appId, memberId, ['PUBLIC', memberId])
                  .createThumbnailUploadPhotoAsset(
                newRandomKey(),
                examplePhoto2AssetPath,
              ))
        ],
      ),
    );
  }

/*
  Future<PostModel> videoAlbum(String memberId) async {
    var memberPublicInfo = await memberPublicInfoRepository()!.get(memberId);
    return await postRepo.AbstractRepositorySingleton.singleton
        .postRepository(appId)!
        .add(
          PostModel(
            documentID: newRandomKey(),
            authorId: memberPublicInfo!.documentID!,
            appId: appId,
            archived: PostArchiveStatus.Active,
            description: "These are my videos",
            readAccess: ['PUBLIC', memberId],
            memberMedia: [
              PostMediumModel(
                documentID: newRandomKey(),
                memberMedium: await MemberMediumHelper(
                        appId, memberId!, ['PUBLIC', memberId])
                    .createThumbnailUploadVideoAsset(
                  newRandomKey(),
                  exampleVideoAssetPath,
                ),
              )
            ],
          ),
        );
  }
*/
}
