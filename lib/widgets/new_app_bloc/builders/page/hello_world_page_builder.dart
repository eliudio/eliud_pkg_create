import 'package:eliud_core/core/wizards/builders/page_builder.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_pkg_text/wizards/builders/page/page_with_text.dart';

class HelloWorldPageBuilder extends PageBuilder {
  HelloWorldPageBuilder(
    super.uniqueId,
    super.pageId,
    super.app,
    super.memberId,
    super.theHomeMenu,
    super.theAppBar,
    super.leftDrawer,
    super.rightDrawer,
  );

  Future<PageModel> create() async {
    return PageWithTextBuilder(
      uniqueId,
      'Hello',
      'Hello world',
      'Hello world',
      pageId,
      app,
      memberId,
      theHomeMenu,
      theAppBar,
      leftDrawer,
      rightDrawer,
    ).create();
  }
}
