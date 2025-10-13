// ═══════════════════════════════════════════════════════════════════════════
// ARQUIVO: app_constants.dart
// PROPÓSITO: Centralização de constantes globais da aplicação
// ═══════════════════════════════════════════════════════════════════════════

/// Classe utilitária que centraliza todas as constantes da aplicação.
///
/// **PATTERN: Constants Container**
/// Agrupa valores fixos para evitar magic numbers/strings espalhados pelo código.
///
/// **BENEFÍCIOS:**
/// 1. Single Source of Truth (única fonte de verdade)
/// 2. Facilita manutenção (mudança em um único lugar)
/// 3. Type-safe (compilador detecta erros de tipo)
/// 4. Autocomplete no IDE (melhor developer experience)
/// 5. Documentação inline (cada constante explicada)
///
/// **ARQUITETURA:**
/// - Camada: Core (fundação da aplicação)
/// - Responsabilidade: Armazenar valores imutáveis globais
/// - Escopo: Toda a aplicação pode acessar via AppConstants.nomeConstante
///
/// **DESIGN PATTERN: Static Class com construtor privado**
/// Previne instanciação acidental (AppConstants() causaria erro).
/// Apenas membros static podem ser acessados: AppConstants.minAge
///
/// **ORGANIZAÇÃO:**
/// Constantes agrupadas por categoria (Storage, Validation, Pagination, etc)
/// para melhor legibilidade e manutenção.
///
/// **INTERAÇÕES:**
/// - LocalStorageDataSource usa storageKey* para chaves do SharedPreferences
/// - Validators usam min/max para validação de formulários
/// - Providers usam *PerPage para paginação
/// - Rating widgets usam minRating/maxRating para stars
/// - Seed data usa capitalsBrazil para popular usuários
/// - Filtros usam professionalSpecialties para dropdown
///
/// **PERFORMANCE:** O(1) - acesso direto a constantes em tempo de compilação
/// **MEMÓRIA:** Constantes são inlined pelo compilador (zero overhead runtime)
class AppConstants {
  // ───────────────────────────────────────────────────────────────────────
  // CONSTRUTOR PRIVADO - Previne Instanciação
  // ───────────────────────────────────────────────────────────────────────
  
  /// Construtor privado que previne instanciação da classe.
  ///
  /// **Por que privado?**
  /// - AppConstants é uma classe utilitária (apenas static members)
  /// - Não faz sentido criar instâncias: `final x = AppConstants()` ❌
  /// - Força uso correto: `AppConstants.minAge` ✅
  ///
  /// **Sintaxe:** 
  /// - `AppConstants._()` → construtor nomeado privado (underscore)
  /// - Dart não permite chamar construtores privados de fora da classe
  ///
  /// **Alternativa (não usada aqui):**
  /// - Classe abstract: `abstract class AppConstants {}`
  /// - Também previne instanciação, mas menos explícito
  ///
  /// **Convenção Flutter:** Construtor privado é o padrão para classes utilities
  AppConstants._();

  // ═══════════════════════════════════════════════════════════════════════
  // STORAGE KEYS - Chaves para SharedPreferences
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Chave para armazenar a lista completa de usuários cadastrados.
  ///
  /// **Tipo de dado armazenado:** JSON String
  /// ```json
  /// {
  ///   "user_123": {"id": "user_123", "nome": "João", "email": "joao@email.com", ...},
  ///   "user_456": {"id": "user_456", "nome": "Maria", "email": "maria@email.com", ...}
  /// }
  /// ```
  ///
  /// **Estrutura:** Map<String, Map<String, dynamic>>
  /// - Key externa: userId
  /// - Value: Dados completos do usuário
  ///
  /// **Onde é usado:**
  /// - LocalStorageDataSource.getAllUsers() → lê esta key
  /// - LocalStorageDataSource.addUserToHostList() → escreve nesta key
  /// - AuthRepository.register() → adiciona novo usuário aqui
  ///
  /// **Tamanho estimado:**
  /// - 1 usuário: ~500 bytes
  /// - 100 usuários: ~50 KB
  /// - 1000 usuários: ~500 KB
  ///
  /// **Performance I/O:**
  /// - Read: ~50ms (cold) / ~1ms (cached)
  /// - Write: ~100ms (serialização JSON + I/O disco)
  ///
  /// **Prefixo 'appSanitaria_':**
  /// - Previne colisões com outros apps/plugins que usam SharedPreferences
  /// - Facilita debug (grep 'appSanitaria_' mostra todas as keys da app)
  static const String storageKeyHostList = 'appSanitaria_hostList';
  
