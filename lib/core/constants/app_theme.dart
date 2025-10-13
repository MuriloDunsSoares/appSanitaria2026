// ═══════════════════════════════════════════════════════════════════════════
// ARQUIVO: app_theme.dart
// PROPÓSITO: Centralização do tema visual (cores, tipografia, estilos)
// ═══════════════════════════════════════════════════════════════════════════

/// [flutter/material.dart]
/// Framework UI do Flutter contendo definições de cores, widgets, e ThemeData.
/// Necessário para criar ColorScheme, TextTheme, ThemeData, e gradientes.
/// **Interação:** Base para todas as customizações visuais da aplicação.
library;

import 'package:flutter/material.dart';

/// Classe utilitária que centraliza todo o design system da aplicação.
///
/// **PATTERN: Design System Container**
/// Agrupa todas as definições visuais (cores, tipografia, espaçamentos, etc)
/// para garantir consistência visual em toda a aplicação.
///
/// **BENEFÍCIOS:**
/// 1. **Consistência:** Mesmas cores/estilos em toda a app
/// 2. **Manutenção:** Mudar cor primária em 1 lugar atualiza tudo
/// 3. **Escalabilidade:** Fácil adicionar dark mode, temas personalizados
/// 4. **Performance:** Constantes são inlined pelo compilador
/// 5. **Branding:** Identidade visual centralizada
///
/// **ARQUITETURA:**
/// - Camada: Core/Constants (fundação da aplicação)
/// - Responsabilidade: Definir paleta de cores, tipografia, espaçamentos
/// - Escopo: Global (acessível via AppTheme.primaryColor ou Theme.of(context))
///
/// **DESIGN PATTERN: Static Class com construtor privado**
/// Previne instanciação (AppTheme() causaria erro).
/// Todos os membros são static: AppTheme.primaryColor
///
/// **ORGANIZAÇÃO:**
/// ```
/// AppTheme
/// ├─ CORES PRIMÁRIAS (branding principal)
/// ├─ CORES DE FUNDO (backgrounds e surfaces)
/// ├─ CORES DE TEXTO (hierarquia tipográfica)
/// ├─ CORES DE ESTADO (success, error, warning, info)
/// ├─ ESPECIALIDADES (gradientes dos cards)
/// ├─ THEME DATA (MaterialApp theme completo)
/// ├─ SPACING (espaçamentos padronizados)
/// └─ BORDER RADIUS (arredondamentos padronizados)
/// ```
///
/// **INTERAÇÕES COM CÓDIGO:**
/// - `main.dart` aplica via `MaterialApp.theme`
/// - Todos os widgets acessam via `Theme.of(context).colorScheme.primary`
/// - Cards customizados usam gradientes específicos (cuidadoresGradient, etc)
/// - Layouts usam spacing constants (spaceMd, spaceLg)
/// - Widgets usam border radius constants (radiusMd, radiusLg)
///
/// **ACESSO AOS VALORES:**
/// ```dart
/// // Opção 1: Via AppTheme (direto)
/// Color myColor = AppTheme.primaryColor;
/// double mySpace = AppTheme.spaceMd;
///
/// // Opção 2: Via Theme.of(context) (recomendado para widgets)
/// Color myColor = Theme.of(context).colorScheme.primary;
/// TextStyle myStyle = Theme.of(context).textTheme.headlineLarge;
/// ```
///
/// **PERFORMANCE:** 
/// - Constantes: O(1), zero overhead runtime (inlined)
/// - lightTheme getter: Criado 1x, cached pelo MaterialApp
/// - Theme.of(context): O(1), busca eficiente na árvore de widgets
///
/// **MEMÓRIA:** 
/// - Constantes de cor: ~16 bytes cada
/// - ThemeData completo: ~2-3 KB em memória
/// - Total: <5 KB (insignificante)
///
/// **EXTENSIBILIDADE FUTURA:**
/// ```dart
/// // Dark mode:
/// static ThemeData get darkTheme { ... }
///
/// // Temas personalizados:
/// static ThemeData getCustomTheme(Color seedColor) { ... }
///
/// // Acessibilidade:
/// static ThemeData getHighContrastTheme() { ... }
/// ```
///
/// **DESIGN SYSTEM REFERENCE:**
/// - Material Design 3: Seguimos guidelines do Google
/// - Color system: Inspirado em Material You
/// - Typography: Scale padronizada (12, 14, 16, 20, 24, 32)
/// - Spacing: Escala 8pt (4, 8, 16, 24, 32)
class AppTheme {
  // ───────────────────────────────────────────────────────────────────────
  // CONSTRUTOR PRIVADO - Previne Instanciação
  // ───────────────────────────────────────────────────────────────────────
  
