# 🚀 Backend Implementation Guide

**Status**: Ready for Implementation  
**Duration**: 8-10 hours  
**Complexity**: Medium  
**Priority**: High (Phase 2 of Layer Separation Audit)

---

## 📋 Overview

This document contains the complete specification for implementing the backend for the App Sanitária project. The frontend and Firebase rules are already production-ready (see `FINAL_DOCUMENTATION.md` for context).

**Backend Responsibility**: Implement 2 critical services:
1. **ReviewsService** - Calculate average ratings with ACID transactions
2. **ContractsService** - Validate contract status transitions

---

## 🎯 What Needs to Be Implemented

### **Service 1: ReviewsService**
**File**: `backend/lib/features/reviews/domain/services/reviews_service.dart`

**Responsibility**: Calculate average rating with ACID transaction + auditing

**Method**: `Future<Map<String, dynamic>> calculateAverageRating(String professionalId)`

**Logic**:
1. Fetch all reviews for professional from Firestore
2. Calculate: sum(ratings) / count
3. ACID transaction:
   - Update professional document with new rating
   - Log audit entry
4. Return success with new rating

**Full Specification**: See `PR_1_2_BACKEND_SPEC.md` (included)

---

### **Service 2: ContractsService**
**File**: `backend/lib/features/contracts/domain/services/contracts_service.dart`

**Responsibility**: Validate and update contract status with ACID transaction + auditing

**Methods**:
1. `Future<Map> updateContractStatus(String contractId, String newStatus, String userId)`
2. `Future<Map> cancelContract(String contractId, String userId, String reason)`

**Logic**:
1. Validate contract exists
2. Validate status transition is valid (state machine)
3. Validate user has permission
4. ACID transaction:
   - Update contract status
   - Log audit entry
5. Return success

**Valid Transitions**:
```
pending    → [accepted, rejected, cancelled]
accepted   → [completed, cancelled]
rejected   → [cancelled]
completed  → [] (terminal)
cancelled  → [] (terminal)
```

**Full Specification**: See `PR_1_3_BACKEND_SPEC.md` (included)

---

### **Controller 1: ReviewsController**
**File**: `backend/lib/features/reviews/presentation/controllers/reviews_controller.dart`

**Endpoints**:
1. `POST /api/v1/reviews/{professionalId}/aggregate` - Calculate average rating
   - Authorization: Bearer JWT
   - Body: {} (empty)
   - Response: { success: bool, data: { professionalId, average, count } }

---

### **Controller 2: ContractsController**
**File**: `backend/lib/features/contracts/presentation/controllers/contracts_controller.dart`

**Endpoints**:
1. `PATCH /api/v1/contracts/{contractId}/status` - Update status
   - Authorization: Bearer JWT
   - Body: { newStatus: string }
   - Response: { success: bool, data: { contractId, status, updatedAt } }

2. `PATCH /api/v1/contracts/{contractId}/cancel` - Cancel contract
   - Authorization: Bearer JWT
   - Body: { reason: string }
   - Response: { success: bool, data: { contractId, status, cancelledBy, reason } }

---

### **Service 3: AuthService** (if not exists)
**File**: `backend/lib/features/auth/domain/services/auth_service.dart`

**Responsibility**: Validate JWT tokens

**Method**: `Future<String?> validateToken(String token)`

**Logic**:
1. Decode JWT
2. Verify signature
3. Check expiration
4. Return userId or null

---

### **Service 4: AuditService** (if not exists)
**File**: `backend/lib/features/audit/domain/services/audit_service.dart`

**Responsibility**: Log all critical actions

**Method**: `Future<void> logAction(String action, String userId, Map<String, dynamic> data)`

**Logs to**: Firestore `auditLogs` collection

---

## 🔌 How Backend Integrates with Frontend

### **Frontend to Backend Communication**

**Frontend calls ReviewsService**:
```
POST /api/v1/reviews/{professionalId}/aggregate
Authorization: Bearer {JWT_TOKEN}
Body: {}

Response: {
  "success": true,
  "data": {
    "professionalId": "prof_123",
    "average": 4.5,
    "count": 10,
    "updatedAt": "2025-10-27T10:00:00Z"
  }
}
```

**Frontend calls ContractsService**:
```
PATCH /api/v1/contracts/{contractId}/status
Authorization: Bearer {JWT_TOKEN}
Body: { "newStatus": "accepted" }

Response: {
  "success": true,
  "data": {
    "contractId": "contract_123",
    "status": "accepted",
    "updatedAt": "2025-10-27T10:00:00Z"
  }
}
```

### **Backend to Firestore Communication**

**ACID Transaction Example**:
```dart
await firestore.runTransaction((transaction) async {
  // 1. Update professional rating
  transaction.update(profDoc, {
    'avaliacao': newAverage,
    'updatedAt': FieldValue.serverTimestamp(),
  });
  
  // 2. Log audit
  transaction.set(auditDoc, {
    'action': 'review.average_calculated',
    'professionalId': professionalId,
    'average': newAverage,
    'count': reviewsCount,
    'timestamp': FieldValue.serverTimestamp(),
  });
});
```

### **Security Layers**

```
Layer 1: Frontend UseCase
├─ Validate data format
├─ Show immediate feedback
└─ User sees errors before HTTP call

Layer 2: Backend Validation
├─ Validate JWT token (authentication)
├─ Validate business rules (authorization)
├─ Validate data again (defense in depth)
└─ ACID transaction ensures consistency

Layer 3: Firestore Rules
├─ isValidRating() - Blocks invalid ratings
├─ isValidStatusTransition() - Blocks invalid transitions
├─ isNotBlocked() - Blocks if user is blocked
└─ Field-level validation
```

