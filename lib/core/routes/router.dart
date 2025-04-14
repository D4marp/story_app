import 'package:go_router/go_router.dart';
import 'package:story_app/ui/auth/login_page.dart';
import 'package:story_app/ui/auth/register_page.dart';
import 'package:story_app/ui/detail/detail_page.dart';
import 'package:story_app/ui/home/home_page.dart';

import '../../ui/account/account_page.dart';
import '../../ui/add/add_new_stories_page.dart';
import '../../ui/location/location_page.dart';

part 'route_name.dart';

final GoRouter router = GoRouter(
  initialLocation: Routes.login,
  routes: [
    GoRoute(
      path: Routes.login,
      name: Routes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: Routes.register,
      name: Routes.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: Routes.home,
      name: Routes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: Routes.addNewStory,
      name: Routes.addNewStory,
      builder: (context, state) => AddNewStoryPage(
        onRefresh: state.extra as void Function(),
      ),
    ),
    GoRoute(
      path: Routes.selectLocation,
      name: Routes.selectLocation,
      builder: (context, state) => SelectLocationPage(
        onLocationSelected: (latLng) {},
      ),
    ),
    GoRoute(
      path: Routes.account,
      name: Routes.account,
      builder: (context, state) => const AccountPage(),
    ),
    GoRoute(
      path: '${Routes.detailStory}/:id',
      name: Routes.detailStory,
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return DetailPage(id: id!);
      },
    ),
  ],
);
