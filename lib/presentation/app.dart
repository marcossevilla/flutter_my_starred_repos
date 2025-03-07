import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_my_starred_repos/features/auth/core/dependency_injection.dart';
import 'package:flutter_my_starred_repos/presentation/routers/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dependency_injection.dart';
import '../core/flavors.dart';
import '../features/auth/application/authenticator_cubit/authenticator_cubit.dart';
import 'routers/app_router.gr.dart';

class MyApp extends ConsumerWidget {
  const MyApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authenticatorCubit = ref.watch(authenticatorCubitPod);
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticatorCubit>.value(
          value: authenticatorCubit..checkAuthStatus(),
        ),
      ],
      child: Builder(
        builder: (context) => Consumer(
          builder: (context, ref, _) =>
              BlocListener<AuthenticatorCubit, AuthenticatorState>(
            listener: (context, authenticatorState) {
              final appRouter = ref.watch(appRouterPod);
              authenticatorState.maybeWhen(
                authenticated: () => appRouter.pushAndPopUntil(
                  const CounterScreenRoute(),
                  predicate: (route) => false,
                ),
                unauthenticated: () => appRouter.pushAndPopUntil(
                  const LoginScreenRoute(),
                  predicate: (route) => false,
                ),
                orElse: () {},
              );
            },
            child: MaterialApp.router(
              title: 'App (${ref.watch(flavorPod).tag})',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerDelegate: ref.watch(appRouterPod).delegate(),
              routeInformationParser:
                  ref.watch(appRouterPod).defaultRouteParser(),
            ),
          ),
        ),
      ),
    );
  }
}
