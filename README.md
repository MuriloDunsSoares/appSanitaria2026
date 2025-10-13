# 🏥 App Sanitária

Aplicação mobile para conectar **profissionais de saúde domiciliar** com **pacientes** que precisam de cuidados.

---

## 📱 Sobre o Projeto

O App Sanitária facilita a busca e contratação de profissionais de saúde para cuidados domiciliares, incluindo:
- 👴 **Cuidadores** de idosos
- 💉 **Técnicos de enfermagem**
- 🏥 **Acompanhantes hospitalares**
- 🏠 **Acompanhantes domiciliares**

---

## 🏗️ Arquitetura

Este projeto segue **Clean Architecture** com as seguintes camadas:

```
lib/
├── core/                  # Funcionalidades compartilhadas
│   ├── constants/        # Constantes, temas, configs
│   ├── errors/           # Tratamento de erros
│   └── utils/            # Funções utilitárias
│
├── data/                  # Camada de dados
│   ├── models/           # Models (JSON ↔ Dart)
│   ├── repositories/     # Implementação de repositories
│   └── datasources/      # Fontes de dados (API, local)
│
├── domain/                # Regras de negócio
│   ├── entities/         # Entidades do domínio
│   └── usecases/         # Casos de uso
│
└── presentation/          # Interface do usuário
    ├── screens/          # Telas completas
    ├── widgets/          # Componentes reutilizáveis
    └── providers/        # State management (Riverpod)
```

---

## 🛠️ Tecnologias

- **Flutter** 3.35.5
- **Dart** 3.9.2
- **Riverpod** (State Management)
- **Equatable** (Value Equality)
- **Dartz** (Functional Programming)
- **Shared Preferences** (Local Storage)

---

## 🚀 Como Rodar

### Pré-requisitos
- Flutter SDK instalado
- Android Studio / Xcode (para emuladores)
- Emulador Android ou dispositivo físico

### Comandos

```bash
# Instalar dependências
flutter pub get

# Rodar no emulador/dispositivo
flutter run

# Build para produção (Android)
flutter build apk --release

# Build para produção (iOS)
flutter build ios --release
```

---

## 📂 Status do Projeto

### ✅ Concluído
- [x] Estrutura de pastas (Clean Architecture)
- [x] Entidades do domínio (User, Professional, Patient)
- [x] Constantes e temas
- [x] Configuração de dependências

### 🚧 Em Desenvolvimento
- [ ] Tela de Login
- [ ] Tela Home (pacientes)
- [ ] Lista de Profissionais
- [ ] Sistema de busca e filtros
- [ ] Perfil de profissional
- [ ] Sistema de chat
- [ ] Favoritos

### 📅 Futuro
- [ ] Backend API (Node.js / Firebase)
- [ ] Autenticação com JWT
- [ ] Push Notifications
- [ ] Sistema de pagamento
- [ ] Avaliações e reviews
- [ ] Geolocalização

---

## 🎨 Design

O design segue Material Design 3 com paleta de cores personalizada:
- **Primary:** `#667EEA` (roxo)
- **Secondary:** `#2196F3` (azul)
- **Background:** `#F8F9FA` (cinza claro)

---

## 👥 Tipos de Usuário

### Profissional
- Cadastro com especialidade
- Perfil com experiência e certificados
- Avaliação por pacientes
- Filtro por cidade e especialidade

### Paciente
- Busca de profissionais
- Filtros avançados
- Sistema de favoritos
- Chat com profissionais
- Avaliação de serviços

---

## 📝 Convenções de Código

- **Classes:** PascalCase (`UserEntity`)
- **Arquivos:** snake_case (`user_entity.dart`)
- **Variáveis:** camelCase (`userName`)
- **Constantes:** camelCase com `const` ou `static const`
- **Privados:** prefixo `_` (`_privateMethod`)

### Commits
- `feat:` Nova funcionalidade
- `fix:` Correção de bug
- `refactor:` Refatoração de código
- `docs:` Documentação
- `test:` Testes
- `style:` Formatação

---

## 🧪 Testes

```bash
# Rodar todos os testes
flutter test

# Testes com coverage
flutter test --coverage

# Ver coverage no navegador
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📄 Licença

Este projeto é privado e confidencial.

---

## 👨‍💻 Desenvolvedor

Migrado de HTML/CSS/JS para Flutter/Dart seguindo as melhores práticas de Clean Architecture e SOLID principles.
