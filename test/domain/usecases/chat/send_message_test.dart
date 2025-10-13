/// Testes para SendMessage Use Case
///
/// Objetivo: Validar envio de mensagens entre usuários
/// Regras de negócio:
/// - Conteúdo não pode ser vazio
/// - Deve criar MessageEntity com timestamp
/// - Deve retornar ValidationFailure se conteúdo inválido
/// - Deve retornar StorageFailure se erro ao salvar
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/entities/message_entity.dart';
import 'package:app_sanitaria/domain/repositories/chat_repository.dart';
import 'package:app_sanitaria/domain/usecases/chat/send_message.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

// Gerar mock: dart run build_runner build
@GenerateMocks([ChatRepository])
void main() {
  late SendMessage useCase;
  late MockChatRepository mockRepository;

  setUp(() {
    mockRepository = MockChatRepository();
    useCase = SendMessage(mockRepository);
  });

  group('SendMessage', () {
    // Dados REALISTAS para testes
    const tSenderId = 'patient123';
    const tReceiverId = 'prof456';
    const tContent =
        'Olá! Gostaria de contratar seus serviços para cuidar da minha mãe.';

    final tMessage = MessageEntity(
      id: 'msg789',
      conversationId: 'conv_patient123_prof456',
      senderId: tSenderId,
      senderName: 'Maria Silva',
      receiverId: tReceiverId,
      content: tContent,
      timestamp: DateTime(2025, 10, 9, 14, 30),
    );

    const tParams = SendMessageParams(
      senderId: tSenderId,
      receiverId: tReceiverId,
      content: tContent,
    );

    test('deve enviar mensagem com sucesso quando conteúdo é válido', () async {
      // Arrange
      when(mockRepository.sendMessage(
        senderId: tSenderId,
        receiverId: tReceiverId,
        content: tContent,
      )).thenAnswer((_) async => Right(tMessage));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Right<Failure, MessageEntity>>());
      result.fold(
        (failure) => fail('Deveria retornar mensagem enviada'),
        (message) {
          expect(message.senderId, tSenderId);
          expect(message.receiverId, tReceiverId);
          expect(message.content, tContent);
          expect(message.isRead, false);
        },
      );

      verify(mockRepository.sendMessage(
        senderId: tSenderId,
        receiverId: tReceiverId,
        content: tContent,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('deve retornar ValidationFailure quando conteúdo está vazio',
        () async {
      // Arrange
      const emptyParams = SendMessageParams(
        senderId: tSenderId,
        receiverId: tReceiverId,
        content: '',
      );

      // Act
      final result = await useCase(emptyParams);

      // Assert
      expect(result, isA<Left<Failure, MessageEntity>>());
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).message, contains('vazio'));
        },
        (message) => fail('Deveria retornar ValidationFailure'),
      );

      verifyNever(mockRepository.sendMessage(
        senderId: anyNamed('senderId'),
        receiverId: anyNamed('receiverId'),
        content: anyNamed('content'),
      ));
    });

    test(
        'deve retornar ValidationFailure quando conteúdo contém apenas espaços',
        () async {
      // Arrange
      const whitespaceParams = SendMessageParams(
        senderId: tSenderId,
        receiverId: tReceiverId,
        content: '   ',
      );

      // Act
      final result = await useCase(whitespaceParams);

      // Assert
      expect(result, isA<Left<Failure, MessageEntity>>());
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (message) => fail('Deveria retornar ValidationFailure'),
      );

      verifyNever(mockRepository.sendMessage(
        senderId: anyNamed('senderId'),
        receiverId: anyNamed('receiverId'),
        content: anyNamed('content'),
      ));
    });

    test('deve retornar StorageFailure quando falha ao enviar mensagem',
        () async {
      // Arrange
      when(mockRepository.sendMessage(
        senderId: tSenderId,
        receiverId: tReceiverId,
        content: tContent,
      )).thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Left<Failure, MessageEntity>>());
      result.fold(
        (failure) {
          expect(failure, isA<StorageFailure>());
        },
        (message) => fail('Deveria retornar StorageFailure'),
      );

      verify(mockRepository.sendMessage(
        senderId: tSenderId,
        receiverId: tReceiverId,
        content: tContent,
      )).called(1);
    });
  });
}