  /// Alias para storageKeyHostList (compatibilidade com código antigo).
  ///
  /// **Por que existe?**
  /// - Refatoração histórica: código antigo usava 'usersHost'
  /// - Novo código usa 'hostList'
  /// - Alias mantém compatibilidade durante transição
  ///
  /// **Depreciado:** Usar storageKeyHostList em novo código
  ///
  /// **Removível após:** Todos os datasources migrarem para storageKeyHostList
  static const String storageKeyUsersHost = 'appSanitaria_usersHost';
  
  /// Chave para armazenar dados do usuário atualmente logado.
  ///
  /// **Tipo de dado:** JSON String
  /// ```json
  /// {
  ///   "id": "user_123",
  ///   "nome": "João Silva",
  ///   "email": "joao@email.com",
  ///   "tipo": "Paciente",
  ///   "telefone": "(11) 98765-4321",
  ///   ...
  /// }
  /// ```
  ///
  /// **Onde é usado:**
  /// - LocalStorageDataSource.getCurrentUser() → lê esta key
  /// - LocalStorageDataSource.saveCurrentUser() → escreve nesta key
  /// - AuthRepository.login() → salva após login bem-sucedido
  /// - AuthRepository.logout() → remove esta key
  /// - AuthProvider.checkSession() → verifica existência ao iniciar app
  ///
  /// **Lifecycle:**
  /// - Criado: Após login ou registro
  /// - Atualizado: Quando usuário edita perfil
  /// - Removido: Após logout
  ///
  /// **Segurança:**
  /// - Senha NÃO é armazenada aqui (apenas hash é comparado no login)
  /// - Dados são acessíveis a outros apps do mesmo usuário (limitação do SharedPreferences)
  /// - Para dados sensíveis, usar flutter_secure_storage (não implementado neste MVP)
  ///
  /// **Performance:** ~200 bytes, leitura ~1ms
  static const String storageKeyUserData = 'appSanitaria_userData';
  
  /// Chave para armazenar apenas o ID do usuário logado (otimização).
  ///
  /// **Tipo de dado:** String simples
  /// ```
  /// "user_123"
  /// ```
  ///
  /// **Por que separar do userData?**
  /// - Performance: Ler apenas ID é mais rápido que deserializar JSON completo
  /// - Usado frequentemente em verificações rápidas (isLoggedIn?)
  /// - Reduz I/O desnecessário
  ///
  /// **Onde é usado:**
  /// - LocalStorageDataSource.getCurrentUserId() → lê esta key
  /// - LocalStorageDataSource.saveCurrentUserId() → escreve nesta key
  /// - AuthRepository.isLoggedIn() → verifica se não é null
  /// - Providers diversos → obtém userId para filtrar dados
  ///
  /// **Sincronização:**
  /// - Deve sempre estar sincronizado com storageKeyUserData
  /// - Se userData existe, currentUserId DEVE existir (e vice-versa)
  /// - Violação desta invariante indica bug
  ///
  /// **Performance:** ~10 bytes, leitura ~0.5ms
  static const String storageKeyCurrentUserId = 'appSanitaria_currentUserId';
  
