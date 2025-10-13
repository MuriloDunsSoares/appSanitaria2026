import 'package:app_sanitaria/core/error/exceptions.dart';
import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/data/datasources/firebase_chat_datasource.dart';
import 'package:app_sanitaria/data/repositories/chat_repository_firebase_impl.dart';
import 'package:app_sanitaria/domain/entities/conversation_entity.dart';
import 'package:app_sanitaria/domain/entities/message_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([FirebaseChatDataSource])
import 'chat_repository_firebase_impl_test.mocks.dart';

void main() {
  late ChatRepositoryFirebaseImpl repository;
  late MockFirebaseChatDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockFirebaseChatDataSource();
    repository = ChatRepositoryFirebaseImpl(
      firebaseChatDataSource: mockDataSource,
    );
  });

  final tMessage2 = MessageEntity(
    id: 'msg-2',
    conversationId: 'conv-1',
    senderId: 'user-2',
    senderName: 'Maria Santos',
    receiverId: 'user-1',
    text: 'Oi! Tudo ótimo, e você?',
    timestamp: DateTime(2025, 10, 7, 10, 5),
    isRead: true,
  );

  final tMessage1 = MessageEntity(
    id: 'msg-1',
    conversationId: 'conv-1',
    senderId: 'user-1',
    senderName: 'João Silva',
    receiverId: 'user-2',
    text: 'Olá, tudo bem?',
    timestamp: DateTime(2025, 10, 7, 10),
  );

  final tConversation1 = ConversationEntity(
    id: 'conv-1',
    participants: ['user-1', 'user-2'],
    otherUserId: 'user-2',
    otherUserName: 'Maria Santos',
    otherUserSpecialty: 'Enfermeira',
    lastMessage: tMessage2,
    lastMessageTime: DateTime(2025, 10, 7, 10, 5),
    unreadCount: 2,
  );

  final tConversation2 = ConversationEntity(
    id: 'conv-2',
    participants: ['user-1', 'user-3'],
    otherUserId: 'user-3',
    otherUserName: 'Pedro Oliveira',
    lastMessageTime: DateTime(2025, 10, 7, 9),
  );

  group('ChatRepositoryFirebaseImpl - getUserConversations', () {
    test('deve retornar lista de conversas do usuário', () async {
      // arrange
      const userId = 'user-1';
      when(mockDataSource.getUserConversationsStream(userId))
          .thenAnswer((_) => Stream.value([tConversation1, tConversation2]));

      // act
      final result = await repository.getUserConversations(userId);

      // assert
      expect(
          result,
          Right<Failure, List<ConversationEntity>>(
              [tConversation1, tConversation2]));
      verify(mockDataSource.getUserConversationsStream(userId));
      verifyNoMoreInteractions(mockDataSource);
    });

    test('deve retornar lista vazia quando não houver conversas', () async {
      // arrange
      const userId = 'user-1';
      when(mockDataSource.getUserConversationsStream(userId))
          .thenAnswer((_) => Stream.value([]));

      // act
      final result = await repository.getUserConversations(userId);

      // assert
      expect(result, const Right<Failure, List<ConversationEntity>>([]));
    });

    test('deve retornar NetworkFailure quando ocorrer erro de rede', () async {
      // arrange
      const userId = 'user-1';
      when(mockDataSource.getUserConversationsStream(userId))
          .thenThrow(const NetworkException('Sem conexão'));

      // act
      final result = await repository.getUserConversations(userId);

      // assert
      expect(result,
          const Left<Failure, List<ConversationEntity>>(NetworkFailure()));
    });

    test('deve retornar StorageFailure quando ocorrer erro genérico', () async {
      // arrange
      const userId = 'user-1';
      when(mockDataSource.getUserConversationsStream(userId))
          .thenThrow(Exception('Erro inesperado'));

      // act
      final result = await repository.getUserConversations(userId);

      // assert
      expect(result,
          const Left<Failure, List<ConversationEntity>>(StorageFailure()));
    });
  });

  group('ChatRepositoryFirebaseImpl - getConversationBetween', () {
    test('deve retornar conversa entre dois usuários', () async {
      // arrange
      const userId1 = 'user-1';
      const userId2 = 'user-2';
      when(mockDataSource.getConversationBetween(userId1, userId2))
          .thenAnswer((_) async => tConversation1);

      // act
      final result = await repository.getConversationBetween(userId1, userId2);

      // assert
      expect(result, Right<Failure, ConversationEntity>(tConversation1));
      verify(mockDataSource.getConversationBetween(userId1, userId2));
    });

    test('deve retornar NotFoundFailure quando conversa não existe', () async {
      // arrange
      const userId1 = 'user-1';
      const userId2 = 'user-99';
      when(mockDataSource.getConversationBetween(userId1, userId2))
          .thenAnswer((_) async => null);

      // act
      final result = await repository.getConversationBetween(userId1, userId2);

      // assert
      expect(
          result,
          const Left<Failure, ConversationEntity>(
            NotFoundFailure('Conversa não encontrada'),
          ));
    });

    test('deve retornar StorageFailure quando ocorrer erro', () async {
      // arrange
      const userId1 = 'user-1';
      const userId2 = 'user-2';
      when(mockDataSource.getConversationBetween(userId1, userId2))
          .thenThrow(Exception('Erro'));

      // act
      final result = await repository.getConversationBetween(userId1, userId2);

      // assert
      expect(result, const Left<Failure, ConversationEntity>(StorageFailure()));
    });
  });

  group('ChatRepositoryFirebaseImpl - getMessages', () {
    test('deve retornar lista de mensagens entre dois usuários', () async {
      // arrange
      const userId1 = 'user-1';
      const userId2 = 'user-2';
      const conversationId = '$userId1-$userId2';
      when(mockDataSource.getMessagesStream(conversationId))
          .thenAnswer((_) => Stream.value([tMessage1, tMessage2]));

      // act
      final result = await repository.getMessages(
        userId1: userId1,
        userId2: userId2,
      );

      // assert
      expect(
          result, Right<Failure, List<MessageEntity>>([tMessage1, tMessage2]));
    });

    test('deve retornar lista vazia quando não houver mensagens', () async {
      // arrange
      const userId1 = 'user-1';
      const userId2 = 'user-2';
      const conversationId = '$userId1-$userId2';
      when(mockDataSource.getMessagesStream(conversationId))
          .thenAnswer((_) => Stream.value([]));

      // act
      final result = await repository.getMessages(
        userId1: userId1,
        userId2: userId2,
      );

      // assert
      expect(result, const Right<Failure, List<MessageEntity>>([]));
    });

    test('deve retornar StorageFailure quando ocorrer erro', () async {
      // arrange
      const userId1 = 'user-1';
      const userId2 = 'user-2';
      const conversationId = '$userId1-$userId2';
      when(mockDataSource.getMessagesStream(conversationId))
          .thenThrow(Exception('Erro'));

      // act
      final result = await repository.getMessages(
        userId1: userId1,
        userId2: userId2,
      );

      // assert
      expect(
          result, const Left<Failure, List<MessageEntity>>(StorageFailure()));
    });
  });

  group('ChatRepositoryFirebaseImpl - sendMessage', () {
    test('deve enviar mensagem com sucesso', () async {
      // arrange
      const senderId = 'user-1';
      const receiverId = 'user-2';
      const content = 'Olá!';
      const conversationId = '$senderId-$receiverId';

      when(mockDataSource.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        senderName: '',
        receiverId: receiverId,
        text: content,
      )).thenAnswer((_) async => tMessage1);

      // act
      final result = await repository.sendMessage(
        senderId: senderId,
        receiverId: receiverId,
        content: content,
      );

      // assert
      expect(result, Right<Failure, MessageEntity>(tMessage1));
    });

    test('deve retornar NetworkFailure quando ocorrer erro de rede', () async {
      // arrange
      const senderId = 'user-1';
      const receiverId = 'user-2';
      const content = 'Olá!';
      const conversationId = '$senderId-$receiverId';

      when(mockDataSource.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        senderName: '',
        receiverId: receiverId,
        text: content,
      )).thenThrow(const NetworkException('Sem conexão'));

      // act
      final result = await repository.sendMessage(
        senderId: senderId,
        receiverId: receiverId,
        content: content,
      );

      // assert
      expect(result, const Left<Failure, MessageEntity>(NetworkFailure()));
    });

    test('deve retornar StorageFailure quando ocorrer erro genérico', () async {
      // arrange
      const senderId = 'user-1';
      const receiverId = 'user-2';
      const content = 'Olá!';
      const conversationId = '$senderId-$receiverId';

      when(mockDataSource.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        senderName: '',
        receiverId: receiverId,
        text: content,
      )).thenThrow(Exception('Erro'));

      // act
      final result = await repository.sendMessage(
        senderId: senderId,
        receiverId: receiverId,
        content: content,
      );

      // assert
      expect(result, const Left<Failure, MessageEntity>(StorageFailure()));
    });
  });

  group('ChatRepositoryFirebaseImpl - startConversation', () {
    test('deve iniciar nova conversa com sucesso', () async {
      // arrange
      const userId1 = 'user-1';
      const userId2 = 'user-2';
      const user1Name = 'João Silva';
      const user2Name = 'Maria Santos';
      const user2Specialty = 'Enfermeira';

      when(mockDataSource.createConversation(
        userId1,
        userId2,
        user1Name,
        user2Name,
        user2Specialty,
      )).thenAnswer((_) async => tConversation1);

      // act
      final result = await repository.startConversation(
        userId1: userId1,
        userId2: userId2,
        user1Name: user1Name,
        user2Name: user2Name,
        user2Specialty: user2Specialty,
      );

      // assert
      expect(result, Right<Failure, ConversationEntity>(tConversation1));
    });

    test('deve retornar NetworkFailure quando ocorrer erro de rede', () async {
      // arrange
      when(mockDataSource.createConversation(any, any, any, any, any))
          .thenThrow(const NetworkException('Sem conexão'));

      // act
      final result = await repository.startConversation(
        userId1: 'user-1',
        userId2: 'user-2',
        user1Name: 'João',
        user2Name: 'Maria',
      );

      // assert
      expect(result, const Left<Failure, ConversationEntity>(NetworkFailure()));
    });
  });

  group('ChatRepositoryFirebaseImpl - markMessagesAsRead', () {
    test('deve marcar mensagens como lidas com sucesso', () async {
      // arrange
      const conversationId = 'conv-1';
      const userId = 'user-1';

      when(mockDataSource.markMessagesAsRead(conversationId, userId))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.markMessagesAsRead(
        conversationId: conversationId,
        userId: userId,
      );

      // assert
      expect(result, const Right<Failure, Unit>(unit));
      verify(mockDataSource.markMessagesAsRead(conversationId, userId));
    });

    test('deve retornar StorageFailure quando ocorrer erro', () async {
      // arrange
      const conversationId = 'conv-1';
      const userId = 'user-1';

      when(mockDataSource.markMessagesAsRead(conversationId, userId))
          .thenThrow(Exception('Erro'));

      // act
      final result = await repository.markMessagesAsRead(
        conversationId: conversationId,
        userId: userId,
      );

      // assert
      expect(result, const Left<Failure, Unit>(StorageFailure()));
    });
  });

  group('ChatRepositoryFirebaseImpl - getUnreadCount', () {
    test('deve retornar contagem de mensagens não lidas', () async {
      // arrange
      const userId = 'user-1';
      when(mockDataSource.getUserConversationsStream(userId))
          .thenAnswer((_) => Stream.value([tConversation1, tConversation2]));

      // act
      final result = await repository.getUnreadCount(userId);

      // assert
      expect(
          result, const Right<Failure, int>(2)); // tConversation1 tem 2 unread
    });

    test('deve retornar 0 quando não houver mensagens não lidas', () async {
      // arrange
      const userId = 'user-1';
      when(mockDataSource.getUserConversationsStream(userId))
          .thenAnswer((_) => Stream.value([tConversation2]));

      // act
      final result = await repository.getUnreadCount(userId);

      // assert
      expect(result, const Right<Failure, int>(0));
    });

    test('deve retornar StorageFailure quando ocorrer erro', () async {
      // arrange
      const userId = 'user-1';
      when(mockDataSource.getUserConversationsStream(userId))
          .thenThrow(Exception('Erro'));

      // act
      final result = await repository.getUnreadCount(userId);

      // assert
      expect(result, const Left<Failure, int>(StorageFailure()));
    });
  });
}
