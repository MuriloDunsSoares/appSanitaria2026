# ✨ QUALIDADE E ESTILO DE CÓDIGO - AppSanitaria

**Data:** 7 de Outubro, 2025  
**Padrão:** Effective Dart + Flutter Best Practices

---

## 📏 LINTS E ANALYZER

### Configuration Atual
```yaml
# analysis_options.yaml (atual - básico)
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Nenhuma regra adicional
```

### Configuration Proposta (Estrita)
```yaml
# analysis_options.yaml (proposto - strict)
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  
  errors:
    # Treat todos and fixmes as warnings
    todo: warning
    fixme: warning
    
    # Strict mode
    invalid_annotation_target: error
    missing_required_param: error
    missing_return: error
  
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

linter:
  rules:
    # Style
    - always_declare_return_types
    - always_put_required_named_parameters_first
    - always_use_package_imports
    - avoid_print
    - avoid_relative_lib_imports
    - avoid_types_as_parameter_names
    - camel_case_types
    - constant_identifier_names
    - curly_braces_in_flow_control_structures
    - directives_ordering
    - file_names
    - library_names
    - library_prefixes
    - non_constant_identifier_names
    - one_member_abstracts
    - package_api_docs
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - prefer_final_fields
    - prefer_final_locals
    - prefer_single_quotes
    - slash_for_doc_comments
    - sort_constructors_first
    - sort_unnamed_constructors_first
    - type_annotate_public_apis
    - unawaited_futures
    - unnecessary_brace_in_string_interps
    - unnecessary_const
    - unnecessary_new
    - unnecessary_null_aware_assignments
    - unnecessary_null_in_if_null_operators
    - use_function_type_syntax_for_parameters
    - use_key_in_widget_constructors
    - use_rethrow_when_possible
    
    # Pub
    - sort_pub_dependencies
    
    # Error handling
    - avoid_catching_errors
    - use_build_context_synchronously
    
    # Performance
    - avoid_unnecessary_containers
    - sized_box_for_whitespace
    - use_decorated_box
```

### Comandos de Validação
```bash
# Análise completa
dart analyze

# Análise com métricas
dart analyze --fatal-infos --fatal-warnings

# Fix automático (cuidado!)
dart fix --dry-run
dart fix --apply

# Verificar todos os arquivos
flutter analyze lib/ test/
```

---

## 🎨 CONVENÇÕES DE NOMENCLATURA

### Files & Directories
```
✅ Correto:
- user_entity.dart
- auth_provider.dart
- login_screen.dart
- professional_card.dart

❌ Errado:
- UserEntity.dart
- authProvider.dart
- LoginScreen.dart
- ProfessionalCard.dart
```

### Classes & Enums
```dart
✅ Correto:
class UserEntity {}
class AuthRepository {}
enum UserType {}
mixin ValidationMixin {}

❌ Errado:
class user_entity {}
class authRepository {}
enum userType {}
```

### Variables & Functions
```dart
✅ Correto:
final userName = 'João';
void fetchUserData() {}
bool isAuthenticated() => true;

❌ Errado:
final UserName = 'João';
void FetchUserData() {}
bool IsAuthenticated() => true;
```

### Constants
```dart
✅ Correto:
const int maxRetries = 3;
static const String apiBaseUrl = 'https://api.example.com';

// Para constantes muito longas, use UPPER_CASE
static const String VERY_LONG_COMPLEX_CONSTANT_NAME = '...';

❌ Errado:
const int MAX_RETRIES = 3; // Não use UPPER_CASE para constantes simples
```

### Private Members
```dart
✅ Correto:
class MyClass {
  final String _privateField;
  String _privateMethod() => '';
}

❌ Errado:
class MyClass {
  final String privateField; // Deveria ser _privateField
}
```

---

## 📦 ORGANIZAÇÃO DE IMPORTS

### Ordem de Imports (Dart Style Guide)
```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter SDK
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Packages externos (alfabético)
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

// 4. Imports locais (sempre package:app_sanitaria/)
import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/entities/user_entity.dart';
import 'package:app_sanitaria/domain/repositories/auth_repository.dart';

// ❌ NUNCA usar relative imports
// import '../../../domain/entities/user_entity.dart'; // ERRADO!
```

### Comandos de Organização
```bash
# Organizar imports automaticamente
flutter pub run import_sorter:main

# Adicionar import_sorter ao pubspec.yaml:
dev_dependencies:
  import_sorter: ^4.6.0
```

---

## 📝 DOCUMENTAÇÃO (DartDoc)

### Classes Públicas
```dart
/// Representa um usuário do sistema.
///
/// Esta entidade é imutável e contém todos os dados
/// essenciais de um usuário (paciente ou profissional).
///
/// Exemplo:
/// ```dart
/// final user = UserEntity(
///   id: '123',
///   nome: 'João',
///   email: 'joao@example.com',
///   tipo: UserType.paciente,
/// );
/// ```
class UserEntity extends Equatable {
  /// ID único do usuário (gerado automaticamente).
  final String id;
  
