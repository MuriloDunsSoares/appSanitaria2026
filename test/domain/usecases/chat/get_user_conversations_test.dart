/// Testes para GetUserConversations Use Case
/// 
/// Objetivo: Validar busca de todas as conversas de um usuário
/// Regras de negócio:
/// - Deve retornar lista de conversas com última mensagem
/// - Lista pode ser vazia (usuário novo sem conversas)
/// - Deve retornar StorageFailure se erro ao buscar
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/entities/conversation_entity.dart';
import 'package:app_sanitaria/domain/entities/message_entity.dart';
import 'package:app_sanitaria/domain/repositories/chat_repository.dart';
import 'package:app_sanitaria/domain/usecases/chat/get_user_conversations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

// Gerar mock: dart run build_runner build
@GenerateMocks([ChatRepository])
void main() {
  late GetUserConversations useCase;
  late MockChatRepository mockRepository;

  setUp(() {
    mockRepository = MockChatRepository();
    useCase = GetUserConversations(mockRepository);
  });

  group('GetUserConversations', () {
    // Dados REALISTAS para testes
    const tUserId = 'patient123';
    
    final tLastMessage1 = MessageEntity(
      id: 'msg1',
      conversationId: 'conv1',
      senderId: 'prof456',
      senderName: 'João Santos',
      receiverId: tUserId,
      content: 'Posso começar na segunda-feira às 8h.',
      timestamp: DateTime(2025, 10, 9, 15, 30),
      isRead: false,
    );

    final tLastMessage2 = MessageEntity(
      id: 'msg2',
      conversationId: 'conv2',
      senderId: tUserId,
      senderName: 'Maria Silva',
      receiverId: 'prof789',
      content: 'Obrigada pelo atendimento!',
      timestamp: DateTime(2025, 10, 8, 10, 15),
      isRead: true,
    );

    final tConversation1 = ConversationEntity(
      id: 'conv1',
      participants: [tUserId, 'prof456'],
      otherUserId: 'prof456',
      otherUserName: 'João Santos',
      otherUserSpecialty: 'Técnicos de enfermagem',
      lastMessage: tLastMessage1,
      lastMessageTime: DateTime(2025, 10, 9, 15, 30),
      unreadCount: 2,
    );

    final tConversation2 = ConversationEntity(
      id: 'conv2',
      participants: [tUserId, 'prof789'],
      otherUserId: 'prof789',
      otherUserName: 'Ana Costa',
      otherUserSpecialty: 'Cuidadores',
      lastMessage: tLastMessage2,
      lastMessageTime: DateTime(2025, 10, 8, 10, 15),
      unreadCount: 0,
    );

    final tConversations = [tConversation1, tConversation2];

    test('deve retornar lista de conversas do usuário quando existem conversas', () async {
      // Arrange
      when(mockRepository.getUserConversations(tUserId))
          .thenAnswer((_) async => Right(tConversations));

      // Act
      final result = await useCase(tUserId);

      // Assert
      expect(result, isA<Right<Failure, List<ConversationEntity>>>());
      result.fold(
        (failure) => fail('Deveria retornar lista de conversas'),
        (conversations) {
          expect(conversations.length, 2);
          
          // Verificar primeira conversa
          expect(conversations[0].id, 'conv1');
          expect(conversations[0].otherUserName, 'João Santos');
          expect(conversations[0].unreadCount, 2);
          expect(conversations[0].lastMessage?.content, contains('segunda-feira'));
          
          // Verificar segunda conversa
          expect(conversations[1].id, 'conv2');
          expect(conversations[1].otherUserName, 'Ana Costa');
          expect(conversations[1].unreadCount, 0);
          expect(conversations[1].lastMessage?.isRead, true);
        },
      );

      verify(mockRepository.getUserConversations(tUserId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('deve retornar lista vazia quando usuário não tem conversas', () async {
      // Arrange
      when(mockRepository.getUserConversations(tUserId))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(tUserId);

      // Assert
      expect(result, isA<Right<Failure, List<ConversationEntity>>>());
      result.fold(
        (failure) => fail('Deveria retornar lista vazia'),
        (conversations) {
          expect(conversations, isEmpty);
        },
      );

      verify(mockRepository.getUserConversations(tUserId)).called(1);
    });

    test('deve retornar StorageFailure quando ocorre erro ao buscar conversas', () async {
      // Arrange
      when(mockRepository.getUserConversations(tUserId))
          .thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tUserId);

      // Assert
      expect(result, isA<Left<Failure, List<ConversationEntity>>>());
      result.fold(
        (failure) {
          expect(failure, isA<StorageFailure>());
        },
        (conversations) => fail('Deveria retornar StorageFailure'),
      );

      verify(mockRepository.getUserConversations(tUserId)).called(1);
    });
  });
}