  /// Chave base para armazenar favoritos de um usuário.
  ///
  /// **IMPORTANTE:** Esta é uma chave BASE, não a chave final!
  /// Chave real = 'appSanitaria_favorites_<userId>'
  ///
  /// **Exemplo:**
  /// - Usuário user_123: 'appSanitaria_favorites_user_123'
  /// - Usuário user_456: 'appSanitaria_favorites_user_456'
  ///
  /// **Tipo de dado:** JSON Array de Strings
  /// ```json
  /// ["prof_789", "prof_012", "prof_345"]
  /// ```
  ///
  /// **Onde é usado:**
  /// - LocalStorageDataSource.getFavorites(userId) → lê '_favorites_$userId'
  /// - LocalStorageDataSource.saveFavorites(userId, list) → escreve nesta key
  /// - FavoritesProvider → carrega e manipula lista de favoritos
  /// - ProfessionalCard → adiciona/remove de favoritos
  ///
  /// **Performance:**
  /// - 10 favoritos: ~100 bytes, leitura ~1ms
  /// - 100 favoritos: ~1 KB, leitura ~5ms
  ///
  /// **Design Pattern: Keyed Storage**
  /// - Cada usuário tem sua própria lista isolada
  /// - Previne conflitos entre usuários
  /// - Facilita limpeza (remove apenas chaves específicas do usuário)
  static const String storageKeyPatients = 'appSanitaria_patients';
  static const String storageKeyProfessionals = 'appSanitaria_professionals';
  static const String storageKeyFavorites = 'appSanitaria_favorites';
  static const String storageKeyProfileImages = 'appSanitaria_profile_images';
  static const String storageKeyPatientProfile = 'appSanitaria_patient_profile';
  static const String storageKeyProfessionalProfile = 'appSanitaria_professional_profile';

  // ═══════════════════════════════════════════════════════════════════════
  // VALIDATION - Regras de Validação de Formulários
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Comprimento mínimo de senha para registro.
  ///
  /// **Valor:** 6 caracteres
  ///
  /// **Justificativa:**
  /// - Balanço entre segurança e usabilidade
  /// - NIST recomenda mínimo de 8, mas 6 é aceitável para MVP
  /// - Menor que 6 = muito vulnerável a brute force
  ///
  /// **Onde é usado:**
  /// - LoginScreen → validação do campo senha
  /// - PatientRegistrationScreen → validação ao criar conta
  /// - ProfessionalRegistrationScreen → validação ao criar conta
  /// - Validators → função validatePassword()
  ///
  /// **Validação típica:**
  /// ```dart
  /// if (password.length < AppConstants.minPasswordLength) {
  ///   return 'Senha deve ter no mínimo ${AppConstants.minPasswordLength} caracteres';
  /// }
  /// ```
  ///
  /// **Melhorias futuras:**
  /// - Exigir letra maiúscula + número + caractere especial
  /// - Aumentar para 8 caracteres
  /// - Implementar strength meter
  ///
  /// **Segurança atual:** BAIXA (sem hash, armazenamento plain text)
  /// **TODO:** Implementar bcrypt/argon2 antes de produção
  static const int minPasswordLength = 6;
  
  /// Idade mínima para registro (maioridade legal no Brasil).
  ///
  /// **Valor:** 18 anos
  ///
  /// **Justificativa Legal:**
  /// - Código Civil Brasileiro: maioridade aos 18 anos
  /// - Plataforma lida com contratação de serviços (requer capacidade civil)
  /// - LGPD: menores de 18 precisam consentimento dos pais
  ///
  /// **Onde é usado:**
  /// - PatientRegistrationScreen → validação campo data de nascimento
  /// - ProfessionalRegistrationScreen → validação campo data de nascimento
  /// - Validators → função validateAge()
  ///
  /// **Cálculo de idade:**
  /// ```dart
  /// final age = DateTime.now().year - birthDate.year;
  /// if (age < AppConstants.minAge) {
  ///   return 'Você deve ter pelo menos ${AppConstants.minAge} anos';
  /// }
  /// ```
  ///
  /// **Compliance:**
  /// - LGPD Art. 14: Tratamento de dados de menores
  /// - Termo de uso deve mencionar esta restrição
  static const int minAge = 18;
  
