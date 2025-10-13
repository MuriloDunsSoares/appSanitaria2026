import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/core/usecases/usecase.dart';
import 'package:app_sanitaria/domain/usecases/auth/check_authentication.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/test_helper.mocks.dart';

void main() {
  late CheckAuthentication usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = CheckAuthentication(mockAuthRepository);
  });

  group('CheckAuthentication', () {
    test('deve retornar true quando usuário está autenticado', () async {
      // arrange
      when(mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => const Right<Failure, bool>(true));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Right<Failure, bool>(true));
      verify(mockAuthRepository.isAuthenticated());
    });

    test('deve retornar false quando usuário não está autenticado', () async {
      // arrange
      when(mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => const Right<Failure, bool>(false));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Right<Failure, bool>(false));
    });
  });
}