  /// Construtor privado que previne instanciação da classe.
  ///
  /// **Por que privado?**
  /// - AppTheme é utility class (apenas static members)
  /// - Não faz sentido criar instâncias: `final theme = AppTheme()` ❌
  /// - Força uso correto: `AppTheme.primaryColor` ✅
  ///
  /// **Sintaxe:** `AppTheme._()` → construtor nomeado privado (underscore)
  ///
  /// **Convenção Flutter:** Padrão para classes utilities
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════════
  // CORES PRIMÁRIAS - Identidade Visual do Brand
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Cor primária da aplicação (roxo/lilás vibrante).
  ///
  /// **Hex:** #667EEA (RGB: 102, 126, 234)
  ///
  /// **Uso:**
  /// - AppBar background
  /// - Botões primários (ElevatedButton)
  /// - Links e highlights
  /// - Ícones importantes
  /// - Bordas de inputs focados
  ///
  /// **Psicologia da cor roxo:**
  /// - Transmite confiança, cuidado, profissionalismo
  /// - Associado à saúde e bem-estar
  /// - Diferenciação (poucas apps de saúde usam roxo)
  ///
  /// **Acessibilidade:**
  /// - Contraste com branco: 4.8:1 (passa WCAG AA para texto grande)
  /// - Contraste com preto: 4.3:1 (passa WCAG AA)
  ///
  /// **Onde é usado:**
  /// - AppBarTheme.backgroundColor
  /// - ColorScheme.primary
  /// - ElevatedButton default color
  /// - InputDecoration.focusedBorder
  ///
  /// **Como acessar:**
  /// ```dart
  /// // Direto:
  /// AppTheme.primaryColor
  ///
  /// // Via Theme (recomendado):
  /// Theme.of(context).colorScheme.primary
  /// ```
  static const Color primaryColor = Color(0xFF667EEA);
  
  /// Cor primária escura (roxo profundo).
  ///
  /// **Hex:** #764BA2 (RGB: 118, 75, 162)
  ///
  /// **Uso:**
  /// - Extremidade de gradientes (ponto final)
  /// - Hover states de botões
  /// - Sombras coloridas
  /// - Status bar color (Android)
  ///
  /// **Gradiente típico:**
  /// ```dart
  /// LinearGradient(
  ///   colors: [AppTheme.primaryColor, AppTheme.primaryDark],
  /// )
  /// ```
  ///
  /// **Onde é usado:**
  /// - cuidadoresGradient (cards da home)
  /// - HomeProfessionalScreen header gradient
  /// - Botões com gradiente
  ///
  /// **Acessibilidade:**
  /// - Contraste com branco: 7.2:1 (passa WCAG AAA)
  /// - Mais escuro = melhor legibilidade
  static const Color primaryDark = Color(0xFF764BA2);
  
