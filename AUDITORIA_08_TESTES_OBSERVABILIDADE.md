# 🧪 TESTES E OBSERVABILIDADE - AppSanitaria

**Data:** 7 de Outubro, 2025  
**Cobertura Atual:** <5%  
**Cobertura Alvo:** >70%

---

## 📊 ESTRATÉGIA DE TESTES

### Pirâmide de Testes
```
      /\      E2E (5 testes)         5%
     /  \     
    /____\    Integration (10)      10%
   /      \   
  /________\  Widget (30)           25%
 /          \ 
/____________\ Unit (100+)          60%
```

**Total:** 145+ testes

---

## 🔬 TESTES UNITÁRIOS

### Cobertura Alvo
- **Use Cases:** 100% (15 use cases × 5 testes = 75 testes)
- **Repositories:** 100% (7 repos × 3 testes = 21 testes)
- **Entities:** 100% (toJson/fromJson)
- **Utils:** 100% (validators, formatters)

### Estrutura
```
test/
├── domain/
│   ├── usecases/
│   │   ├── auth/
│   │   │   ├── login_user_test.dart
│   │   │   ├── register_user_test.dart
│   │   │   └── logout_user_test.dart
│   │   ├── contracts/
│   │   └── ... (15+ use cases)
│   └── entities/
│       └── user_entity_test.dart
├── data/
│   ├── repositories/
│   │   └── auth_repository_impl_test.dart
│   └── datasources/
│       └── auth_local_datasource_test.dart
└── core/
    ├── utils/
    │   └── validators_test.dart
    └── error/
        └── failures_test.dart
```

### Exemplo de Teste Unitário
```dart
// test/domain/usecases/auth/login_user_test.dart
@GenerateMocks([AuthRepository])
void main() {
  late LoginUser usecase;
  late MockAuthRepository mockRepo;
  
  setUp(() {
    mockRepo = MockAuthRepository();
    usecase = LoginUser(mockRepo);
  });
  
  group('LoginUser', () {
    test('should return user when credentials valid', () async {
      // arrange
      when(mockRepo.login(email: any, password: any))
          .thenAnswer((_) async => Right(tUser));
      
      // act
      final result = await usecase(LoginParams(email: tEmail, password: tPass));
      
      // assert
      expect(result, Right(tUser));
    });
    
    test('should return ValidationFailure when email empty', () async {
      final result = await usecase(LoginParams(email: '', password: tPass));
      expect(result, isA<Left<ValidationFailure, UserEntity>>());
    });
  });
}
```

---

## 🎨 TESTES DE WIDGET

### Cobertura Alvo
- Todos os 9 widgets reutilizáveis
- Componentes críticos de telas

### Exemplo
```dart
// test/presentation/widgets/professional_card_test.dart
void main() {
  testWidgets('should display professional name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfessionalCard(
            professional: {'nome': 'Dr. João', 'especialidade': 'Cuidador'},
          ),
        ),
      ),
    );
    
    expect(find.text('Dr. João'), findsOneWidget);
    expect(find.text('Cuidador'), findsOneWidget);
  });
  
  testWidgets('should show favorite icon when favorited', (tester) async {
    // ...
  });
}
```

---

## 🔗 TESTES DE INTEGRAÇÃO

### Cobertura
- Fluxos críticos end-to-end
- 10 testes principais

### Fluxos
1. Login → Home → Logout
2. Register → Home
3. Search → Professional Detail → Hiring
4. Chat: Send Message → Receive → Reply
5. Contract: Create → Accept → Complete → Review

### Exemplo
```dart
// integration_test/login_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('complete login flow', (tester) async {
    await tester.pumpWidget(const MyApp());
    
    // Enter credentials
    await tester.enterText(find.byKey(const Key('email')), 'test@email.com');
    await tester.enterText(find.byKey(const Key('password')), 'password123');
    
    // Tap login
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();
    
    // Verify home screen
    expect(find.text('Buscar Profissionais'), findsOneWidget);
  });
}
```

---

