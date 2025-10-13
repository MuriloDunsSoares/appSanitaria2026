/// Integration Test: Auth Flow
///
/// Este teste valida que as camadas Domain + Data funcionam JUNTAS:
/// - Use Cases → Repositories → DataSources → SharedPreferences
///
/// Diferença para Unit Tests:
/// - Unit: Testa ISOLADO com mocks
/// - Integration: Testa INTEGRAÇÃO entre camadas reais
///
/// O que este teste garante:
/// 1. Use Cases conseguem chamar Repositories corretamente
/// 2. Repositories conseguem chamar DataSources corretamente
/// 3. DataSources conseguem persistir dados no SharedPreferences
/// 4. Todo o fluxo de dados funciona end-to-end
///
/// Bugs que detecta:
/// - Incompatibilidade entre camadas
/// - Problemas de serialização/desserialização
/// - Falhas no fluxo de dados entre camadas
/// - Problemas de persistência
library;

import 'package:app_sanitaria/core/di/injection_container.dart';
import 'package:app_sanitaria/core/usecases/usecase.dart';
import 'package:app_sanitaria/domain/entities/patient_entity.dart';
import 'package:app_sanitaria/domain/entities/professional_entity.dart';
import 'package:app_sanitaria/domain/entities/speciality.dart';
import 'package:app_sanitaria/domain/entities/user_entity.dart';
import 'package:app_sanitaria/domain/usecases/auth/get_current_user.dart';
import 'package:app_sanitaria/domain/usecases/auth/login_user.dart';
import 'package:app_sanitaria/domain/usecases/auth/logout_user.dart';
import 'package:app_sanitaria/domain/usecases/auth/register_patient.dart';
import 'package:app_sanitaria/domain/usecases/auth/register_professional.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LoginUser loginUseCase;
  late RegisterPatient registerPatientUseCase;
  late RegisterProfessional registerProfessionalUseCase;
  late GetCurrentUser getCurrentUserUseCase;
  late LogoutUser logoutUseCase;

  setUp(() async {
    // Limpar SharedPreferences antes de cada teste
    SharedPreferences.setMockInitialValues({});

    // Inicializar DI com dependências REAIS (não mocks!)
    await setupDependencyInjection();

    // Obter Use Cases do DI
    loginUseCase = sl<LoginUser>();
    registerPatientUseCase = sl<RegisterPatient>();
    registerProfessionalUseCase = sl<RegisterProfessional>();
    getCurrentUserUseCase = sl<GetCurrentUser>();
    logoutUseCase = sl<LogoutUser>();
  });

  tearDown(() async {
    // Limpar DI após cada teste
    await sl.reset();
  });

  group('Integration Test: Fluxo Completo de Autenticação de Paciente', () {
    test('deve registrar paciente, fazer login, verificar sessão e logout',
        () async {
      // ════════════════════════════════════════════════════════════
      // FASE 1: REGISTRO DE PACIENTE
      // ════════════════════════════════════════════════════════════
      final newPatient = PatientEntity(
        id: 'patient-integration-001',
        nome: 'João da Silva',
        email: 'joao.integration@test.com',
        password: 'senha123',
        telefone: '11999999999',
        cidade: 'São Paulo',
        estado: 'SP',
        dataNascimento: DateTime(1990, 5, 15),
        endereco: 'Rua Teste, 123',
        sexo: 'M',
        dataCadastro: DateTime.now(),
      );

      // ACT: Registrar paciente
      final registerResult = await registerPatientUseCase(newPatient);

      // ASSERT: Registro deve ser bem-sucedido
      registerResult.fold(
        (failure) => fail('Registro falhou: ${failure.message}'),
        (user) {
          expect(user.id, newPatient.id);
          expect(user.email, newPatient.email);
          expect(user.nome, newPatient.nome);
        },
      );

      // ════════════════════════════════════════════════════════════
      // FASE 2: VERIFICAR SESSÃO APÓS REGISTRO
      // ════════════════════════════════════════════════════════════
      // O registro deve ter salvado a sessão automaticamente
      final getCurrentUserResult1 = await getCurrentUserUseCase(NoParams());

      // ASSERT: Deve haver usuário logado
      getCurrentUserResult1.fold(
        (failure) => fail('Deveria haver usuário logado após registro'),
        (user) {
          expect(user.id, newPatient.id);
          expect(user.email, newPatient.email);
        },
      );

      // ════════════════════════════════════════════════════════════
      // FASE 3: LOGOUT
      // ════════════════════════════════════════════════════════════
      final logoutResult = await logoutUseCase(NoParams());

      // ASSERT: Logout deve ser bem-sucedido
      logoutResult.fold(
        (failure) => fail('Logout falhou: ${failure.message}'),
        (_) => <String, dynamic>{}, // Sucesso
      );

      // ════════════════════════════════════════════════════════════
      // FASE 4: VERIFICAR SESSÃO APÓS LOGOUT
      // ════════════════════════════════════════════════════════════
      final getCurrentUserResult2 = await getCurrentUserUseCase(NoParams());

      // ASSERT: NÃO deve haver usuário logado
      getCurrentUserResult2.fold(
        (failure) => <String, dynamic>{}, // Esperado: falha
        (user) => fail('Não deveria haver usuário logado após logout'),
      );

      // ════════════════════════════════════════════════════════════
      // FASE 5: LOGIN COM CREDENCIAIS
      // ════════════════════════════════════════════════════════════
      const loginParams = LoginParams(
        email: 'joao.integration@test.com',
        password: 'senha123',
      );
      final loginResult = await loginUseCase(loginParams);

      // ASSERT: Login deve ser bem-sucedido
      loginResult.fold(
        (failure) => fail('Login falhou: ${failure.message}'),
        (user) {
          expect(user.id, newPatient.id);
          expect(user.email, newPatient.email);
        },
      );

      // ════════════════════════════════════════════════════════════
      // FASE 6: VERIFICAR SESSÃO APÓS LOGIN
      // ════════════════════════════════════════════════════════════
      final getCurrentUserResult3 = await getCurrentUserUseCase(NoParams());

      // ASSERT: Deve haver usuário logado novamente
      getCurrentUserResult3.fold(
        (failure) => fail('Deveria haver usuário logado após login'),
        (user) {
          expect(user.id, newPatient.id);
          expect(user.email, newPatient.email);
        },
      );

      // ✅ TESTE COMPLETO: 6 fases validadas com sucesso!
    });

    test('deve impedir login com credenciais inválidas', () async {
      // ARRANGE: Registrar um paciente
      final patient = PatientEntity(
        id: 'patient-002',
        nome: 'Maria Santos',
        email: 'maria@test.com',
        password: 'senha_correta',
        telefone: '11988888888',
        cidade: 'Rio de Janeiro',
        estado: 'RJ',
        dataNascimento: DateTime(1995, 3, 20),
        endereco: 'Av. Brasil, 456',
        sexo: 'F',
        dataCadastro: DateTime.now(),
      );

      await registerPatientUseCase(patient);
      await logoutUseCase(NoParams()); // Fazer logout

      // ACT: Tentar login com senha ERRADA
      const loginParams = LoginParams(
        email: 'maria@test.com',
        password: 'senha_errada',
      );
      final loginResult = await loginUseCase(loginParams);

      // ASSERT: Login deve FALHAR
      loginResult.fold(
        (failure) {
          // Esperado: InvalidCredentialsFailure
          final msg = failure.message.toLowerCase();
          expect(
              msg.contains('senha') ||
                  msg.contains('incorreto') ||
                  msg.contains('credenciais'),
              isTrue);
        },
        (user) => fail('Login deveria ter falhado com senha incorreta'),
      );

      // VERIFICAR: Sessão deve continuar vazia
      final getCurrentUserResult = await getCurrentUserUseCase(NoParams());
      getCurrentUserResult.fold(
        (failure) => <String, dynamic>{}, // Esperado: sem usuário logado
        (user) => fail('Não deveria haver usuário logado após login falhado'),
      );
    });

    test('deve impedir registro com email duplicado', () async {
      // ARRANGE: Registrar primeiro paciente
      final patient1 = PatientEntity(
        id: 'patient-003',
        nome: 'Carlos Souza',
        email: 'carlos@test.com',
        password: 'senha123',
        telefone: '11977777777',
        cidade: 'Brasília',
        estado: 'DF',
        dataNascimento: DateTime(1988, 8, 10),
        endereco: 'SQN 456',
        sexo: 'M',
        dataCadastro: DateTime.now(),
      );

      await registerPatientUseCase(patient1);

      // ACT: Tentar registrar outro paciente com MESMO EMAIL
      final patient2 = PatientEntity(
        id: 'patient-004',
        nome: 'Carlos Souza Junior',
        email: 'carlos@test.com', // Email duplicado!
        password: 'outra_senha',
        telefone: '11966666666',
        cidade: 'São Paulo',
        estado: 'SP',
        dataNascimento: DateTime(2000),
        endereco: 'Rua XYZ',
        sexo: 'M',
        dataCadastro: DateTime.now(),
      );

      final registerResult = await registerPatientUseCase(patient2);

      // ASSERT: Registro deve FALHAR
      registerResult.fold(
        (failure) {
          // Esperado: EmailAlreadyExistsFailure
          expect(failure.message.toLowerCase(), contains('email'));
          expect(failure.message.toLowerCase(), contains('cadastrado'));
        },
        (user) => fail('Registro deveria ter falhado com email duplicado'),
      );
    });
  });

  group('Integration Test: Fluxo Completo de Autenticação de Profissional', () {
    test('deve registrar profissional e fazer login', () async {
      // ARRANGE: Criar profissional
      final professional = ProfessionalEntity(
        id: 'prof-integration-001',
        nome: 'Dra. Ana Paula',
        email: 'ana.prof@test.com',
        password: 'senha123',
        telefone: '11955555555',
        cidade: 'São Paulo',
        estado: 'SP',
        dataNascimento: DateTime(1985, 4, 25),
        endereco: 'Av. Paulista, 1000',
        sexo: 'F',
        dataCadastro: DateTime.now(),
        especialidade: Speciality.tecnicosEnfermagem,
        formacao: 'Enfermagem - USP',
        certificados: 'COREN-SP-123456',
        experiencia: 15,
        avaliacao: 4.9,
        hourlyRate: 80,
      );

      // ACT: Registrar profissional
      final registerResult = await registerProfessionalUseCase(professional);

      // ASSERT: Registro deve ser bem-sucedido
      registerResult.fold(
        (failure) => fail('Registro profissional falhou: ${failure.message}'),
        (user) {
          expect(user.id, professional.id);
          expect(user.email, professional.email);
          expect(user.tipo, UserType.profissional);
        },
      );

      // Fazer logout
      await logoutUseCase(NoParams());

      // ACT: Login como profissional
      const loginParams = LoginParams(
        email: 'ana.prof@test.com',
        password: 'senha123',
      );
      final loginResult = await loginUseCase(loginParams);

      // ASSERT: Login deve ser bem-sucedido
      loginResult.fold(
        (failure) => fail('Login profissional falhou: ${failure.message}'),
        (user) {
          expect(user.id, professional.id);
          expect(user.email, professional.email);
          expect(user.tipo, UserType.profissional);
        },
      );
    });
  });

  group('Integration Test: Persistência de Dados', () {
    test('deve persistir dados entre "reinicializações" do app', () async {
      // ════════════════════════════════════════════════════════════
      // SIMULAÇÃO: PRIMEIRA EXECUÇÃO DO APP
      // ════════════════════════════════════════════════════════════
      final patient = PatientEntity(
        id: 'patient-persist-001',
        nome: 'Pedro Oliveira',
        email: 'pedro@test.com',
        password: 'senha123',
        telefone: '11944444444',
        cidade: 'Curitiba',
        estado: 'PR',
        dataNascimento: DateTime(1992, 11, 5),
        endereco: 'Rua das Flores, 789',
        sexo: 'M',
        dataCadastro: DateTime.now(),
      );

      await registerPatientUseCase(patient);

      // ════════════════════════════════════════════════════════════
      // SIMULAÇÃO: FECHAR E REABRIR O APP
      // ════════════════════════════════════════════════════════════
      // Reset do DI (simula reinicialização)
      await sl.reset();
      await setupDependencyInjection();

      // Reobter Use Cases
      final newGetCurrentUserUseCase = sl<GetCurrentUser>();

      // ACT: Verificar se usuário ainda está logado
      final getCurrentUserResult = await newGetCurrentUserUseCase(NoParams());

      // ASSERT: Dados devem ter sido persistidos!
      getCurrentUserResult.fold(
        (failure) => fail('Dados não foram persistidos: ${failure.message}'),
        (user) {
          expect(user.id, patient.id);
          expect(user.email, patient.email);
          expect(user.nome, patient.nome);
        },
      );

      // ✅ GARANTIA: Dados sobrevivem à "reinicialização" do app!
    });
  });
}