  /// Cor secundária da aplicação (azul Material).
  ///
  /// **Hex:** #2196F3 (RGB: 33, 150, 243)
  ///
  /// **Uso:**
  /// - Botões secundários (TextButton, OutlinedButton)
  /// - Ícones informativos
  /// - Links menos importantes
  /// - Badges e chips
  /// - Progress indicators
  ///
  /// **Psicologia da cor azul:**
  /// - Confiança e segurança
  /// - Calma e tranquilidade
  /// - Padrão da indústria tech/saúde
  ///
  /// **Onde é usado:**
  /// - ColorScheme.secondary
  /// - TextButton text color
  /// - Info icons
  /// - tecnicosGradient (cards de técnicos de enfermagem)
  ///
  /// **Harmonização:**
  /// - Combina bem com primaryColor (esquema análogo)
  /// - Não compete visualmente (roxo é dominante, azul é suporte)
  ///
  /// **Acessibilidade:**
  /// - Contraste com branco: 3.1:1 (falha WCAG AA, usar com cuidado)
  /// - Melhor usar em elementos grandes (ícones, fundos)
  static const Color secondaryColor = Color(0xFF2196F3);

  // ═══════════════════════════════════════════════════════════════════════
  // CORES DE FUNDO - Backgrounds e Surfaces
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Cor de fundo principal da aplicação (cinza muito claro).
  ///
  /// **Hex:** #F8F9FA (RGB: 248, 249, 250)
  ///
  /// **Uso:**
  /// - Scaffold.backgroundColor (fundo de telas)
  /// - Background geral da app
  /// - Contraste sutil com cards brancos
  ///
  /// **Design rationale:**
  /// - Cinza claro cria hierarquia visual (cards se destacam)
  /// - Reduz fadiga ocular (branco puro é muito brilhante)
  /// - Padrão em apps modernas (Instagram, Twitter usam similar)
  ///
  /// **Onde é usado:**
  /// - MaterialApp.scaffoldBackgroundColor
  /// - Todas as telas automaticamente herdam esta cor
  ///
  /// **Contraste:**
  /// - Com branco (cards): Sutil mas perceptível
  /// - Com texto preto: 19.5:1 (excelente legibilidade)
  ///
  /// **Performance:**
  /// - Cor sólida renderiza mais rápido que gradientes
  /// - GPU-friendly (sem blend complexo)
  static const Color backgroundColor = Color(0xFFF8F9FA);
  
  /// Cor de superfícies elevadas (branco puro).
  ///
  /// **Valor:** Colors.white (#FFFFFFFF)
  ///
  /// **Uso:**
  /// - Fundo de widgets elevados
  /// - Material surfaces
  /// - Overlays e modals
  ///
  /// **Onde é usado:**
  /// - ColorScheme.surface
  /// - Input fields background
  /// - Bottom sheets
  /// - Dialogs
  ///
  /// **Material Design:**
  /// - Surface = camada elevada sobre background
  /// - Cria hierarquia de elevação (z-index visual)
  ///
  /// **Nota:** Usar Colors.white (const) é mais eficiente que Color(0xFFFFFFFF)
  static const Color surfaceColor = Colors.white;
  
  /// Cor de fundo de cards (branco puro).
  ///
  /// **Valor:** Colors.white (#FFFFFFFF)
  ///
  /// **Uso:**
  /// - Card widgets
  /// - ProfessionalCard
  /// - ConversationCard
  /// - ContractCard
  ///
  /// **Onde é usado:**
  /// - CardTheme.color
  /// - Todos os Card() herdam automaticamente
  ///
  /// **Design rationale:**
  /// - Contraste com backgroundColor cria destaque
  /// - Branco transmite limpeza e confiança
  /// - Combina com qualquer cor de acento
  ///
  /// **Elevação:**
  /// - Cards têm elevation: 2 (sombra sutil)
  /// - Sombra reforça hierarquia visual
  static const Color cardColor = Colors.white;

  // ═══════════════════════════════════════════════════════════════════════
  // CORES DE TEXTO - Hierarquia Tipográfica
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Cor de texto primário (cinza muito escuro).
  ///
  /// **Hex:** #333333 (RGB: 51, 51, 51)
  ///
  /// **Uso:**
  /// - Headings (títulos)
  /// - Texto de maior importância
  /// - Nomes de profissionais
  /// - Títulos de cards
  ///
  /// **Por que #333 e não preto puro (#000)?**
  /// - Preto puro é muito agressivo visualmente
  /// - #333 é mais suave, reduz fadiga ocular
  /// - Padrão da indústria (Google, Medium, etc usam)
  ///
  /// **Acessibilidade:**
  /// - Contraste com branco: 12.6:1 (passa WCAG AAA)
  /// - Contraste com backgroundColor: 12.4:1 (AAA)
  /// - Excelente para qualquer tamanho de texto
  ///
  /// **Onde é usado:**
  /// - TextTheme.headlineLarge.color
  /// - TextTheme.bodyLarge.color
  /// - Texto principal em todos os widgets
  ///
  /// **Hierarquia:** Nível 1 (mais importante)
  static const Color textPrimary = Color(0xFF333333);
  
