# 🧪 Backend Testing Quick Reference

**Status**: Ready to test  
**Date**: 27 October 2025

---

## 🚀 Start Backend Locally

```bash
cd backend_dart
dart pub get
dart run lib/main.dart
```

Expected output:
```
✅ Backend running at http://0.0.0.0:8080
📊 Available endpoints:
   POST   /api/v1/reviews/{professionalId}/aggregate
   PATCH  /api/v1/contracts/{contractId}/status
   PATCH  /api/v1/contracts/{contractId}/cancel
```

---

## 📍 Endpoints & Testing

### 0️⃣ Health Check (No Auth Required)
```bash
curl -X GET http://localhost:8080/health
```

Expected:
```
"Backend is running"
```

---

### 1️⃣ Reviews - Calculate Average Rating

**Endpoint**: `POST /api/v1/reviews/{professionalId}/aggregate`

**Required**: JWT Token in Authorization header

```bash
# Step 1: Set up variables
PROF_ID="prof_123"
TOKEN="your_jwt_token_here"

# Step 2: Make request
curl -X POST http://localhost:8080/api/v1/reviews/$PROF_ID/aggregate \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Expected Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "professionalId": "prof_123",
    "averageRating": 4.5,
    "totalReviews": 12,
    "updatedAt": "2025-10-27T10:00:00Z"
  }
}
```

**Error Responses**:
```json
// 401 - Missing token
{"error": "JWT token requerido"}

// 401 - Invalid token
{"error": "JWT token inválido ou expirado"}

// 404 - Professional not found
{"error": "Profissional com ID prof_123 não encontrado"}
```

---

### 2️⃣ Contracts - Update Status

**Endpoint**: `PATCH /api/v1/contracts/{contractId}/status`

**Required**: JWT Token + Valid status transition

```bash
# Step 1: Set up variables
CONTRACT_ID="contract_123"
TOKEN="your_jwt_token_here"
NEW_STATUS="accepted"  # valid: pending, accepted, rejected, completed, cancelled

# Step 2: Make request
curl -X PATCH http://localhost:8080/api/v1/contracts/$CONTRACT_ID/status \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"newStatus\": \"$NEW_STATUS\"}"
```

**Expected Response (200 OK)**:
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

**Valid Transitions**:
```
pending    → [accepted, rejected, cancelled]
accepted   → [completed, cancelled]
rejected   → [cancelled]
completed  → (terminal - no transitions)
cancelled  → (terminal - no transitions)
```

**Error Responses**:
```json
// 400 - Invalid transition
{"error": "Transição inválida: completed → pending"}

// 401 - Missing/invalid token
{"error": "JWT token requerido"}

// 403 - User not involved in contract
{"error": "Você não tem permissão para alterar este contrato"}

// 404 - Contract not found
{"error": "Contrato com ID contract_123 não encontrado"}
```

---

### 3️⃣ Contracts - Cancel

**Endpoint**: `PATCH /api/v1/contracts/{contractId}/cancel`

**Required**: JWT Token + Non-empty reason + Status is pending or accepted

```bash
# Step 1: Set up variables
CONTRACT_ID="contract_123"
TOKEN="your_jwt_token_here"
REASON="Cliente mudou de ideia"

# Step 2: Make request
curl -X PATCH http://localhost:8080/api/v1/contracts/$CONTRACT_ID/cancel \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"reason\": \"$REASON\"}"
```

**Expected Response (200 OK)**:
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

**Note**: `cancelledBy` will be:
- `"Paciente"` if the patient initiates cancellation
- `"Profissional"` if the professional initiates cancellation

**Error Responses**:
```json
// 400 - Missing reason
{"error": "reason é obrigatório"}

// 400 - Empty reason
{"error": "Motivo do cancelamento é obrigatório"}

// 400 - Invalid status (can only cancel pending/accepted)
{"error": "Contrato com status completed não pode ser cancelado. Apenas pending e accepted podem ser cancelados."}

// 403 - User not involved in contract
{"error": "Você não tem permissão para cancelar este contrato"}

// 404 - Contract not found
{"error": "Contrato com ID contract_123 não encontrado"}
```

---

### 4️⃣ Contracts - Update Fields

**Endpoint**: `PATCH /api/v1/contracts/{contractId}`

**Required**: JWT Token + Contract status must be pending + Patient creator