---

## 📊 Data Models

### **Review Document** (Firestore)
```
{
  "id": "review_123",
  "professionalId": "prof_123",
  "userId": "user_456",
  "rating": 4.5,
  "comment": "Excelente profissional",
  "createdAt": timestamp,
  "updatedAt": timestamp
}
```

### **Contract Document** (Firestore)
```
{
  "id": "contract_123",
  "patientId": "patient_123",
  "professionalId": "prof_456",
  "status": "pending",  // pending, accepted, rejected, completed, cancelled
  "serviceType": "Limpeza",
  "address": "Rua A, 123",
  "date": "2025-11-15",
  "duration": 4,
  "value": 150.00,
  "createdAt": timestamp,
  "updatedAt": timestamp
}
```

### **Professional Document** (Firestore)
```
{
  "id": "prof_123",
  "name": "João Silva",
  "avaliacao": 4.5,  // Average rating (updated by backend)
  "avaliacao_count": 10,
  "updatedAt": timestamp
}
```

### **Audit Log Document** (Firestore)
```
{
  "id": "audit_123",
  "action": "review.average_calculated",
  "userId": "user_456",
  "data": {
    "professionalId": "prof_123",
    "average": 4.5,
    "count": 10
  },
  "timestamp": timestamp
}
```

---

## ✅ Implementation Checklist

### **Phase 1: Setup (1 hour)**
- [ ] Create project structure
- [ ] Setup Firebase Firestore client
- [ ] Setup JWT validation library
- [ ] Setup HTTP routing

### **Phase 2: AuthService (1 hour)**
- [ ] Implement `validateToken()`
- [ ] Handle token errors
- [ ] Test with sample tokens

### **Phase 3: AuditService (1 hour)**
- [ ] Implement `logAction()`
- [ ] Save to Firestore auditLogs
- [ ] Test audit logging

### **Phase 4: ReviewsService (2 hours)**
- [ ] Implement `calculateAverageRating()`
- [ ] ACID transaction logic
- [ ] Error handling
- [ ] Unit tests

### **Phase 5: ReviewsController (1 hour)**
- [ ] Implement aggregate endpoint
- [ ] JWT validation
- [ ] Response formatting
- [ ] Error handling

### **Phase 6: ContractsService (2 hours)**
- [ ] Implement `updateContractStatus()`
- [ ] Implement `cancelContract()`
- [ ] Status transition validation
- [ ] ACID transactions
- [ ] Unit tests

### **Phase 7: ContractsController (1 hour)**
- [ ] Implement status endpoint
- [ ] Implement cancel endpoint
- [ ] JWT validation
- [ ] Response formatting

### **Phase 8: Testing & Deployment (2 hours)**
- [ ] Integration tests
- [ ] Deploy to staging
- [ ] Load testing
- [ ] Final validation

---

## 🧪 Testing Strategy

### **Unit Tests**
- AuthService JWT validation
- ReviewsService calculations
- ContractsService transition validation

### **Integration Tests**
- ReviewsController → ReviewsService → Firestore
- ContractsController → ContractsService → Firestore

### **Manual Tests**
- Test in emulator
- Test with staging database
- Test with production (final check)

---

## 🔒 Security Considerations

1. **JWT Validation**: Always validate tokens
2. **Permission Checks**: User can only modify their own data
3. **ACID Transactions**: Use transactions for consistency
4. **Error Handling**: Don't expose sensitive info
5. **Rate Limiting**: Prepare for future implementation
6. **Auditing**: Log all critical actions

---

## 📚 Reference Specifications

### **Full Backend Spec for Reviews**
See file: `PR_1_2_BACKEND_SPEC.md`
- Detailed endpoint specification
- Request/response formats
- Error handling
- Recommended code

### **Full Backend Spec for Contracts**
See file: `PR_1_3_BACKEND_SPEC.md`
- Detailed endpoint specification
- Status transition rules
- Permission validation
- Recommended code

---

## 🎯 Success Criteria

After implementation:

- [ ] All 4 endpoints working
- [ ] All unit tests passing
- [ ] Integration tests passing
- [ ] Firestore ACID transactions working
- [ ] Audit logging working
- [ ] JWT validation working
- [ ] Error handling comprehensive
- [ ] Performance acceptable (< 500ms per request)
- [ ] Deployed to staging
- [ ] Ready for production

---

## 📞 Questions About Frontend?

If you need to understand:
- **Frontend HTTP calls**: See `http_reviews_datasource.dart`
- **Frontend validation**: See `UpdateContractStatus` UseCase in `update_contract_status.dart`
- **Frontend architecture**: See `FINAL_DOCUMENTATION.md`

---

## 🚀 Ready to Start?

This backend implementation will complete the 3-layer security architecture:

```
Layer 1: Frontend ✅ (Done - Production Ready)
Layer 2: Firestore Rules ✅ (Done - Deploy Ready)
Layer 3: Backend ⏳ (Ready to Implement)
```

**Estimated Duration**: 8-10 hours for complete implementation

**Next Steps**:
1. Read `PR_1_2_BACKEND_SPEC.md` for Reviews implementation
2. Read `PR_1_3_BACKEND_SPEC.md` for Contracts implementation
3. Start with Phase 1 (Setup)
4. Follow the checklist
5. Test thoroughly
6. Deploy to staging
7. Final production release

---

**Created**: 27 October 2025  
**Status**: Ready for Implementation  
**Quality**: Production Grade