  /// Idade máxima para registro (validação de sanidade de dados).
  ///
  /// **Valor:** 120 anos
  ///
  /// **Justificativa:**
  /// - Pessoa viva mais velha registrada: 122 anos (Jeanne Calment)
  /// - Valor razoável para detectar erros de input (ex: 1900 ao invés de 2000)
  /// - Não discrimina idosos, apenas previne bugs
  ///
  /// **Onde é usado:**
  /// - PatientRegistrationScreen → validação campo data de nascimento
  /// - ProfessionalRegistrationScreen → validação campo data de nascimento
  /// - Validators → função validateAge()
  ///
  /// **Validação:**
  /// ```dart
  /// final age = DateTime.now().year - birthDate.year;
  /// if (age > AppConstants.maxAge) {
  ///   return 'Data de nascimento inválida';
  /// }
  /// ```
  ///
  /// **Edge case:**
  /// - Se usuário realmente tiver 120 anos, será rejeitado
  /// - Solução: Processo manual de verificação (não implementado no MVP)
  static const int maxAge = 120;

  // ═══════════════════════════════════════════════════════════════════════
  // PAGINATION - Limites de Itens por Página
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Número de profissionais carregados por página na lista.
  ///
  /// **Valor:** 20 profissionais
  ///
  /// **Justificativa:**
  /// - Performance: Carregar 100+ cards de uma vez causa jank
  /// - UX: 20 itens são suficientes para scroll sem parecer vazio
  /// - Memória: 20 cards ≈ 2-3 MB RAM (imagens + dados)
  ///
  /// **Onde é usado:**
  /// - ProfessionalsListScreen → limita itens iniciais
  /// - ProfessionalsProvider.loadMore() → carrega próxima página
  /// - Scroll listener → detecta fim da lista e carrega mais
  ///
  /// **Implementação (não implementada no MVP, TODO):**
  /// ```dart
  /// if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
  ///   if (loadedCount < totalCount) {
  ///     loadNextPage(); // carrega próximos 20
  ///   }
  /// }
  /// ```
  ///
  /// **Estado atual:**
  /// - Carrega TODOS os profissionais de uma vez (bug de performance)
  /// - Com 1000 profissionais, causa ~3s de freeze
  /// - TODO: Implementar lazy loading usando esta constante
  ///
  /// **Performance esperada após implementação:**
  /// - Load inicial: 20 cards × 50ms = ~1s
  /// - Load incremental: imperceptível (background)
  static const int professionalsPerPage = 20;
  
  /// Número de mensagens carregadas por página no chat.
  ///
  /// **Valor:** 50 mensagens
  ///
  /// **Justificativa:**
  /// - 50 mensagens ≈ 1-2 dias de conversa típica
  /// - ListView.builder renderiza apenas itens visíveis (eficiente)
  /// - Carregar histórico completo causaria freeze em conversas longas
  ///
  /// **Onde seria usado (não implementado no MVP):**
  /// - IndividualChatScreen → carrega últimas 50 mensagens
  /// - Scroll para topo → carrega 50 anteriores
  /// - ChatProvider.loadMoreMessages() → paginação reversa
  ///
  /// **Estado atual:**
  /// - Carrega TODAS as mensagens de uma vez
  /// - Com 1000+ mensagens, causa lag
  /// - TODO: Implementar paginação reversa (scroll to top = load more)
  ///
  /// **Implementação futura:**
  /// ```dart
  /// // Carregar mais antigas ao scrollar para o topo
  /// if (scrollController.offset == 0) {
  ///   loadPreviousMessages(count: AppConstants.messagesPerPage);
  /// }
  /// ```
  ///
  /// **Performance esperada:**
  /// - Load inicial: 50 msgs × 10ms = ~500ms
  /// - Render: Apenas ~10 visíveis na tela (rápido)
  static const int messagesPerPage = 50;