```bash
# Step 1: Set up variables
CONTRACT_ID="contract_123"
TOKEN="your_jwt_token_here"

# Step 2: Make request
curl -X PATCH http://localhost:8080/api/v1/contracts/$CONTRACT_ID \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "serviceType": "Limpeza",
    "address": "Rua A, 123",
    "duration": 4,
    "date": "2025-11-15",
    "value": 150.00
  }'
```

**Expected Response (200 OK)**:
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

**Validation Rules**:
- ✅ `date` must be in future (ISO format: YYYY-MM-DD)
- ✅ `duration` must be > 0
- ✅ `value` must be > 0
- ✅ Only patient can edit (creator)
- ✅ Only pending status can be edited

**Error Responses**:
```json
// 400 - Invalid date format
{"error": "Data inválida: invalid_date"}

// 400 - Date in past
{"error": "Data não pode ser no passado"}

// 400 - Invalid duration
{"error": "Duração deve ser maior que 0"}

// 400 - Invalid value
{"error": "Valor deve ser maior que 0"}

// 403 - Only creator can edit
{"error": "Apenas o criador do contrato pode editar"}

// 400 - Contract not pending
{"error": "Apenas contratos com status pending podem ser editados"}
```

---

## 🔑 JWT Token Generation

For testing, generate JWT token using the backend's AuthService:

```dart
// In Dart test
final authService = AuthService.instance;
final token = authService.generateToken('user_123');
print(token); // Use this in Authorization header
```

Or create manually with your JWT_SECRET:
```bash
# Using jwt.io web tool (NOT secure for production!)
# Header: {"alg": "HS256", "typ": "JWT"}
# Payload: {"userId": "user_123", "iat": 1234567890, "exp": 9999999999}
# Secret: your_jwt_secret_key_here_min_32_chars
```

---

## 📊 Full Test Sequence

```bash
#!/bin/bash

# Backend running at http://localhost:8080

TOKEN="your_token_here"
PROF_ID="prof_123"
CONTRACT_ID="contract_123"

echo "1️⃣ Health check..."
curl -X GET http://localhost:8080/health

echo "\n2️⃣ Aggregate reviews..."
curl -X POST http://localhost:8080/api/v1/reviews/$PROF_ID/aggregate \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{}'

echo "\n3️⃣ Update contract status..."
curl -X PATCH http://localhost:8080/api/v1/contracts/$CONTRACT_ID/status \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"newStatus": "accepted"}'

echo "\n4️⃣ Cancel contract..."
curl -X PATCH http://localhost:8080/api/v1/contracts/$CONTRACT_ID/cancel \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"reason": "Mudança de planos"}'

echo "\n5️⃣ Update contract fields..."
curl -X PATCH http://localhost:8080/api/v1/contracts/$CONTRACT_ID \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{
    "serviceType": "Limpeza",
    "address": "Rua B, 456",
    "duration": 5,
    "date": "2025-12-01",
    "value": 200.00
  }'
```

---

## 🐛 Debugging Tips

### Check backend logs
```
📥 POST /reviews/prof_123/aggregate
✅ Token validated for user: user_123
📊 Starting average rating calculation
Found 12 reviews
✅ Calculated: average=4.5, total=12
✅ Average rating updated: prof_123 → 4.5
```

### Verify Firestore auditLogs
Open Firebase Console → Firestore → auditLogs collection
- Each transaction should create an audit log
- Contains: action, userId, data, timestamp

### Check contract state in Firestore
Open Firebase Console → Firestore → contracts collection
- Status should reflect your updates
- updatedAt should be current timestamp
- cancelledBy/cancellationReason if cancelled

---

## ✅ Checklist

- [ ] Backend starts without errors
- [ ] Health check responds
- [ ] Reviews endpoint responds with 200
- [ ] Valid contract status transitions work
- [ ] Invalid transitions are rejected
- [ ] Cancellation works with reason
- [ ] Audit logs are created
- [ ] JWT validation works
- [ ] Unauthorized requests are rejected
- [ ] Not found responses are correct

---

**Ready to test!** 🚀

If you encounter issues:
1. Check backend console for errors
2. Verify JWT_SECRET matches between frontend and backend
3. Check Firestore rules allow reads/writes
4. Verify contract/professional data exists in Firestore
