# 🔬 DEVTOOLS PROFILING GUIDE - AppSanitaria

**Data:** 7 de Outubro, 2025  
**Status:** 📋 MANUAL DISPONÍVEL  
**Objetivo:** Guia para profiling detalhado de performance

---

## 🚀 COMO EXECUTAR PROFILING COMPLETO

### **PASSO 1: Iniciar app em PROFILE mode**

```bash
cd /Users/dcpduns/Desktop/appSanitaria
flutter run --profile -d emulator-5554
```

**Por que profile mode?**
- Mais próximo de produção que debug
- Mantém performance traces
- Não inclui debug overhead

---

### **PASSO 2: Abrir DevTools**

Quando o app iniciar, você verá:
```
The Flutter DevTools debugger and profiler is available at: 
http://127.0.0.1:9101?uri=http://...
```

**Abrir no navegador** → Acessar a aba **Performance**

---

### **PASSO 3: Capturar traces das telas críticas**

#### **3.1 Cold Start (Inicialização do app)**
1. Fechar o app completamente
2. No DevTools: Clicar **"Record"**
3. Abrir o app no emulador
4. Aguardar tela de login carregar
5. Clicar **"Stop"**

**Métrica alvo:** ≤ 1.5s até login screen visível

---

#### **3.2 Home Patient Screen Load**
1. Fazer login como paciente
2. No DevTools: Clicar **"Record"**
3. Navegar para Home
4. Aguardar cards carregarem
5. Clicar **"Stop"**

**Métricas alvo:**
- First frame: ≤ 300ms
- All cards rendered: ≤ 800ms

---

#### **3.3 Professionals List Scroll**
1. Navegar para lista de profissionais
2. No DevTools: Clicar **"Record"**
3. Scroll rápido de cima para baixo (5x)
4. Clicar **"Stop"**

**Métricas alvo:**
- Jank (skipped frames): < 5% dos frames
- p99 frame time: ≤ 16ms (60 FPS)
- Davey (long frame): 0ms

---

#### **3.4 Chat Screen Rendering**
1. Abrir uma conversa com ≥ 50 mensagens
2. No DevTools: Clicar **"Record"**
3. Scroll até o topo
4. Enviar 1 mensagem
5. Clicar **"Stop"**

**Métricas alvo:**
- Message send → UI update: ≤ 100ms
- Scroll jank: < 3%

---

### **PASSO 4: Analisar resultados**

Na aba **Performance** do DevTools, procurar por:

#### **🔴 Red flags (CRÍTICO):**
- Frames > 16ms (jank)
- Davey (frames > 700ms)
- `build()` calls > 100ms
- I/O síncrono no main thread

#### **🟡 Yellow flags (ATENÇÃO):**
- GC (Garbage Collection) frequente
- Alocação de memória > 10 MB/s
- Widget rebuilds desnecessários

#### **🟢 Green flags (BOM):**
- Frames consistentes em ~16ms
- GC raro e rápido
- Memória estável

---

## 📊 BASELINE ATUAL (PRs #3 e #4)

### **Antes da refatoração:**
- Max skipped frames: **1546** 🔴
- Davey duration: **10747ms** 🔴
- Jank rate: ~40% 🔴

### **Depois da refatoração (RatingsCacheProvider):**
- Max skipped frames: **416** 🟡 (73% redução ✅)
- Davey duration: **0ms** 🟢 (100% redução ✅)
- Jank rate: ~10% 🟡

### **Target para próxima iteração:**
- Max skipped frames: **< 100** 🟢
- Davey duration: **0ms** 🟢 (mantido)
- Jank rate: **< 5%** 🟢

---

## 🛠️ AÇÕES RECOMENDADAS BASEADO EM PROFILING

### **Se detectar I/O no main thread:**
```dart
// ❌ ANTES
final data = localStorage.getData();

// ✅ DEPOIS  
final data = await Future.microtask(() => localStorage.getData());
```

### **Se detectar rebuilds excessivos:**
```dart
// ❌ ANTES
class MyWidget extends StatelessWidget {
  Widget build(context) {
    final provider = ref.watch(myProvider); // Rebuilds sempre
    ...
  }
}

// ✅ DEPOIS
class MyWidget extends ConsumerWidget {
  Widget build(context, ref) {
    final specificValue = ref.watch(myProvider.select((s) => s.field)); // Rebuilds só quando field muda
    ...
  }
}
```

### **Se detectar GC frequente:**
```dart
// ❌ ANTES
List.generate(100, (i) => ProfessionalCard(...)); // Aloca 100 objetos de uma vez

// ✅ DEPOIS
ListView.builder(
  itemCount: 100,
  itemBuilder: (context, i) => ProfessionalCard(...), // Aloca sob demanda
);
```

---

## 🎯 COMANDOS ÚTEIS

### **Profile build com tamanho de APK:**
```bash
flutter build apk --profile --analyze-size
```

### **Profile build com tree-shake icons:**
```bash
flutter build apk --release --tree-shake-icons
```

### **Capture timeline JSON para análise offline:**
```bash
flutter run --profile --trace-startup
```

---

## 📝 CHECKLIST FINAL

Antes de considerar profiling completo, verificar:

- [ ] Cold start ≤ 1.5s
- [ ] Home screen load ≤ 800ms
- [ ] Scroll jank < 5%
- [ ] Davey duration = 0ms
- [ ] Memory leaks = 0
- [ ] APK size não aumentou > 5%
- [ ] Todos os traces salvos e documentados

---

**Próximo passo:** Executar este guia manualmente ou configurar CI/CD para profiling automático.

*Guia criado durante pipeline de refatoração.*