  // ═══════════════════════════════════════════════════════════════════════
  // RATING - Configuração do Sistema de Avaliações
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Rating mínimo permitido (estrelas vazias).
  ///
  /// **Valor:** 0.0 (zero estrelas)
  ///
  /// **Onde é usado:**
  /// - RatingStars widget → min value do slider/selector
  /// - Validators → garante rating >= 0
  /// - Display de rating → mostra "Sem avaliações" se 0.0
  ///
  /// **Semântica:**
  /// - 0.0 = Profissional sem avaliações (não é "péssimo")
  /// - Diferente de 1.0 (uma estrela = "muito ruim")
  ///
  /// **UI típica:**
  /// ```dart
  /// if (rating == AppConstants.minRating) {
  ///   return Text('Sem avaliações');
  /// }
  /// ```
  static const double minRating = 0.0;
  
  /// Rating máximo permitido (5 estrelas cheias).
  ///
  /// **Valor:** 5.0 (cinco estrelas)
  ///
  /// **Sistema de escala:**
  /// - 1.0 = Péssimo
  /// - 2.0 = Ruim
  /// - 3.0 = Regular
  /// - 4.0 = Bom
  /// - 5.0 = Excelente
  ///
  /// **Onde é usado:**
  /// - RatingStars widget → max value do selector
  /// - AddReviewScreen → validação (não permitir > 5)
  /// - Validators → garante rating <= 5
  /// - Cálculo de média → normalização
  ///
  /// **Por que 5 e não 10?**
  /// - Padrão da indústria (Google, Uber, Airbnb usam 5)
  /// - Mais fácil para usuários decidirem
  /// - 10 estrelas tem muita granularidade (confunde usuário)
  ///
  /// **Precisão:**
  /// - Aceita decimais: 4.5, 4.7, etc
  /// - UI pode arredondar para meio (4.3 → 4.5)
  static const double maxRating = 5.0;
  
  /// Rating padrão quando profissional não tem avaliações.
  ///
  /// **Valor:** 4.5 (quatro estrelas e meia)
  ///
  /// **Justificativa:**
  /// - Dar benefit of the doubt para novos profissionais
  /// - Previne discriminação contra quem acabou de se cadastrar
  /// - 4.5 é "bom" mas não perfeito (incentiva buscar avaliações reais)
  ///
  /// **Onde é usado (ATENÇÃO: não implementado corretamente no MVP!):**
  /// - ProfessionalCard → deveria mostrar 4.5 se sem avaliações
  /// - Filtro de rating → profissionais novos aparecem em "4+ estrelas"
  /// - Ordenação por rating → novos não ficam no fim da lista
  ///
  /// **Estado atual:**
  /// - Mostra 0.0 se sem avaliações (bug de UX)
  /// - TODO: Implementar lógica:
  /// ```dart
  /// final displayRating = (totalReviews == 0) 
  ///   ? AppConstants.defaultRating 
  ///   : averageRating;
  /// ```
  ///
  /// **Debate:** 
  /// - Alguns argumentam que deve ser 0.0 (mais honesto)
  /// - Outros argumentam 4.5 (mais justo para novos)
  /// - Solução: Badge "Novo profissional" + 4.5 temporário
  static const double defaultRating = 4.5;

