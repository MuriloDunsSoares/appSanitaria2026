# 🎯 PRÓXIMOS PASSOS - App Sanitária

**Data:** 13 de Outubro de 2025  
**Status:** ✅ Limpeza Concluída | 🧪 Testes Passando (82/82)

---

## ✅ O QUE JÁ FOI FEITO

- ✅ Arquitetura Clean Architecture implementada
- ✅ 137 arquivos Dart funcionais
- ✅ 82 testes unitários passando (100%)
- ✅ Firebase integrado (Auth, Firestore, Storage, Analytics, Crashlytics, Performance)
- ✅ Dependências atualizadas
- ✅ Repositório limpo (~936 MB removidos)
- ✅ Código no GitHub atualizado

---

## 📋 O QUE FAZER AGORA

### 🔴 **PRIORIDADE 1: Configuração do Ambiente**

#### 1.1 Configurar Firebase (OBRIGATÓRIO)
O app usa Firebase mas as credenciais precisam ser verificadas:

```bash
# Verificar se firebase_options.dart está correto
cat lib/firebase_options.dart

# Testar conexão Firebase (opcional - requer emulators)
# firebase emulators:start
```

**Ação:** Garantir que os arquivos de configuração Firebase estão corretos:
- ✅ `android/app/google-services.json`
- ✅ `ios/Runner/GoogleService-Info.plist`
- ✅ `lib/firebase_options.dart`

---

#### 1.2 Resolver Warnings do Flutter Doctor (OPCIONAL)

**Android:**
```bash
# Aceitar licenças Android
flutter doctor --android-licenses
```

**iOS (apenas se for desenvolver para iOS):**
```bash
# Instalar Xcode (Mac App Store)
# Instalar CocoaPods
sudo gem install cocoapods
cd ios && pod install
```

---

### 🟡 **PRIORIDADE 2: Melhorias de Código**

#### 2.1 Corrigir Warnings de Lint (RECOMENDADO)
Temos 764 issues de estilo (não críticos):

```bash
# Corrigir automaticamente
dart fix --apply

# Formatar código
dart format .
```

**Principais issues:**
- `prefer_const_constructors` (use const onde possível)
- `directives_ordering` (ordenar imports)
- `eol_at_end_of_file` (adicionar nova linha no final)
- `avoid_redundant_argument_values` (remover valores padrão)

---

#### 2.2 Atualizar Dependências (OPCIONAL)
41 pacotes têm versões mais recentes:

```bash
# Ver quais pacotes podem ser atualizados
flutter pub outdated

# Atualizar (CUIDADO: testar depois!)
flutter pub upgrade

# Rodar testes após atualizar
flutter test
```

**Nota:** Firebase tem versão major nova (v6). Avaliar se vale atualizar agora ou depois.

---

### 🟢 **PRIORIDADE 3: Desenvolvimento de Features**

#### 3.1 Features Já Implementadas (Backend + UI)
- ✅ Autenticação (Login, Registro, Logout)
- ✅ Perfis (Paciente e Profissional)
- ✅ Busca de Profissionais
- ✅ Favoritos
- ✅ Chat
- ✅ Contratos
- ✅ Avaliações (Reviews)

#### 3.2 Próximas Features Sugeridas

**Curto Prazo (1-2 semanas):**
1. **Tela de Onboarding** - Apresentação inicial do app
2. **Filtros Avançados** - Filtrar por preço, disponibilidade, distância
3. **Notificações Push** - Usar firebase_messaging para notificar novos chats/contratos
4. **Sistema de Busca** - Melhorar busca por nome, cidade, especialidade

**Médio Prazo (1-2 meses):**
1. **Sistema de Pagamento** - Integrar Stripe/PagSeguro
2. **Geolocalização** - Mostrar profissionais próximos no mapa
3. **Calendário** - Agendar horários de atendimento
4. **Upload de Documentos** - Certificados, documentos de profissionais

**Longo Prazo (3+ meses):**
1. **Sistema de Recomendação** - ML para sugerir profissionais
2. **Video Chamadas** - Integrar Agora/Twilio
3. **Multi-idioma** - Suporte para inglês/espanhol
4. **Dark Mode** - Tema escuro

---

### 🔧 **PRIORIDADE 4: DevOps e Qualidade**

#### 4.1 CI/CD (RECOMENDADO)
```bash
# Já existe script de auditoria
./tools/audit.sh

# Configurar GitHub Actions (opcional)
# Criar .github/workflows/flutter.yml
```

#### 4.2 Code Coverage
```bash
# Gerar relatório de cobertura
flutter test --coverage

# Visualizar (requer genhtml - macOS)
brew install lcov
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Meta:** Manter cobertura > 80%

---

#### 4.3 Testes de Integração
```bash
# Configurar Firebase Emulators
firebase init emulators

# Rodar testes de integração
flutter test test/integration/
```

**Nota:** Atualmente falham porque Firebase não está inicializado. Configurar emulators resolve.

---

### 📱 **PRIORIDADE 5: Build e Deploy**

#### 5.1 Build de Debug
```bash
# Android
flutter build apk --debug

# iOS (requer Mac + Xcode)
flutter build ios --debug
```

#### 5.2 Build de Release
```bash
# Android (PlayStore)
flutter build appbundle --release

