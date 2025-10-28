# 📋 PR 1.3 - Backend Specification: Contract Status Transitions & Validations

**Status**: 🟡 FRONTEND READY, BACKEND PENDING  
**Data**: 27 de Outubro de 2025

---

## 🎯 O que foi feito no Frontend

✅ **Já existe**:
- `UpdateContractStatus` UseCase - valida transições
- `CancelContract` UseCase - valida cancelamento
- `UpdateContract` UseCase - valida edição
- Firestore Rules - bloqueia transições inválidas (PR 1.1)

⏳ **Precisa**:
- HTTP DataSource para chamar backend
- Backend endpoints para validação com ACID

---

## 🔧 O que precisa ser feito no Backend

### Endpoints HTTP

#### 1️⃣ PATCH /api/v1/contracts/{contractId}/status
```
Alterar status de um contrato
```

**Authorization**: Bearer JWT  
**Body**:
```json
{
  "newStatus": "accepted" // 'pending' | 'accepted' | 'rejected' | 'completed' | 'cancelled'
}
```

**Validações**:
- ✅ JWT token válido
- ✅ Contrato existe
- ✅ Usuário é paciente ou profissional envolvido (ou admin)
- ✅ Transição de status é válida

**Transições Válidas**:
```
pending    → accepted, rejected, cancelled
accepted   → completed, cancelled
rejected   → cancelled
completed  → (terminal)
cancelled  → (terminal)
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "contractId": "contract_123",
    "status": "accepted",
    "updatedAt": "2025-10-27T10:00:00Z"
  }
}
```

---

#### 2️⃣ PATCH /api/v1/contracts/{contractId}/cancel
```
Cancelar um contrato com motivo
```

**Authorization**: Bearer JWT  
**Body**:
```json
{
  "reason": "Cliente mudou de ideia"
}
```

**Validações**:
- ✅ JWT token válido
- ✅ Contrato existe
- ✅ Usuário é paciente ou profissional
- ✅ Status é pending ou accepted
- ✅ Motivo não está vazio

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "contractId": "contract_123",
    "status": "cancelled",
    "cancelledBy": "Paciente",
    "reason": "Cliente mudou de ideia",
    "updatedAt": "2025-10-27T10:00:00Z"
  }
}
```

---

#### 3️⃣ PATCH /api/v1/contracts/{contractId}
```
Atualizar campos de um contrato (apenas se pending)
```

**Authorization**: Bearer JWT  
**Body**:
```json
{
  "serviceType": "Limpeza",
  "address": "Rua A, 123",
  "duration": 4,
  "date": "2025-11-15",
  "value": 150.00
}
```

**Validações**:
- ✅ JWT token válido
- ✅ Contrato existe
- ✅ Apenas paciente criador pode editar
- ✅ Status é pending
- ✅ Data não está no passado
- ✅ Campos obrigatórios preenchidos
- ✅ Valores válidos (duration > 0, value > 0)

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "contractId": "contract_123",
    "status": "pending",
    "updatedAt": "2025-10-27T10:00:00Z"
  }
}
```

---

### Error Responses

```json
// 400 Bad Request - Validação falhou
{
  "error": "Transição inválida: completed → pending"
}

// 401 Unauthorized
{
  "error": "JWT token inválido ou expirado"
}

// 403 Forbidden
{
  "error": "Você não tem permissão para alterar este contrato"
}

// 404 Not Found
{
  "error": "Contrato não encontrado"
}

// 500 Internal Server Error
{
  "error": "Erro ao atualizar contrato"
}
```

---

## 📝 Implementação Recomendada (Backend)

### Arquivo: `backend/lib/features/contracts/domain/services/contracts_service.dart`

