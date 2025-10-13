/// Interface base para todos os Use Cases da aplicação.
///
/// **Clean Architecture - Use Case Layer:**
/// - Encapsulam TODA a lógica de negócio da aplicação
/// - São a única forma de executar operações no domínio
/// - Independentes de frameworks, UI e infraestrutura
/// - Testáveis isoladamente com mocks
///
/// **Convenção de Nomenclatura:**
/// - Nome: `<Verbo><Substantivo>` (ex: LoginUser, GetProfessionals)
/// - Um Use Case = Uma responsabilidade única (SRP)
/// - Parâmetros complexos usam classes Params dedicadas
///
/// **Exemplo de uso:**
/// ```dart
/// final usecase = sl<LoginUser>();
/// final result = await usecase(LoginParams(email: 'test@test.com', password: '123'));
/// result.fold(
///   (failure) => print('Erro: ${failure.message}'),
///   (user) => print('Sucesso: ${user.name}'),
/// );
/// ```
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Interface base para Use Cases que retornam um resultado.
///
/// **Type Parameters:**
/// - [Type]: O tipo de retorno em caso de sucesso
/// - [Params]: Os parâmetros de entrada (use [NoParams] se não houver)
///
/// **Por que Either<Failure, Type>?**
/// - Programação funcional: erros são valores, não exceptions
/// - Força o tratamento explícito de erros na UI
/// - Facilita testes (não precisa try-catch)
abstract class UseCase<Type, Params> {
  /// Executa o caso de uso com os [params] fornecidos.
  ///
  /// Retorna:
  /// - [Left(Failure)]: em caso de erro (ex: usuário não encontrado)
  /// - [Right(Type)]: em caso de sucesso (ex: usuário autenticado)
  Future<Either<Failure, Type>> call(Params params);
}

/// Classe placeholder para Use Cases sem parâmetros.
///
/// **Exemplo:**
/// ```dart
/// class GetCurrentUser extends UseCase<UserEntity, NoParams> {
///   @override
///   Future<Either<Failure, UserEntity>> call(NoParams params) async {
///     return await repository.getCurrentUser();
///   }
/// }
/// ```
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}


