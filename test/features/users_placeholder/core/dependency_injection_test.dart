import 'package:dio/dio.dart';
import 'package:flutter_my_starred_repos/core/flavors.dart';
import 'package:flutter_my_starred_repos/features/users_placeholder/application/users_cubit/cubit.dart';
import 'package:flutter_my_starred_repos/features/users_placeholder/core/dependency_injection.dart';
import 'package:flutter_my_starred_repos/features/users_placeholder/infrastructure/data_sources/users_rds/interface.dart';
import 'package:flutter_my_starred_repos/features/users_placeholder/infrastructure/facades/interface.dart';
import 'package:get_it/get_it.dart';
import 'package:test/test.dart';
import 'package:graphql/client.dart';

void main() {
  group(
    '''
  
GIVEN an injector function''',
    () {
      // ARRANGE
      final getIt = GetIt.instance;

      for (final flavor in Flavor.values) {
        group(
          '''
  
AND the ${flavor.tag} flavor
WHEN the injection process is triggered''',
          () {
            setUp(
              () async {
                // ARRANGE
                getIt.reset();

                // ACT
                await injectDependencies(
                  flavor: flavor,
                );
              },
            );

            test(
              '''

THEN a single users remote data source should be injected
AND a single users repo should be injected
AND a single users cubit should be injected
''',
              () async {
                // ASSERT
                expect(getIt.isRegistered<UsersRDS>(), isTrue);
                expect(getIt.isRegistered<UsersRepo>(), isTrue);
                expect(getIt.isRegistered<UsersCubit>(), isTrue);
              },
            );

            test(
              '''

THEN a single users cubit should be available
''',
              () async {
                // ASSERT
                expect(getIt.get<UsersCubit>(), isNotNull);
              },
            );

            if (flavor == Flavor.dev || flavor == Flavor.prod) {
              test(
                '''

THEN a single HTTP client should be injected
''',
                () async {
                  // ASSERT
                  expect(getIt.isRegistered<Dio>(), isTrue);
                },
              );
            } else if (flavor == Flavor.stg) {
              test(
                '''

THEN a single GraphQL client should be injected
''',
                () async {
                  // ASSERT
                  expect(getIt.isRegistered<GraphQLClient>(), isTrue);
                },
              );
            }
          },
        );
      }
    },
  );
}
