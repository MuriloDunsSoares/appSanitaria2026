/// Testes para GetMessages Use Case
/// 
/// Objetivo: Validar busca de mensagens entre dois usuários
/// Regras de negócio:
/// - Deve retornar lista ordenada por timestamp
/// - Lista pode ser vazia (sem conversas)
/// - Deve retornar StorageFailure se erro ao buscar
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/entities/message_entity.dart';
import 'package:app_sanitaria/domain/repositories/chat_repository.dart';
import 'package:app_sanitaria/domain/usecases/chat/get_messages.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

// Gerar mock: dart run build_runner build
@GenerateMocks([ChatRepository])
void main() {
  late GetMessages useCase;
  late MockChatRepository mockRepository;

  setUp(() {
    mockRepository = MockChatRepository();
    useCase = GetMessages(mockRepository);
  });

  group('GetMessages', () {
    // Dados REALISTAS para testes
    const tUserId1 = 'patient123';
    const tUserId2 = 'prof456';
    
    final tMessage1 = MessageEntity(
      id: 'msg1',
      conversationId: 'conv_patient123_prof456',
      senderId: tUserId1,
      senderName: 'Maria Silva',
      receiverId: tUserId2,
      content: 'Olá! Gostaria de contratar seus serviços.',
      timestamp: DateTime(2025, 10, 9, 14, 30),
      isRead: true,
    );

    final tMessage2 = MessageEntity(
      id: 'msg2',
      conversationId: 'conv_patient123_prof456',
      senderId: tUserId2,
      senderName: 'João Santos',
      receiverId: tUserId1,
      content: 'Olá Maria! Claro, quando você precisa?',
      timestamp: DateTime(2025, 10, 9, 14, 35),
      isRead: false,
    );

    final tMessage3 = MessageEntity(
      id: 'msg3',
      conversationId: 'conv_patient123_prof456',
      senderId: tUserId1,
      senderName: 'Maria Silva',
      receiverId: tUserId2,
      content: 'Seria possível começar na próxima segunda-feira?',
      timestamp: DateTime(2025, 10, 9, 14, 40),
      isRead: false,
    );

    final tMessages = [tMessage1, tMessage2, tMessage3];

    final tParams = GetMessagesParams(
      userId1: tUserId1,
      userId2: tUserId2,
    );

    test('deve retornar lista de mensagens entre dois usuários quando existem mensagens', () async {
      // Arrange
      when(mockRepository.getMessages(
        userId1: tUserId1,
        userId2: tUserId2,
      )).thenAnswer((_) async => Right(tMessages));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Right<Failure, List<MessageEntity>>>());
      result.fold(
        (failure) => fail('Deveria retornar lista de mensagens'),
        (messages) {
          expect(messages.length, 3);
          expect(messages[0].id, 'msg1');
          expect(messages[0].content, contains('contratar'));
          expect(messages[1].id, 'msg2');
          expect(messages[1].senderName, 'João Santos');
          expect(messages[2].id, 'msg3');
          expect(messages[2].isRead, false);
        },
      );

      verify(mockRepository.getMessages(
        userId1: tUserId1,
        userId2: tUserId2,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('deve retornar lista vazia quando não existem mensagens entre os usuários', () async {
      // Arrange
      when(mockRepository.getMessages(
        userId1: tUserId1,
        userId2: tUserId2,
      )).thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Right<Failure, List<MessageEntity>>>());
      result.fold(
        (failure) => fail('Deveria retornar lista vazia'),
        (messages) {
          expect(messages, isEmpty);
        },
      );

      verify(mockRepository.getMessages(
        userId1: tUserId1,
        userId2: tUserId2,
      )).called(1);
    });

    test('deve retornar StorageFailure quando ocorre erro ao buscar mensagens', () async {
      // Arrange
      when(mockRepository.getMessages(
        userId1: tUserId1,
        userId2: tUserId2,
      )).thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Left<Failure, List<MessageEntity>>>());
      result.fold(
        (failure) {
          expect(failure, isA<StorageFailure>());
        },
        (messages) => fail('Deveria retornar StorageFailure'),
      );

      verify(mockRepository.getMessages(
        userId1: tUserId1,
        userId2: tUserId2,
      )).called(1);
    });
  });
}