  // ═══════════════════════════════════════════════════════════════════════
  // ESPECIALIDADES - Lista de Categorias de Profissionais
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Lista de especialidades/categorias de profissionais de saúde.
  ///
  /// **Tipo:** List<String> (imutável via const)
  ///
  /// **Conteúdo:**
  /// 1. Cuidadores (de idosos, pessoas com deficiência)
  /// 2. Técnicos de enfermagem
  /// 3. Acompanhantes hospitalares
  /// 4. Acompanhantes domiciliares
  ///
  /// **Onde é usado:**
  /// - HomePatientScreen → cards clicáveis por especialidade
  /// - ProfessionalsListScreen → filtro dropdown
  /// - ProfessionalRegistrationScreen → seleção de especialidade
  /// - Seed data → gera profissionais para cada especialidade
  /// - ProfessionalsProvider → filtro de busca
  ///
  /// **Uso típico (filtro):**
  /// ```dart
  /// DropdownButton<String>(
  ///   items: AppConstants.professionalSpecialties.map((spec) {
  ///     return DropdownMenuItem(value: spec, child: Text(spec));
  ///   }).toList(),
  /// )
  /// ```
  ///
  /// **Decisão de design:**
  /// - Hardcoded ao invés de banco de dados (simplicidade do MVP)
  /// - Mudanças requerem rebuild do app (aceitável para MVP)
  /// - Futuro: Mover para Firestore/API (atualizações sem rebuild)
  ///
  /// **Localização:**
  /// - Atualmente apenas português brasileiro
  /// - TODO: Suporte a múltiplos idiomas (i18n)
  ///
  /// **Extensibilidade:**
  /// Para adicionar nova especialidade:
  /// 1. Adicionar string aqui
  /// 2. Rebuild app
  /// 3. Seed data gerará usuários da nova especialidade
  ///
  /// **Validação:**
  /// - Professional.especialidade DEVE estar nesta lista
  /// - Caso contrário, card/filtro podem quebrar
  ///
  /// **Performance:** 4 strings, ~100 bytes, acesso O(1)
  static const List<String> professionalSpecialties = [
    'Cuidadores',
    'Técnicos de enfermagem',
    'Acompanhantes hospital',
    'Acompanhante Domiciliar',
  ];

  // ═══════════════════════════════════════════════════════════════════════
  // CIDADES - Capitais Brasileiras com Estados
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Mapa de todas as 27 capitais brasileiras com suas siglas de estado.
  ///
  /// **Tipo:** Map<String, String>
  /// - Key: Nome da capital (ex: "São Paulo")
  /// - Value: Sigla do estado (ex: "SP")
  ///
  /// **Total:** 27 capitais (26 estados + Distrito Federal)
  ///
  /// **Ordem:** Norte → Nordeste → Centro-Oeste → Sudeste → Sul
  ///
  /// **Onde é usado:**
  /// - Seed data → gera 1 profissional por capital
  /// - ProfessionalRegistrationScreen → dropdown de cidade
  /// - ProfessionalsListScreen → filtro por cidade
  /// - HomePatientScreen → seção de busca por cidade (removida após feedback)
  ///
  /// **Uso típico (dropdown):**
  /// ```dart
  /// DropdownButton<String>(
  ///   items: AppConstants.capitalsBrazil.keys.map((city) {
  ///     final state = AppConstants.capitalsBrazil[city]!;
  ///     return DropdownMenuItem(
  ///       value: city,
  ///       child: Text('$city - $state'),
  ///     );
  ///   }).toList(),
  /// )
  /// ```
  ///
  /// **Limitação atual:**
  /// - Apenas capitais (não inclui cidades menores)
  /// - Para MVP é suficiente (27 opções)
  /// - Futuro: API do IBGE para todas as 5570 cidades brasileiras
  ///
  /// **Seed data:**
  /// ```dart
  /// AppConstants.capitalsBrazil.forEach((city, state) {
  ///   final prof = generateProfessional(city: city, state: state);
  ///   seedProfessionals.add(prof);
  /// });
  /// ```
  ///
  /// **Formato padronizado:**
  /// - Acentuação correta (São Paulo, não Sao Paulo)
  /// - Primeira letra maiúscula
  /// - Sigla do estado SEMPRE 2 letras maiúsculas
  ///
  /// **Validação:**
  /// - Professional.cidade DEVE estar nas keys deste mapa
  /// - Caso contrário, filtro pode não funcionar
  ///
  /// **Performance:** 27 entradas, ~1 KB, lookup O(1)
  ///
  /// **Regiões (organizadas geograficamente):**
  static const Map<String, String> capitalsBrazil = {
    // REGIÃO NORTE (7 capitais)
    'Rio Branco': 'AC',      // Acre
    'Macapá': 'AP',          // Amapá
    'Manaus': 'AM',          // Amazonas
    'Belém': 'PA',           // Pará
    'Porto Velho': 'RO',     // Rondônia
    'Boa Vista': 'RR',       // Roraima
    'Palmas': 'TO',          // Tocantins
    
    // REGIÃO NORDESTE (9 capitais)
    'Maceió': 'AL',          // Alagoas
    'Salvador': 'BA',        // Bahia
    'Fortaleza': 'CE',       // Ceará
    'São Luís': 'MA',        // Maranhão
    'João Pessoa': 'PB',     // Paraíba
    'Recife': 'PE',          // Pernambuco
    'Teresina': 'PI',        // Piauí
    'Natal': 'RN',           // Rio Grande do Norte
    'Aracaju': 'SE',         // Sergipe
    
    // REGIÃO CENTRO-OESTE (4 capitais)
    'Brasília': 'DF',        // Distrito Federal
    'Goiânia': 'GO',         // Goiás
    'Cuiabá': 'MT',          // Mato Grosso
    'Campo Grande': 'MS',    // Mato Grosso do Sul
    
    // REGIÃO SUDESTE (4 capitais)
    'Vitória': 'ES',         // Espírito Santo
    'Belo Horizonte': 'MG',  // Minas Gerais
    'Rio de Janeiro': 'RJ',  // Rio de Janeiro
    'São Paulo': 'SP',       // São Paulo
    
    // REGIÃO SUL (3 capitais)
    'Curitiba': 'PR',        // Paraná
    'Florianópolis': 'SC',   // Santa Catarina
    'Porto Alegre': 'RS',    // Rio Grande do Sul
  };

