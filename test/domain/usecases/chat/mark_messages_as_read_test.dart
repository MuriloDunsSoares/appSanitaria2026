/// Testes para MarkMessagesAsRead Use Case
///
/// Objetivo: Validar marcação de mensagens como lidas
/// Regras de negócio:
/// - Deve marcar todas as mensagens de uma conversa como lidas
/// - Deve retornar Unit (sem valor de retorno)
/// - Deve retornar StorageFailure se erro ao atualizar
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/repositories/chat_repository.dart';
import 'package:app_sanitaria/domain/usecases/chat/mark_messages_as_read.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

// Gerar mock: dart run build_runner build
@GenerateMocks([ChatRepository])
void main() {
  late MarkMessagesAsRead useCase;
  late MockChatRepository mockRepository;

  setUp(() {
    mockRepository = MockChatRepository();
    useCase = MarkMessagesAsRead(mockRepository);
  });

  group('MarkMessagesAsRead', () {
    // Dados REALISTAS para testes
    const tConversationId = 'conv_patient123_prof456';
    const tUserId = 'patient123';

    const tParams = MarkMessagesAsReadParams(
      conversationId: tConversationId,
      userId: tUserId,
    );

    test('deve marcar mensagens como lidas com sucesso', () async {
      // Arrange
      when(mockRepository.markMessagesAsRead(
        conversationId: tConversationId,
        userId: tUserId,
      )).thenAnswer((_) async => const Right(unit));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Right<Failure, Unit>>());
      result.fold(
        (failure) => fail('Deveria marcar mensagens como lidas'),
        (success) {
          expect(success, unit);
        },
      );

      verify(mockRepository.markMessagesAsRead(
        conversationId: tConversationId,
        userId: tUserId,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('deve retornar StorageFailure quando falha ao marcar mensagens',
        () async {
      // Arrange
      when(mockRepository.markMessagesAsRead(
        conversationId: tConversationId,
        userId: tUserId,
      )).thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Left<Failure, Unit>>());
      result.fold(
        (failure) {
          expect(failure, isA<StorageFailure>());
        },
        (success) => fail('Deveria retornar StorageFailure'),
      );

      verify(mockRepository.markMessagesAsRead(
        conversationId: tConversationId,
        userId: tUserId,
      )).called(1);
    });

    test('deve funcionar corretamente com conversationId vazio', () async {
      // Arrange
      const emptyParams = MarkMessagesAsReadParams(
        conversationId: '',
        userId: tUserId,
      );

      when(mockRepository.markMessagesAsRead(
        conversationId: '',
        userId: tUserId,
      )).thenAnswer((_) async => const Right(unit));

      // Act
      final result = await useCase(emptyParams);

      // Assert
      expect(result, isA<Right<Failure, Unit>>());

      verify(mockRepository.markMessagesAsRead(
        conversationId: '',
        userId: tUserId,
      )).called(1);
    });
  });
}