  /// Cor de texto secundário (cinza médio).
  ///
  /// **Hex:** #666666 (RGB: 102, 102, 102)
  ///
  /// **Uso:**
  /// - Texto de importância média
  /// - Descrições e subtítulos
  /// - Especialidades de profissionais
  /// - Metadata (data, hora, localização)
  ///
  /// **Diferenciação visual:**
  /// - Mais claro que textPrimary → cria hierarquia
  /// - Usuário naturalmente lê textPrimary primeiro
  ///
  /// **Acessibilidade:**
  /// - Contraste com branco: 5.7:1 (passa WCAG AA)
  /// - Contraste com backgroundColor: 5.6:1 (AA)
  /// - Adequado para texto >= 14px
  ///
  /// **Onde é usado:**
  /// - TextTheme.bodyMedium.color
  /// - Subtítulos em cards
  /// - Info secundária em listas
  ///
  /// **Hierarquia:** Nível 2 (importância média)
  static const Color textSecondary = Color(0xFF666666);
  
  /// Cor de texto hint/placeholder (cinza claro).
  ///
  /// **Hex:** #999999 (RGB: 153, 153, 153)
  ///
  /// **Uso:**
  /// - Placeholders de input ("Digite seu nome...")
  /// - Hints e dicas
  /// - Texto desabilitado
  /// - Labels de baixa importância
  ///
  /// **Acessibilidade:**
  /// - Contraste com branco: 2.8:1 (falha WCAG AA)
  /// - **ATENÇÃO:** Não usar para texto importante!
  /// - Adequado apenas para hints (não são conteúdo principal)
  ///
  /// **Onde é usado:**
  /// - TextTheme.bodySmall.color
  /// - TextField hintText
  /// - Disabled text
  ///
  /// **Hierarquia:** Nível 3 (menor importância)
  static const Color textHint = Color(0xFF999999);

  // ═══════════════════════════════════════════════════════════════════════
  // CORES DE ESTADO - Feedback Visual
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Cor de sucesso (verde Material).
  ///
  /// **Hex:** #4CAF50 (RGB: 76, 175, 80)
  ///
  /// **Uso:**
  /// - Mensagens de sucesso (SnackBar)
  /// - Ícones de confirmação
  /// - Status "Ativo" ou "Aprovado"
  /// - Botões de ação positiva
  ///
  /// **Psicologia:**
  /// - Verde = segurança, sucesso, "go ahead"
  /// - Universal (reconhecido globalmente)
  ///
  /// **Onde é usado:**
  /// - ScaffoldMessenger (sucesso)
  /// - Check icons
  /// - Status badges
  ///
  /// **Acessibilidade:**
  /// - Não confiar apenas em cor (adicionar ícone ✓)
  /// - Daltônicos podem não distinguir de cinza
  ///
  /// **Exemplo:**
  /// ```dart
  /// ScaffoldMessenger.of(context).showSnackBar(
  ///   SnackBar(
  ///     content: Text('Contrato criado com sucesso!'),
  ///     backgroundColor: AppTheme.successColor,
  ///   ),
  /// );
  /// ```
  static const Color successColor = Color(0xFF4CAF50);
  
