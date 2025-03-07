import 'package:dio/dio.dart';
import 'package:flutter_my_starred_repos/features/auth/core/dependency_injection.dart';
import 'package:flutter_my_starred_repos/features/auth/infrastructure/external/dio_interceptors.dart';
import 'package:flutter_my_starred_repos/features/stared_repos/application/starred_repos_cubit/cubit.dart';
import 'package:flutter_my_starred_repos/features/stared_repos/core/dependency_injection.dart';
import 'package:flutter_my_starred_repos/features/stared_repos/infrastructure/data_sources/etags_lds/interface.dart';
import 'package:flutter_my_starred_repos/features/stared_repos/infrastructure/data_sources/stared_repos_rds/interface.dart';
import 'package:flutter_my_starred_repos/features/stared_repos/infrastructure/data_sources/starred_repos_lds/interface.dart';
import 'package:flutter_my_starred_repos/features/stared_repos/infrastructure/external/etags_dio_interceptor.dart';
import 'package:flutter_my_starred_repos/features/stared_repos/infrastructure/facades/starred_repos_repo/interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sembast/sembast.dart';
import 'package:test/test.dart';

class MockSembastDb extends Mock implements Database {}

class MockAuthInterceptor extends Fake implements AuthInterceptor {}

void main() {
  group(
    '''

GIVEN a depencencies container''',
    () {
      test(
        '''

AND no interaction
WHEN the Sembast database is accessed
THEN an exception is thrown
├─ THAT indicates that the database has not been initialized
''',
        () {
          // ARRANGE
          final container = ProviderContainer();

          // ACT
          Database action() => container.read(sembastDbPod);

          // ASSERT
          expect(
            action,
            throwsA(
              predicate(
                (e) => e is ProviderException && e.exception is StateError,
              ),
            ),
          );
        },
      );

      group(
        '''

AND a previously injected auth interceptor
AND an injection overrides getter function
├─ THAT overrides the Sembast database injection
WHEN the injection process is triggered''',
        () {
          // ARRANGE
          late ProviderContainer container;

          setUp(
            () async {
              // ARRANGE
              final preconditionalOverrides = [
                authInterceptorPod.overrideWithValue(MockAuthInterceptor()),
              ];
              // ACT
              final overrides = await getInjectionOverrides();
              container = ProviderContainer(
                overrides: [
                  ...preconditionalOverrides,
                  ...overrides,
                ],
              );
            },
          );

          test(
            '''

THEN the necessary starred-repos-related dependencies should be injected
├─ BY  injecting a single Sembast database
├─ AND injecting a single pages ETags local data source
├─ AND injecting a single ETags interceptor
├─ AND injecting a single Dio HTTP client
├─ AND injecting a single starred repos remote data source
├─ AND injecting a single starred repos local data source
├─ AND injecting a single starred repos repository
├─ AND injecting a single starred repos cubit
''',
            () async {
              // ASSERT
              expect(
                container.read(sembastDbPod),
                isA<Database>(),
              );
              expect(
                container.read(pagesEtagsLDSPod),
                isA<PagesEtagsLDS>(),
              );
              expect(
                container.read(etagsInterceptorPod),
                isA<EtagsInterceptor>(),
              );
              expect(
                container.read(starredReposDioPod),
                isA<Dio>(),
              );
              expect(
                container.read(starredReposRDSPod),
                isA<StaredReposRDS>(),
              );
              expect(
                container.read(starredReposLDSPod),
                isA<StarredReposLDS>(),
              );
              expect(
                container.read(starredReposRepoPod),
                isA<StarredReposRepo>(),
              );
              expect(
                container.read(starredReposCubitPod),
                isA<StarredReposCubit>(),
              );
            },
          );
        },
      );
    },
  );
}