  /// Nome completo do usuário.
  final String nome;
  
  // ...
}
```

### Métodos Públicos
```dart
/// Autentica um usuário com email e senha.
///
/// Retorna [Right(UserEntity)] em caso de sucesso,
/// ou [Left(Failure)] em caso de erro.
///
/// Possíveis falhas:
/// - [ValidationFailure]: Email/senha inválidos
/// - [CacheFailure]: Erro ao acessar dados locais
/// - [ServerFailure]: Erro ao autenticar no servidor
///
/// Exemplo:
/// ```dart
/// final result = await authRepository.login(
///   email: 'user@example.com',
///   password: 'senha123',
/// );
/// result.fold(
///   (failure) => print('Erro: $failure'),
///   (user) => print('Logado: ${user.nome}'),
/// );
/// ```
Future<Either<Failure, UserEntity>> login({
  required String email,
  required String password,
});
```

---

## 🔧 PRE-COMMIT HOOKS

### Setup com Husky (Git Hooks)

#### 1. Instalar melos (monorepo tool)
```bash
dart pub global activate melos
```

#### 2. Criar `melos.yaml`
```yaml
name: app_sanitaria

packages:
  - .

scripts:
  analyze:
    exec: flutter analyze
  
  test:
    exec: flutter test
  
  format:
    exec: flutter format lib/ test/
  
  pre-commit:
    run: |
      melos run format &&
      melos run analyze &&
      melos run test
```

#### 3. Criar `.githooks/pre-commit`
```bash
#!/bin/sh

echo "🔍 Running pre-commit checks..."

# Format check
echo "📝 Checking formatting..."
if ! dart format --set-exit-if-changed lib/ test/; then
  echo "❌ Code is not formatted. Run 'dart format .'"
  exit 1
fi

# Analyze
echo "🔬 Running analysis..."
if ! flutter analyze --fatal-infos --fatal-warnings; then
  echo "❌ Analysis failed"
  exit 1
fi

# Tests
echo "🧪 Running tests..."
if ! flutter test; then
  echo "❌ Tests failed"
  exit 1
fi

echo "✅ All checks passed!"
exit 0
```

#### 4. Ativar hooks
```bash
chmod +x .githooks/pre-commit
git config core.hooksPath .githooks
```

---

## 🎯 FORMATAÇÃO AUTOMÁTICA

### VS Code Settings
```json
// .vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.formatOnType": true,
  "editor.rulers": [80],
  "editor.tabSize": 2,
  "dart.lineLength": 80,
  "dart.enableSdkFormatter": true,
  "dart.insertArgumentPlaceholders": false,
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code"
  },
  "dart.analysisExcludedFolders": [
    ".dart_tool",
    "build",
    ".fvm"
  ]
}
```

### EditorConfig
```ini
# .editorconfig
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.dart]
indent_style = space
indent_size = 2
max_line_length = 80

[*.{yaml,yml}]
indent_style = space
indent_size = 2

[*.{json,jsonc}]
indent_style = space
indent_size = 2
```

---

## ✅ CHECKLIST DE QUALIDADE

### Antes de Commit
- [ ] Código formatado (`dart format .`)
- [ ] Análise sem erros (`flutter analyze`)
- [ ] Testes passando (`flutter test`)
- [ ] Coverage >70% nas alterações
- [ ] Imports organizados (package imports)
- [ ] Documentação atualizada (DartDoc)
- [ ] TODOs/FIXMEs documentados
- [ ] Sem `print()` em produção (usar logger)
- [ ] Const constructors onde possível
- [ ] Null safety respeitado

### Antes de PR
- [ ] Branch atualizada com main
- [ ] Título descritivo do PR
- [ ] Descrição com contexto
- [ ] Screenshots (se UI)
- [ ] Linked issues
- [ ] Reviewers atribuídos
- [ ] Labels aplicados
- [ ] CI/CD passando

### Antes de Release
- [ ] Changelog atualizado
- [ ] Version bump (pubspec.yaml)
- [ ] Release notes escritas
- [ ] APK testado em device real
- [ ] Performance profiling
- [ ] Memory leaks verificados

---

## 📊 MÉTRICAS DE QUALIDADE

### Targets
| Métrica | Alvo | Como Medir |
|---------|------|------------|
| Linhas/arquivo | <300 | `find lib -name "*.dart" -exec wc -l {} +` |
| Complexidade ciclomática | <10 | Usar package `dart_code_metrics` |
| Coverage | >70% | `flutter test --coverage` |
| Warnings | 0 | `flutter analyze` |
| Duplicação | <5% | Usar `jscpd` |

### Comandos de Medição
```bash
# Complexidade
dart pub global activate dart_code_metrics
metrics lib -r github

# Coverage
flutter test --coverage
lcov --summary coverage/lcov.info

# Duplicação
npm install -g jscpd
jscpd lib
```

---

[◀️ Voltar ao Plano](./AUDITORIA_04_PLANO_REFATORACAO.md) | [Próximo: Exemplos ▶️](./AUDITORIA_06_EXEMPLOS.md)