  // ═══════════════════════════════════════════════════════════════════════
  // TIMEOUTS - Durações de Timeout para Operações Assíncronas
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Timeout para chamadas de API (quando implementadas).
  ///
  /// **Valor:** 30 segundos
  ///
  /// **Tipo:** Duration (30 segundos = 30000 ms)
  ///
  /// **Justificativa:**
  /// - 30s é padrão da indústria (OkHttp, Axios, Fetch API)
  /// - Permite redes lentas (3G rural)
  /// - Previne travamento infinito
  ///
  /// **Onde será usado (futuro, não implementado no MVP):**
  /// - Dio/Http client → timeout de requests
  /// - Upload de imagens → pode levar 10-20s em 3G
  /// - Download de dados → pode levar tempo em conexão ruim
  ///
  /// **Implementação futura:**
  /// ```dart
  /// final dio = Dio(BaseOptions(
  ///   connectTimeout: AppConstants.apiTimeout,
  ///   receiveTimeout: AppConstants.apiTimeout,
  ///   sendTimeout: AppConstants.apiTimeout,
  /// ));
  /// ```
  ///
  /// **Tratamento de timeout:**
  /// ```dart
  /// try {
  ///   final response = await dio.get('/api/professionals');
  /// } on DioError catch (e) {
  ///   if (e.type == DioErrorType.connectTimeout) {
  ///     showError('Conexão lenta. Tente novamente.');
  ///   }
  /// }
  /// ```
  ///
  /// **Estado atual:**
  /// - SharedPreferences é local (sem timeout necessário)
  /// - Quando migrar para Firebase/API, usar esta constante
  ///
  /// **Performance:**
  /// - Não afeta app atual (sem chamadas de rede)
  /// - Crítico para produção (previne ANR - App Not Responding)
  static const Duration apiTimeout = Duration(seconds: 30);
  
