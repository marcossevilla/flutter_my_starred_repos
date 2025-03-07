import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/auth/screen.dart';
import '../../features/auth/presentation/screens/login/screen.dart';
import '../../features/counter/presentation/screens/counter/screen.dart';
import '../../features/stared_repos/presentation/screens/starred_repos/screen.dart';
import '../../features/users_placeholder/presentation/screens/users/screen.dart';
import 'app_router.gr.dart';

@CustomAutoRouter(
  routes: [
    CustomRoute(
      page: CounterScreen,
      initial: true,
    ),
    CustomRoute(
      page: LoginScreen,
    ),
    CustomRoute<Uri>(
      page: AuthScreen,
    ),
    CustomRoute(
      page: UsersScreen,
    ),
    CustomRoute(
      page: StarredReposScreen,
    ),
  ],
)
class $AppRouter {}

final appRouterPod = ChangeNotifierProvider<AppRouter>(
  (_) => AppRouter(),
);