# iOS (AppStore)
flutter build ipa --release
```

#### 5.3 Deploy
- **Android:** Google Play Console
- **iOS:** App Store Connect
- **Web:** Firebase Hosting (se houver versão web)

---

## 📊 MÉTRICAS ATUAIS

| Métrica | Valor | Status |
|---------|-------|--------|
| **Arquivos Dart** | 137 | ✅ |
| **Testes Unitários** | 82 (100%) | ✅ |
| **Testes de Integração** | 1 (falha config) | ⚠️ |
| **Cobertura de Testes** | ? (rodar coverage) | ❓ |
| **Warnings Lint** | 764 (não críticos) | ⚠️ |
| **Dependências** | 41 desatualizadas | ⚠️ |
| **Tamanho do Repo** | ~5 MB (após limpeza) | ✅ |

---

## 🎓 RECOMENDAÇÕES DE ARQUITETURA

### ✅ Mantidas (Boas Práticas)
- Clean Architecture (core/data/domain/presentation)
- Dependency Injection (GetIt)
- State Management (Riverpod)
- Error Handling (Either/Dartz)
- Repository Pattern
- Use Cases separados

### 🔄 Considerar Melhorar
1. **Logging:** Implementar sistema de logs estruturado (já tem Logger)
2. **Analytics:** Expandir eventos Firebase Analytics
3. **Error Tracking:** Garantir que Crashlytics captura todos erros
4. **Performance:** Monitorar tempos de carregamento
5. **Offline First:** Melhorar cache e sincronização offline

---

## 🚀 COMANDOS RÁPIDOS

```bash
# Rodar app
flutter run

# Rodar testes
flutter test

# Análise estática
flutter analyze

# Formatar código
dart format .

# Limpar build
flutter clean && flutter pub get

# Build APK debug
flutter build apk --debug

# Ver dependências desatualizadas
flutter pub outdated

# Gerar coverage
flutter test --coverage
```

---

## 📚 DOCUMENTAÇÃO ESSENCIAL

| Documento | Descrição |
|-----------|-----------|
| `README.md` | Documentação principal do projeto |
| `RELATORIO_LIMPEZA_ARQUIVOS.md` | Relatório da limpeza realizada |
| `PROXIMOS_PASSOS.md` | Este documento |
| `firestore.rules` | Regras de segurança Firebase |
| `pubspec.yaml` | Dependências do projeto |

---

## 🎯 PLANO DE AÇÃO SUGERIDO (Próximos 7 dias)

### Dia 1-2: Configuração
- [ ] Verificar credenciais Firebase
- [ ] Rodar `flutter doctor --android-licenses`
- [ ] Testar build: `flutter build apk --debug`
- [ ] Testar app em dispositivo/emulador real

### Dia 3-4: Qualidade de Código
- [ ] Rodar `dart fix --apply`
- [ ] Rodar `dart format .`
- [ ] Corrigir warnings críticos
- [ ] Gerar relatório de coverage

### Dia 5-6: Features
- [ ] Implementar Onboarding (primeira vez que abre)
- [ ] Melhorar tela de busca
- [ ] Adicionar loading states
- [ ] Testar fluxo completo (registro → busca → chat → contrato)

### Dia 7: Deploy
- [ ] Build de release
- [ ] Testar em múltiplos dispositivos
- [ ] Preparar para deploy (ícones, screenshots, descrição)

---

## ❓ DÚVIDAS FREQUENTES

**Q: O app funciona offline?**  
A: Parcialmente. Firebase tem cache offline habilitado, mas algumas operações requerem conexão.

**Q: Preciso configurar Firebase do zero?**  
A: Não. Os arquivos já existem. Apenas verifique se as credenciais estão corretas.

**Q: Como adicionar novos testes?**  
A: Siga o padrão dos testes existentes em `test/domain/usecases/`. Use mockito para mocks.

**Q: Posso atualizar Flutter/Dart?**  
A: Sim, mas teste tudo depois. Atual: Flutter 3.35.5 / Dart 3.9.2.

**Q: O que fazer com os arquivos .disabled?**  
A: São testes desabilitados temporariamente. Você pode reativar removendo a extensão `.disabled` e corrigir se necessário.

---

## 📞 PRÓXIMOS PASSOS IMEDIATOS

**Escolha UMA das opções abaixo para começar:**

### Opção A: Quero TESTAR o app agora
```bash
flutter run
# Se pedir dispositivo: flutter emulators --launch <nome>
```

### Opção B: Quero CORRIGIR warnings de código
```bash
dart fix --apply
dart format .
git add .
git commit -m "style: Corrigir warnings de lint"
git push
```

### Opção C: Quero DESENVOLVER nova feature
1. Escolha uma feature da lista acima
2. Crie uma branch: `git checkout -b feature/nome-da-feature`
3. Desenvolva seguindo a arquitetura existente
4. Escreva testes
5. Faça commit e push

### Opção D: Quero FAZER BUILD para testar em dispositivo real
```bash
flutter build apk --debug
# APK estará em: build/app/outputs/flutter-apk/app-debug.apk
```

---

**🎉 Projeto está limpo, organizado e pronto para desenvolvimento!**

**Próximo passo:** Escolha uma das opções acima e continue o desenvolvimento.

---

**Gerado automaticamente após limpeza do repositório**  
*Atualizado em: 13 de Outubro de 2025*