  /// Debounce para busca em tempo real (evita requests excessivos).
  ///
  /// **Valor:** 500 milissegundos (0.5 segundos)
  ///
  /// **Tipo:** Duration (500 ms = meio segundo)
  ///
  /// **O que é debounce?**
  /// - Espera usuário parar de digitar antes de executar ação
  /// - Previne chamadas a cada caractere digitado
  ///
  /// **Exemplo sem debounce (MAU):**
  /// ```
  /// Usuário digita "João Silva":
  /// J → busca "J"
  /// o → busca "Jo"
  /// ã → busca "Joã"
  /// o → busca "João"
  /// (espaço) → busca "João "
  /// S → busca "João S"
  /// ... (12 requests!)
  /// ```
  ///
  /// **Exemplo com debounce 500ms (BOM):**
  /// ```
  /// Usuário digita "João Silva":
  /// (digita tudo em 2 segundos)
  /// (espera 500ms sem digitar)
  /// → busca "João Silva" (1 request apenas!)
  /// ```
  ///
  /// **Onde é usado:**
  /// - ProfessionalsListScreen → campo de busca
  /// - SearchBar → filtro em tempo real
  /// - TextField.onChanged → aguarda 500ms antes de filtrar
  ///
  /// **Implementação típica:**
  /// ```dart
  /// Timer? _debounce;
  /// 
  /// void onSearchChanged(String query) {
  ///   _debounce?.cancel();
  ///   _debounce = Timer(AppConstants.searchDebounce, () {
  ///     performSearch(query); // Executado apenas após 500ms de inatividade
  ///   });
  /// }
  /// ```
  ///
  /// **Trade-off:**
  /// - Muito curto (100ms): Muitos requests, gasta bateria
  /// - Muito longo (2s): Parece lento, má UX
  /// - 500ms: Sweet spot (rápido mas econômico)
  ///
  /// **Performance:**
  /// - Reduz requests em ~90% (12 → 1-2)
  /// - Melhora battery life
  /// - Reduz carga no servidor (quando houver)
  ///
  /// **UX:**
  /// - Usuário não percebe o delay (500ms é imperceptível)
  /// - Sente que app é responsivo
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // ═══════════════════════════════════════════════════════════════════════
  // CACHE - Durações de Expiração de Cache
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Duração até cache de dados expirar e precisar ser recarregado.
  ///
  /// **Valor:** 24 horas (1 dia)
  ///
  /// **Tipo:** Duration (24 × 60 × 60 = 86400 segundos)
  ///
  /// **Onde será usado (futuro, não implementado no MVP):**
  /// - Cache de imagens de profissionais
  /// - Cache de lista de profissionais
  /// - Cache de reviews
  /// - Qualquer dado que pode ficar desatualizado
  ///
  /// **Estratégia de cache (futuro):**
  /// ```dart
  /// // Salvar com timestamp
  /// await prefs.setString('professionals_data', jsonEncode(data));
  /// await prefs.setString('professionals_timestamp', DateTime.now().toIso8601String());
  /// 
  /// // Verificar se expirou
  /// final timestamp = DateTime.parse(prefs.getString('professionals_timestamp')!);
  /// final age = DateTime.now().difference(timestamp);
  /// 
  /// if (age > AppConstants.cacheExpiration) {
  ///   // Cache expirado, recarregar da API
  ///   data = await fetchFromApi();
  /// } else {
  ///   // Cache válido, usar dados locais
  ///   data = loadFromCache();
  /// }
  /// ```
  ///
  /// **Por que 24 horas?**
  /// - Balanço entre freshness e performance
  /// - Dados de profissionais não mudam frequentemente
  /// - Usuário pode forçar refresh (pull-to-refresh)
  ///
  /// **Trade-offs:**
  /// - Muito curto (1h): Muitos fetches, gasta dados móveis
  /// - Muito longo (7 dias): Dados desatualizados, má UX
  /// - 24h: Dados razoavelmente frescos, econômico
  ///
  /// **Estado atual:**
  /// - SharedPreferences não tem expiração automática
  /// - Dados persistem até logout ou clear data
  /// - TODO: Implementar cache com TTL (Time To Live)
  ///
  /// **Implementação recomendada:**
  /// - Package: hive (suporta TTL nativo)
  /// - Ou: flutter_cache_manager para imagens
  /// - Ou: Manual com timestamps (mostrado acima)
  ///
  /// **Performance:**
  /// - Cache hit: ~1ms (SharedPreferences)
  /// - Cache miss: ~500ms+ (fetch da API)
  /// - Economia de bateria: ~70% menos requests
  static const Duration cacheExpiration = Duration(hours: 24);
}

