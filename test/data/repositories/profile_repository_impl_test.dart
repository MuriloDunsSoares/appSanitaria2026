import 'package:app_sanitaria/core/error/exceptions.dart';
import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/data/datasources/profile_storage_datasource.dart';
import 'package:app_sanitaria/data/repositories/profile_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([ProfileStorageDataSource])
import 'profile_repository_impl_test.mocks.dart';

void main() {
  late ProfileRepositoryImpl repository;
  late MockProfileStorageDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockProfileStorageDataSource();
    repository = ProfileRepositoryImpl(dataSource: mockDataSource);
  });

  const tUserId = 'user-123';
  const tImagePath = '/storage/emulated/0/Pictures/profile_user-123.jpg';
  const tNewImagePath =
      '/storage/emulated/0/Pictures/profile_user-123_updated.jpg';

  group('ProfileRepositoryImpl - getProfileImage', () {
    test('deve retornar caminho da imagem quando usuário tem foto de perfil',
        () async {
      // arrange
      when(mockDataSource.getProfileImage(tUserId))
          .thenAnswer((_) async => tImagePath);

      // act
      final result = await repository.getProfileImage(tUserId);

      // assert
      expect(result, const Right<Failure, dynamic>(tImagePath));
      verify(mockDataSource.getProfileImage(tUserId));
      verifyNoMoreInteractions(mockDataSource);
    });

    test('deve retornar null quando usuário não tem foto de perfil', () async {
      // arrange
      when(mockDataSource.getProfileImage(tUserId))
          .thenAnswer((_) async => null);

      // act
      final result = await repository.getProfileImage(tUserId);

      // assert
      expect(result, const Right<Failure, dynamic>(null));
      verify(mockDataSource.getProfileImage(tUserId));
    });

    test('deve retornar StorageFailure quando ocorre LocalStorageException',
        () async {
      // arrange
      when(mockDataSource.getProfileImage(tUserId))
          .thenThrow(const LocalStorageException('Erro ao buscar imagem'));

      // act
      final result = await repository.getProfileImage(tUserId);

      // assert
      expect(result, const Left<Failure, dynamic>(StorageFailure()));
      verify(mockDataSource.getProfileImage(tUserId));
    });

    test('deve retornar StorageFailure quando ocorre exceção genérica',
        () async {
      // arrange
      when(mockDataSource.getProfileImage(tUserId))
          .thenThrow(Exception('Erro inesperado'));

      // act
      final result = await repository.getProfileImage(tUserId);

      // assert
      expect(result, const Left<Failure, dynamic>(StorageFailure()));
    });
  });

  group('ProfileRepositoryImpl - saveProfileImage', () {
    test('deve salvar imagem de perfil com sucesso', () async {
      // arrange
      when(mockDataSource.saveProfileImage(tUserId, tImagePath))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.saveProfileImage(tUserId, tImagePath);

      // assert
      expect(result, const Right<Failure, dynamic>(unit));
      verify(mockDataSource.saveProfileImage(tUserId, tImagePath));
      verifyNoMoreInteractions(mockDataSource);
    });

    test('deve atualizar imagem existente com sucesso', () async {
      // arrange
      when(mockDataSource.saveProfileImage(tUserId, tNewImagePath))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.saveProfileImage(tUserId, tNewImagePath);

      // assert
      expect(result, const Right<Failure, dynamic>(unit));
      verify(mockDataSource.saveProfileImage(tUserId, tNewImagePath));
    });

    test('deve retornar StorageFailure quando ocorre LocalStorageException',
        () async {
      // arrange
      when(mockDataSource.saveProfileImage(tUserId, tImagePath))
          .thenThrow(const LocalStorageException('Erro ao salvar imagem'));

      // act
      final result = await repository.saveProfileImage(tUserId, tImagePath);

      // assert
      expect(result, const Left<Failure, dynamic>(StorageFailure()));
    });

    test('deve retornar StorageFailure quando ocorre exceção genérica',
        () async {
      // arrange
      when(mockDataSource.saveProfileImage(tUserId, tImagePath))
          .thenThrow(Exception('Erro inesperado'));

      // act
      final result = await repository.saveProfileImage(tUserId, tImagePath);

      // assert
      expect(result, const Left<Failure, dynamic>(StorageFailure()));
    });

    test('deve validar caminho de imagem vazio', () async {
      // arrange
      const emptyPath = '';
      when(mockDataSource.saveProfileImage(tUserId, emptyPath))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.saveProfileImage(tUserId, emptyPath);

      // assert
      expect(result, const Right<Failure, dynamic>(unit));
      verify(mockDataSource.saveProfileImage(tUserId, emptyPath));
    });
  });

  group('ProfileRepositoryImpl - deleteProfileImage', () {
    test('deve deletar imagem de perfil com sucesso', () async {
      // arrange
      when(mockDataSource.deleteProfileImage(tUserId))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.deleteProfileImage(tUserId);

      // assert
      expect(result, const Right<Failure, dynamic>(unit));
      verify(mockDataSource.deleteProfileImage(tUserId));
      verifyNoMoreInteractions(mockDataSource);
    });

    test('deve retornar sucesso mesmo quando não há imagem para deletar',
        () async {
      // arrange
      when(mockDataSource.deleteProfileImage(tUserId))
          .thenAnswer((_) async => false);

      // act
      final result = await repository.deleteProfileImage(tUserId);

      // assert
      expect(result, const Right<Failure, dynamic>(unit));
    });

    test('deve retornar StorageFailure quando ocorre LocalStorageException',
        () async {
      // arrange
      when(mockDataSource.deleteProfileImage(tUserId))
          .thenThrow(const LocalStorageException('Erro ao deletar imagem'));

      // act
      final result = await repository.deleteProfileImage(tUserId);

      // assert
      expect(result, const Left<Failure, dynamic>(StorageFailure()));
    });

    test('deve retornar StorageFailure quando ocorre exceção genérica',
        () async {
      // arrange
      when(mockDataSource.deleteProfileImage(tUserId))
          .thenThrow(Exception('Erro inesperado'));

      // act
      final result = await repository.deleteProfileImage(tUserId);

      // assert
      expect(result, const Left<Failure, dynamic>(StorageFailure()));
    });

    test('deve lidar com usuário inexistente graciosamente', () async {
      // arrange
      const nonExistentUserId = 'user-nao-existe';
      when(mockDataSource.deleteProfileImage(nonExistentUserId))
          .thenAnswer((_) async => false);

      // act
      final result = await repository.deleteProfileImage(nonExistentUserId);

      // assert
      expect(result, const Right<Failure, dynamic>(unit));
      verify(mockDataSource.deleteProfileImage(nonExistentUserId));
    });
  });
}
