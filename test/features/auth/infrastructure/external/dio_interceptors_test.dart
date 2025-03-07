import 'package:dio/dio.dart';
import 'package:flutter_my_starred_repos/features/auth/infrastructure/data_sources/creds_storage/interface.dart';
import 'package:flutter_my_starred_repos/features/auth/infrastructure/external/dio_interceptors.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oauth2/oauth2.dart';
import 'package:test/test.dart';

import '../../../../helpers/mock_interceptor.dart';

class MockCredsStorage extends Mock implements CredsStorage {}

void main() {
  group(
    '''

GIVEN an HTTP client
├─ THAT uses an auth interceptor
│  ├─ THAT uses a credentials storage
AND a request
├─ THAT uses auth extra data for interception''',
    () {
      // ARRANGE
      late MockCredsStorage mockCredsStorage;
      late AuthInterceptor authInterceptor;
      late MockerInterceptor mockerInterceptor;
      late Dio dio;

      final extraData = Map.fromEntries([
        AuthInterceptor.extraEntry,
      ]);
      RequestOptions request() =>
          // Using a function to avoid mutability-related issues.
          RequestOptions(
            path: 'some.url',
            extra: extraData,
          );

      setUp(
        () {
          mockCredsStorage = MockCredsStorage();
          authInterceptor = AuthInterceptor(
            credsStorage: mockCredsStorage,
          );
          mockerInterceptor = MockerInterceptor();
          dio = Dio()
            ..interceptors.addAll([
              authInterceptor,
              mockerInterceptor,
            ]);
        },
      );

      tearDown(
        () {
          verifyNoMoreInteractions(mockCredsStorage);
        },
      );

      test(
        '''

AND a stored access token
WHEN the request is sent
THEN the auth interceptor should alter the request
├─ BY retriving an access token with the creds storage
├─ AND attaching the token to the `Authorization` header as a bearer one
''',
        () async {
          // ARRANGE
          const accessToken = 'access_token';
          when(
            () => mockCredsStorage.get(),
          ).thenAnswer(
            (_) async => Credentials(accessToken),
          );

          // ACT
          final result = await dio.fetch(request());

          // ASSERT
          verify(
            () => mockCredsStorage.get(),
          ).called(1);
          expect(
            result.requestOptions.headers['Authorization'],
            'Bearer $accessToken',
          );
        },
      );

      test(
        '''

AND no stored access token
WHEN the request is sent
THEN the auth interceptor should not alter the request
├─ BY trying to retrive an access token with the creds storage
├─ AND not defining the `Authorization` header
''',
        () async {
          // ARRANGE
          when(
            () => mockCredsStorage.get(),
          ).thenAnswer(
            (_) async => null,
          );

          // ACT
          final result = await dio.fetch(request());

          // ASSERT
          verify(
            () => mockCredsStorage.get(),
          ).called(1);
          expect(result.requestOptions.headers['Authorization'], isNull);
        },
      );
    },
  );
}