```dart
class ContractsService {
  final FirebaseFirestore _firestore;

  /// ✅ Valida e executa transição de status
  /// ACID transaction garantida
  Future<Map<String, dynamic>> updateContractStatus(
    String contractId,
    String newStatus,
    String userId,
  ) async {
    try {
      // 1. Buscar contrato
      final contractDoc = await _firestore
          .collection('contracts')
          .doc(contractId)
          .get();

      if (!contractDoc.exists) {
        throw const StorageException('Contrato não encontrado');
      }

      final contract = contractDoc.data()!;
      final currentStatus = contract['status'] as String;

      // 2. Validar transição
      if (!_isValidTransition(currentStatus, newStatus)) {
        throw ValidationException(
          'Transição inválida: $currentStatus → $newStatus',
        );
      }

      // 3. Validar permissão
      if (userId != contract['patientId'] && 
          userId != contract['professionalId']) {
        throw const ValidationException(
          'Você não tem permissão para alterar este contrato',
        );
      }

      // 4. Usar transação para atualizar atomicamente
      await _firestore.runTransaction((transaction) async {
        transaction.update(
          contractDoc.reference,
          {
            'status': newStatus,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );

        // Registrar auditoria
        transaction.set(
          _firestore.collection('auditLogs').doc(),
          {
            'action': 'contract.status_changed',
            'contractId': contractId,
            'userId': userId,
            'from': currentStatus,
            'to': newStatus,
            'timestamp': FieldValue.serverTimestamp(),
          },
        );
      });

      return {
        'contractId': contractId,
        'status': newStatus,
        'updatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Valida se a transição de status é permitida
  bool _isValidTransition(String from, String to) {
    final validTransitions = {
      'pending': ['accepted', 'rejected', 'cancelled'],
      'accepted': ['completed', 'cancelled'],
      'rejected': ['cancelled'],
      'completed': [],
      'cancelled': [],
    };

    return validTransitions[from]?.contains(to) ?? false;
  }

  /// ✅ Valida e cancela contrato
  Future<Map<String, dynamic>> cancelContract(
    String contractId,
    String userId,
    String reason,
  ) async {
    try {
      // 1. Buscar contrato
      final contractDoc = await _firestore
          .collection('contracts')
          .doc(contractId)
          .get();

      if (!contractDoc.exists) {
        throw const StorageException('Contrato não encontrado');
      }

      final contract = contractDoc.data()!;
      final currentStatus = contract['status'] as String;

      // 2. Validar se pode cancelar
      if (currentStatus != 'pending' && currentStatus != 'accepted') {
        throw ValidationException(
          'Contrato com status $currentStatus não pode ser cancelado',
        );
      }

      // 3. Validar permissão
      if (userId != contract['patientId'] && 
          userId != contract['professionalId']) {
        throw const ValidationException(
          'Você não tem permissão para cancelar este contrato',
        );
      }

      // 4. Validar motivo
      if (reason.trim().isEmpty) {
        throw const ValidationException('Motivo é obrigatório');
      }

      // 5. Determinar quem cancelou
      final isPatient = userId == contract['patientId'];
      final cancelledBy = isPatient ? 'Paciente' : 'Profissional';

      // 6. Usar transação
      await _firestore.runTransaction((transaction) async {
        transaction.update(
          contractDoc.reference,
          {
            'status': 'cancelled',
            'cancelledBy': cancelledBy,
            'cancellationReason': reason,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );

        // Registrar auditoria
        transaction.set(
          _firestore.collection('auditLogs').doc(),
          {
            'action': 'contract.cancelled',
            'contractId': contractId,
            'userId': userId,
            'cancelledBy': cancelledBy,
            'reason': reason,
            'timestamp': FieldValue.serverTimestamp(),
          },
        );
      });

      return {
        'contractId': contractId,
        'status': 'cancelled',
        'cancelledBy': cancelledBy,
        'reason': reason,
        'updatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      rethrow;
    }
  }
}
```

### Arquivo: `backend/lib/features/contracts/presentation/controllers/contracts_controller.dart`

```dart
class ContractsController {
  final ContractsService _contractsService;

  /// PATCH /api/v1/contracts/{contractId}/status
  Future<Response> updateStatus(
    Request request,
    String contractId,
  ) async {
    try {
      final token = request.headers['authorization']?.replaceFirst('Bearer ', '');
      if (token == null) {
        return Response(401, body: jsonEncode({'error': 'JWT requerido'}));
      }

      final userId = await _authService.validateToken(token);
      if (userId == null) {
        return Response(401, body: jsonEncode({'error': 'Token inválido'}));
      }

      final body = await request.readAsString();
      final params = jsonDecode(body) as Map<String, dynamic>;
      final newStatus = params['newStatus'] as String;

      final result = await _contractsService.updateContractStatus(
        contractId,
        newStatus,
        userId,
      );

      return Response.ok(
        jsonEncode({'success': true, 'data': result}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response(500, body: jsonEncode({'error': e.toString()}));
    }
  }

  /// PATCH /api/v1/contracts/{contractId}/cancel
  Future<Response> cancelContract(
    Request request,
    String contractId,
  ) async {
    try {
      final token = request.headers['authorization']?.replaceFirst('Bearer ', '');
      if (token == null) {
        return Response(401, body: jsonEncode({'error': 'JWT requerido'}));
      }

      final userId = await _authService.validateToken(token);
      if (userId == null) {
        return Response(401, body: jsonEncode({'error': 'Token inválido'}));
      }

      final body = await request.readAsString();
      final params = jsonDecode(body) as Map<String, dynamic>;
      final reason = params['reason'] as String;

      final result = await _contractsService.cancelContract(
        contractId,
        userId,
        reason,
      );

      return Response.ok(
        jsonEncode({'success': true, 'data': result}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response(500, body: jsonEncode({'error': e.toString()}));
    }
  }
}
```

---

## 📊 Frontend Status

✅ **Já Existe**:
- 3 UseCases com validações
- Firestore Rules com bloqueio
- Pronto para chamar backend

⏳ **Precisa**:
- HTTP DataSource para chamar backend
- Atualizar repositories para usar HTTP

---

## 🧪 Testes Recomendados

```dart
// Backend Unit Tests
test('updateContractStatus: pending → accepted (válido)', () async {
  // Arrange, Act, Assert
});

test('updateContractStatus: completed → pending (inválido)', () async {
  // Deve rejeitar
});

test('cancelContract: apenas status pending ou accepted', () async {
  // Deve rejeitar completed ou rejected
});
```

---

## 📋 Checklist para PR 1.3

### Frontend (PENDENTE):
- [ ] Criar HTTP DataSource com 3 métodos
- [ ] Atualizar Repositories
- [ ] Testar chamadas HTTP

### Backend (PENDENTE):
- [ ] Implementar ContractsService
- [ ] Implementar ContractsController
- [ ] Montar rotas
- [ ] Testes unitários
- [ ] Deploy

---

**PR 1.3 Status**: Especificação completa, implementação pendente