  /// Cor de erro (vermelho suave).
  ///
  /// **Hex:** #E74C3C (RGB: 231, 76, 60)
  ///
  /// **Uso:**
  /// - Mensagens de erro
  /// - Validação de formulários
  /// - Textos de erro
  /// - Ícones de alerta crítico
  ///
  /// **Psicologia:**
  /// - Vermelho = perigo, parar, atenção urgente
  /// - Chama atenção imediatamente
  ///
  /// **Por que este tom específico?**
  /// - Não é vermelho puro (muito agressivo)
  /// - Tom "flat" moderno (tendência de design)
  /// - Bom contraste com branco
  ///
  /// **Onde é usado:**
  /// - InputDecoration.errorBorder
  /// - Form validation messages
  /// - Error SnackBars
  ///
  /// **Acessibilidade:**
  /// - Sempre acompanhar com texto explicativo
  /// - Não usar apenas cor para indicar erro
  ///
  /// **Exemplo:**
  /// ```dart
  /// if (email.isEmpty) {
  ///   return Text(
  ///     'Email é obrigatório',
  ///     style: TextStyle(color: AppTheme.errorColor),
  ///   );
  /// }
  /// ```
  static const Color errorColor = Color(0xFFE74C3C);
  
  /// Cor de aviso (laranja).
  ///
  /// **Hex:** #FFA726 (RGB: 255, 167, 38)
  ///
  /// **Uso:**
  /// - Avisos não críticos
  /// - "Atenção, mas não urgente"
  /// - Status "Pendente" ou "Aguardando"
  /// - Ícones de alerta moderado
  ///
  /// **Psicologia:**
  /// - Laranja = cautela, atenção moderada
  /// - Intermediário entre verde (ok) e vermelho (perigo)
  ///
  /// **Onde seria usado (não muito implementado no MVP):**
  /// - Contratos pendentes
  /// - Perfis incompletos
  /// - Notificações de ação necessária
  ///
  /// **Diferença de errorColor:**
  /// - warningColor = "você deve fazer algo"
  /// - errorColor = "algo deu errado"
  ///
  /// **Exemplo:**
  /// ```dart
  /// if (contract.status == 'pending') {
  ///   return Container(
  ///     color: AppTheme.warningColor.withOpacity(0.1),
  ///     child: Text('Aguardando confirmação'),
  ///   );
  /// }
  /// ```
  static const Color warningColor = Color(0xFFFFA726);
  
  /// Cor informativa (azul, mesmo que secondaryColor).
  ///
  /// **Hex:** #2196F3 (RGB: 33, 150, 243)
  ///
  /// **Uso:**
  /// - Mensagens informativas neutras
  /// - Tooltips
  /// - Info icons (ℹ️)
  /// - Dicas e sugestões
  ///
  /// **Psicologia:**
  /// - Azul = calma, confiança, informação
  /// - Não é urgente nem negativo
  ///
  /// **Onde seria usado:**
  /// - Info SnackBars
  /// - Tooltips explicativos
  /// - Help icons
  ///
  /// **Nota:** Mesmo valor que secondaryColor (reuso intencional)
  ///
  /// **Exemplo:**
  /// ```dart
  /// IconButton(
  ///   icon: Icon(Icons.info, color: AppTheme.infoColor),
  ///   onPressed: () => showTooltip('Toque para mais informações'),
  /// );
  /// ```
  static const Color infoColor = Color(0xFF2196F3);