## 🚦 DOUBLES (Mocks, Stubs, Fakes)

### Mockito para Unit Tests
```dart
@GenerateMocks([
  AuthRepository,
  ProfessionalsRepository,
  ContractsRepository,
  // ... todos os repositories
])
void main() {
  // Mocks são gerados automaticamente
}
```

### Fake DataSources para Integration Tests
```dart
class FakeAuthDataSource implements AuthLocalDataSource {
  final Map<String, UserModel> _users = {};
  
  @override
  Future<UserModel> login(String email, String password) async {
    final user = _users.values.firstWhere(
      (u) => u.email == email,
      orElse: () => throw CacheException('Not found'),
    );
    return user;
  }
}
```

---

## 📈 COBERTURA DE TESTES

### Comandos
```bash
# Executar testes com coverage
flutter test --coverage

# Gerar relatório HTML
genhtml coverage/lcov.info -o coverage/html

# Abrir no navegador
open coverage/html/index.html
```

### Alvo por Camada
- **Domain:** 100% (crítico)
- **Data:** 90% (repositories e datasources)
- **Presentation:** 60% (providers e widgets)
- **Core:** 100% (utils e error handling)

**Média Geral:** >70%

---

## 📊 OBSERVABILIDADE

### Logging Estruturado
```dart
// lib/core/utils/app_logger.dart (atualizado)
import 'package:logger/logger.dart';

class AppLogger {
  static final _logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  
  static void info(String message, [dynamic data]) {
    _logger.i(message, error: data);
  }
  
  static void warning(String message, [dynamic data]) {
    _logger.w(message, error: data);
  }
  
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
```

### Métricas de Performance
```dart
// lib/core/utils/performance_tracker.dart
import 'dart:developer' as developer;

class PerformanceTracker {
  static void trackAction(String name, VoidCallback action) {
    final stopwatch = Stopwatch()..start();
    
    developer.Timeline.startSync(name);
    action();
    developer.Timeline.finishSync();
    
    stopwatch.stop();
    AppLogger.info('[$name] took ${stopwatch.elapsedMilliseconds}ms');
  }
  
  static Future<T> trackAsync<T>(String name, Future<T> Function() action) async {
    final stopwatch = Stopwatch()..start();
    
    developer.Timeline.startSync(name);
    final result = await action();
    developer.Timeline.finishSync();
    
    stopwatch.stop();
    AppLogger.info('[$name] took ${stopwatch.elapsedMilliseconds}ms');
    
    return result;
  }
}
```

### Uso
```dart
// Medir performance de use case
final result = await PerformanceTracker.trackAsync(
  'LoginUser',
  () => loginUser(LoginParams(email: email, password: password)),
);
```

### Métricas Rastreadas
- **Cold Start Time:** Tempo até primeira tela
- **Use Case Execution:** Tempo de cada use case
- **API Calls:** Latência de requests (futuro)
- **Frame Time:** Tempo de render de cada frame
- **Memory Usage:** Uso de memória por tela
- **Cache Hit Rate:** Taxa de acerto do cache

### Dashboards (Futuro com Sentry/Firebase)
```yaml
# pubspec.yaml (futuro)
dependencies:
  sentry_flutter: ^8.14.0
  firebase_crashlytics: ^4.3.0
  firebase_performance: ^0.10.7
```

---

## ✅ CHECKLIST DE TESTES

### Antes de Merge
- [ ] Testes unitários para novos use cases
- [ ] Testes de widget para novos componentes
- [ ] Coverage >70% nas alterações
- [ ] Todos os testes passando
- [ ] Sem testes flaky (intermitentes)

### Antes de Release
- [ ] Integration tests passando
- [ ] E2E smoke tests passando
- [ ] Performance profiling realizado
- [ ] Memory leaks verificados
- [ ] Crash-free rate >99.9%

---

[◀️ Voltar à Performance](./AUDITORIA_07_PERFORMANCE.md) | [Próximo: Entregáveis ▶️](./AUDITORIA_09_ENTREGAVEIS.md)