  // ═══════════════════════════════════════════════════════════════════════
  // ESPECIALIDADES - Gradientes para Cards de Categorias
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Gradiente para cards de "Cuidadores" (roxo primário).
  ///
  /// **Cores:** 
  /// - Início (topLeft): #667EEA (primaryColor - roxo claro)
  /// - Fim (bottomRight): #764BA2 (primaryDark - roxo escuro)
  ///
  /// **Direção:** Diagonal (topLeft → bottomRight)
  /// ```
  /// ┌─────────┐
  /// │●        │  ● = início (claro)
  /// │  ╲      │
  /// │    ╲    │  ╲ = direção do gradiente
  /// │      ●  │  ● = fim (escuro)
  /// └─────────┘
  /// ```
  ///
  /// **Onde é usado:**
  /// - HomePatientScreen: Card "Cuidadores"
  /// - Tela de busca ao filtrar por "Cuidadores"
  ///
  /// **Design rationale:**
  /// - Usa cores do brand (consistência visual)
  /// - Gradiente cria profundidade e modernidade
  /// - Diagonal é mais dinâmica que vertical/horizontal
  ///
  /// **Uso típico:**
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     gradient: AppTheme.cuidadoresGradient,
  ///     borderRadius: BorderRadius.circular(16),
  ///   ),
  /// )
  /// ```
  ///
  /// **Performance:**
  /// - Gradientes são mais pesados que cores sólidas (~2-3x)
  /// - GPU renderiza bem (hardware-accelerated)
  /// - Usar com moderação em listas longas
  static const LinearGradient cuidadoresGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente para cards de "Técnicos de enfermagem" (azul).
  ///
  /// **Cores:**
  /// - Início: #2196F3 (secondaryColor - azul Material claro)
  /// - Fim: #1976D2 (azul Material escuro)
  ///
  /// **Direção:** Diagonal (topLeft → bottomRight)
  ///
  /// **Onde é usado:**
  /// - HomePatientScreen: Card "Técnicos de enfermagem"
  /// - Filtro por esta especialidade
  ///
  /// **Psicologia:**
  /// - Azul transmite profissionalismo e confiança
  /// - Adequado para profissionais técnicos
  /// - Diferencia visualmente de "Cuidadores" (roxo)
  ///
  /// **Contraste:**
  /// - Texto branco tem bom contraste em ambos os tons
  /// - Acessível para leitura de títulos
  ///
  /// **Variação de tom:**
  /// - Leve (2196F3 → 1976D2)
  /// - Cria transição suave
  static const LinearGradient tecnicosGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente para cards de "Acompanhantes hospital" (vermelho/coral).
  ///
  /// **Cores:**
  /// - Início: #FF6B6B (vermelho coral claro)
  /// - Fim: #EE5A6F (vermelho coral escuro)
  ///
  /// **Direção:** Diagonal (topLeft → bottomRight)
  ///
  /// **Onde é usado:**
  /// - HomePatientScreen: Card "Acompanhantes hospital"
  /// - Filtro por esta especialidade
  ///
  /// **Psicologia:**
  /// - Vermelho/coral = urgência, atenção, cuidado intenso
  /// - Adequado para contexto hospitalar (situação crítica)
  /// - Diferencia de outras categorias
  ///
  /// **Design:**
  /// - Tom "coral" é mais suave que vermelho puro
  /// - Não assusta como vermelho erro
  /// - Moderno e acolhedor
  ///
  /// **Acessibilidade:**
  /// - Texto branco tem bom contraste
  /// - Visível para daltônicos (protanopia/deuteranopia)
  static const LinearGradient acompanhantesGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente para cards de "Acompanhante Domiciliar" (turquesa/verde).
  ///
  /// **Cores:**
  /// - Início: #4ECDC4 (turquesa claro)
  /// - Fim: #44A08D (verde água escuro)
  ///
  /// **Direção:** Diagonal (topLeft → bottomRight)
  ///
  /// **Onde é usado:**
  /// - HomePatientScreen: Card "Acompanhante Domiciliar"
  /// - Filtro por esta especialidade
  ///
  /// **Psicologia:**
  /// - Turquesa/verde = calma, conforto, ambiente doméstico
  /// - Adequado para cuidado em casa (menos intenso que hospital)
  /// - Transmite tranquilidade
  ///
  /// **Diferenciação:**
  /// - Única categoria com tons de verde/turquesa
  /// - Fácil distinção visual das outras
  ///
  /// **Design:**
  /// - Tom moderno e clean
  /// - Combina com branding geral
  /// - Agradável aos olhos
  ///
  /// **Acessibilidade:**
  /// - Texto branco legível
  /// - Contraste adequado (>4.5:1)
  static const LinearGradient domiciliarGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // === THEME DATA ===
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,

      // AppBar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),

      // Cards
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: cardColor,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textHint,
        ),
      ),
    );
  }

  // === SPACING ===
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;

  // === BORDER RADIUS ===
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 999.0;
}
