# Postman Collection - Complete API Analysis

## Executive Summary

This document provides a comprehensive analysis of the Postman collection for the Havenly apartment rental application API. The collection contains **50+ endpoints** organized into **8 main feature groups**, supporting both tenant and owner functionalities with a Laravel/PHP backend.

---

## 1. Collection Structure Overview

### 1.1 Main Groups
1. **auth** - Authentication & User Management (8 endpoints)
2. **media** - Media/File Upload Management (3 endpoints)
3. **App** - Main Application Features (7 sub-groups)
   - apartment (6 endpoints)
   - apartment photo (5 endpoints)
   - Governorate (1 endpoint)
   - Favorite (3 endpoints)
   - Review (5 endpoints)
   - reservation request (5 endpoints)
   - reservation (5 endpoints)
   - reservation modification (5 endpoints)
   - notification (3 endpoints)
4. **Dashboard** - Admin Dashboard Features (3 sub-groups)
   - User (5 endpoints)
   - system (1 endpoint)
   - notification (3 endpoints - duplicate)

### 1.2 Base Configuration
- **Base URL Variable**: `{{baseUrl}}`
- **Authentication**: Bearer Token (stored in `{{token}}`)
- **Backend**: PHP 8.2.12 (Laravel)
- **API Format**: RESTful JSON API
- **CORS**: Enabled (`Access-Control-Allow-Origin: *`)

---

## 2. Authentication Endpoints (`/auth`)

### 2.1 Endpoints Summary

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| POST | `/auth/register` | ❌ | User registration |
| POST | `/auth/login` | ❌ | User login |
| GET | `/auth/me` | ✅ | Get current user profile |
| POST | `/auth/update-profile` | ✅ | Update user profile |
| POST | `/auth/logout` | ✅ | User logout |
| POST | `/auth/reset-password` | ✅ | Reset password |
| POST | `/auth/send-otp` | ❌ | Send OTP for verification |
| POST | `/auth/verify-otp` | ❌ | Verify OTP |

### 2.2 Request/Response Patterns

#### Register Request
```json
{
  "phone": "963974516435",
  "password": "123456789",
  "password_confirmation": "123456789",
  "first_name": "first name",
  "last_name": "last name",
  "username": "username5", // Optional
  "date_of_birth": "2025-12-08",
  "id_photo": 1,  // Media ID
  "personal_photo": 1  // Media ID
}
```

#### Register Response
```json
{
  "data": {
    "token": "2|p1UCPlc9ULigTF2W9HYApJyul54cj0GS3EWLoQR5951a9121",
    "user": {
      "id": 4,
      "phone": "963964587365",
      "first_name": "first name",
      "last_name": "last name",
      "username": "username1",
      "date_of_birth": "2025-12-08",
      "role_id": null,
      "id_photo": 5,
      "personal_photo": 6,
      "status": null
    }
  }
}
```

#### Login Request
```json
{
  "phone": "963944068317",
  "password": "password"
}
```

#### Login Response
```json
{
  "data": {
    "token": "7|z9kIQCdrv9akvAGTSBLDfiDvMykBv4zncSFpHTC1ba402b34",
    "user": {
      "id": 5,
      "phone": "963964587965",
      "first_name": "first name",
      "last_name": "last name",
      "username": "username2",
      "date_of_birth": "2025-12-08",
      "role": "user",
      "id_photo": 5,
      "personal_photo": 6,
      "status": 2
    }
  }
}
```

#### Me Response (Different Structure!)
```json
{
  "id": 5,
  "phone": "963964587965",
  "first_name": "first name",
  "last_name": "last name",
  "username": "username2",
  "date_of_birth": "2025-12-08",
  "role": "user",
  "id_photo": 5,
  "personal_photo": 6,
  "status": 2
}
```

**⚠️ Issue**: `/auth/me` returns direct object, not wrapped in `data` like other endpoints.

### 2.3 Authentication Flow
1. **Register/Login** → Returns token in `data.token`
2. **Token Storage** → Postman script saves to `{{token}}` variable
3. **Subsequent Requests** → Use Bearer token authentication
4. **Token Format** → `{id}|{hash}` (Laravel Sanctum format)

### 2.4 Issues Identified
- ❌ Inconsistent response structure (`/auth/me` vs others)
- ❌ OTP endpoints have swapped names (`send-otp` actually verifies, `verify-otp` actually sends)
- ⚠️ Reset password requires authentication (should be unauthenticated?)

---

## 3. Media Endpoints (`/media`)

### 3.1 Endpoints

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| GET | `/media/:id` | ❌ | Get media by ID |
| POST | `/media` | ❌ | Upload single media file |
| POST | `/media/store-many` | ✅ | Upload multiple media files |

### 3.2 Upload Request Format

#### Single Upload
```
FormData:
- medium: [File]
- type: "1" (1 = Image, other types exist)
- for: "personal-photo" | "id-photo" | "apartment-photo"
```

#### Multiple Upload
```
FormData:
- media[0][medium]: [File]
- media[0][type]: "1"
- media[0][for]: "id-photo"
- media[1][medium]: [File]
- media[1][type]: "1"
- media[1][for]: "personal-photo"
```

#### Upload Response
```json
{
  "id": 8,
  "name": "Features__Basic_style_Sheer__Opaque_Stretch_-removebg-preview.png",
  "url": "http://127.0.0.1:8000/storage/media/personal/photo/d9Mc2B8JaU114A4pJ5UW9twtZzCYLg8A0rXlhZAX.png",
  "extension": "png",
  "type": 1,
  "for": "personal-photo",
  "createdAt": "2025-12-10T22:10:09.000000Z",
  "createdBy": null
}
```

### 3.3 Media Types
- `personal-photo` - User profile photo
- `id-photo` - User ID document
- `apartment-photo` - Apartment listing photos

### 3.4 Issues Identified
- ❌ Single upload doesn't require auth, but store-many does (inconsistent)
- ⚠️ Content-Type header duplication in some requests

---

## 4. Apartment Endpoints (`/apartment`)

### 4.1 Endpoints

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| GET | `/apartment` | ✅ | List apartments with filters |
| GET | `/apartments/available` | ✅ | Get available apartments |
| POST | `/apartment/` | ✅ | Create new apartment |
| GET | `/apartment/:id` | ✅ | Get apartment details |
| PUT | `/apartment/:id` | ✅ | Update apartment |
| DELETE | `/apartment/:id` | ✅ | Delete apartment |

### 4.2 Query Parameters (List Endpoint)

```
GET /apartment?
  keyword=الطيبة&
  filters[0][name]=governorate&
  filters[0][operation]=eq&
  filters[0][value]=1&
  orders[0][name]=price&
  orders[0][direction]=asc&
  perPage=10&
  page=1
```

**Filter Operations**: `eq` (equals), likely supports others
**Order Directions**: `asc`, `desc`

### 4.3 Create/Update Request

```json
{
  "title": {
    "en": "apartment",
    "ar": "شقة جيدة"
  },
  "description": {
    "en": "new apartment",
    "ar": "شقة جديدة"
  },
  "price": "300.00",
  "currency": "$",
  "governorate": 1,  // ID
  "city": {
    "en": "zakia",
    "ar": "زاكية"
  },
  "address": {
    "en": "damas",
    "ar": "دمشق"
  },
  "number_of_room": "4",
  "number_of_bathroom": "2",
  "area": "160",
  "floor": "1"
}
```

**Features**:
- ✅ Multi-language support (en/ar)
- ✅ Nested location data (governorate, city, address)
- ✅ Numeric fields as strings (needs conversion in Flutter)

### 4.4 List Response

```json
{
  "data": [
    {
      "id": 3,
      "title": "شقة جيدة",
      "description": "شقة جديدة",
      "price": "300.00",
      "currency": "$",
      "rate": 0,
      "governorate": "دمشق",
      "city": "زاكية",
      "address": "دمشق",
      "status": "available",
      "number_of_room": 4,
      "number_of_bathroom": 2,
      "area": 160,
      "floor": 1,
      "created_at": "2025-12-29"
    }
  ],
  "page": 0,
  "perPage": 15,
  "lastPage": 1,
  "total": 3
}
```

**Pagination**: Zero-indexed pages (page: 0 = first page)

### 4.5 Issues Identified
- ❌ Inconsistent endpoint naming (`/apartment` vs `/apartments/available`)
- ⚠️ Mixed data types (strings for price, numbers for rooms)
- ⚠️ Localized fields returned as single string (not object)

---

## 5. Apartment Photo Endpoints (`/apartment/:id/photo`)

### 5.1 Endpoints

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| POST | `/apartment/:id/photo` | ✅ | Upload apartment photo |
| GET | `/apartment/:id/photo` | ✅ | Get all photos for apartment |
| DELETE | `/apartment/:id/photo/:photoId` | ✅ | Delete specific photo |
| PUT | `/apartment/:id/photo/:photoId/main` | ✅ | Set main photo |
| GET | `/apartment/:id/photo/main` | ✅ | Get main photo |

### 5.2 Upload Format
```
FormData:
- media[0][medium]: [File]
- media[0][type]: "1"
- media[0][for]: "apartment-photo"
```

### 5.3 Issues Identified
- ⚠️ Same endpoint (`GET /apartment/:id/photo`) used for both list and main photo (different paths)

---

## 6. Governorate Endpoints (`/governorates`)

### 6.1 Endpoints

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| GET | `/governorates` | ❌ | Get all governorates |

**Note**: Simple list endpoint, no pagination visible in collection.

---

## 7. Favorite Endpoints (`/favorites` & `/apartment/:id/favorite`)

### 7.1 Endpoints

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| GET | `/favorites` | ✅ | Get user's favorites |
| POST | `/apartment/:id/favorite` | ✅ | Add to favorites |
| DELETE | `/apartment/:id/favorite` | ✅ | Remove from favorites |

### 7.2 Issues Identified
- ❌ Inconsistent endpoint structure (favorites list vs apartment-specific)

---

## 8. Review Endpoints (`/apartment/review`)

### 8.1 Endpoints

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| GET | `/apartment/review` | ✅ | Get all reviews (for apartment?) |
| POST | `/apartment/review/?apartment_id=1&rate=1` | ✅ | Create review |
| GET | `/apartment/review/:id` | ✅ | Get specific review |
| PUT | `/apartment/review/:id?rate=4` | ✅ | Update review rating |
| DELETE | `/apartment/review/:id` | ✅ | Delete review |

### 8.2 Create Review Request
```
POST /apartment/review/?apartment_id=1&rate=1
```
**Note**: Rating passed as query parameter, not body.

### 8.3 Issues Identified
- ❌ Rating in query params instead of body
- ⚠️ Unclear if GET returns all reviews or apartment-specific

---

## 9. Reservation Request Endpoints (`/reservation-requests`)

### 9.1 Endpoints

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| GET | `/reservation-requests` | ✅ | List user's reservation requests |
| POST | `/reservation-requests` | ✅ | Create reservation request |
| GET | `/reservation-requests/:id` | ✅ | Get request details |
| PUT | `/reservation-requests/:id` | ✅ | Update request |
| DELETE | `/reservation-requests/:id` | ✅ | Cancel request |

### 9.2 Create Request
```json
{
  "apartment_id": 1,
  "start_date": "2026-3-16",
  "end_date": "2026-3-17",
  "note": ""
}
```

**Date Format**: `YYYY-M-D` (inconsistent with other date formats)

### 9.3 Issues Identified
- ❌ Inconsistent date format (`2026-3-16` vs `2025-12-08`)

---

## 10. Reservation Endpoints (`/reservations`)

### 10.1 Endpoints

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| GET | `/reservations` | ✅ | List active reservations |
| GET | `/reservations/:id` | ✅ | Get reservation details |
| POST | `/reservation-requests/:id/accept` | ✅ | Accept request (owner) |
| POST | `/reservation-requests/:id/reject` | ✅ | Reject request (owner) |

**Note**: Accept/Reject are on reservation-requests endpoint, not reservations.

---

## 11. Reservation Modification Endpoints

### 11.1 Endpoints

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| GET | `/reservation-modifications` | ✅ | List modifications |
| GET | `/reservation-modifications/:id` | ✅ | Get modification details |
| POST | `/reservations/:id/modifications` | ✅ | Request modification (user) |
| POST | `/modifications/:id/accept` | ✅ | Accept modification (owner) |
| POST | `/modifications/:id/reject` | ✅ | Reject modification (owner) |

### 11.2 Modification Request
```json
{
  "type": "end_date",
  "new_value": "2026-2-25"
}
```

**Modification Types**: `end_date`, likely `start_date` also supported

### 11.3 Issues Identified
- ❌ Inconsistent endpoint naming (`/reservation-modifications` vs `/modifications`)

---

## 12. Notification Endpoints (`/notifications`)

### 12.1 Endpoints

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| GET | `/notifications` | ✅ | Get user notifications |
| GET | `/notifications/unread-count` | ✅ | Get unread count |
| POST | `/notifications/read` | ✅ | Mark all as read |

### 12.2 Notification Response
```json
{
  "data": [
    {
      "id": 500000,
      "title": "تسجيل مستخدم جديد",
      "body": "تم تسجيل مستخدم جديد في النظام 11 first name.",
      "type": 2,
      "data": {
        "item_id": 11
      },
      "read_at": "2025-12-29T19:56:37.000000Z",
      "created_at": "2025-12-28T22:03:10.000000Z",
      "updated_at": "2025-12-29T19:56:37.000000Z"
    }
  ],
  "page": 0,
  "perPage": 15,
  "lastPage": 1,
  "total": 1
}
```

**Notification Types**: Integer (2 = new user registration, others exist)

### 12.3 Unread Count Response
```json
{
  "unread_count": 0
}
```

---

## 13. Dashboard Endpoints (Admin)

### 13.1 User Management (`/users`)

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| GET | `/users` | ✅ | List users (with filters) |
| POST | `/users` | ✅ | Create user (admin) |
| GET | `/users/:id` | ✅ | Get user details |
| PUT | `/users/:id` | ✅ | Update user |
| DELETE | `/users/:id` | ✅ | Delete user |

### 13.2 System Data (`/system-data`)

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| GET | `/system-data` | ✅ | Get system statistics/data |

**Note**: No response example in collection.

---

## 14. Common Patterns & Standards

### 14.1 Response Structure

#### Success Response (Most Endpoints)
```json
{
  "data": [...],  // or single object
  "page": 0,
  "perPage": 15,
  "lastPage": 1,
  "total": 3
}
```

#### Error Response
```json
{
  "message": "Unauthenticated."
}
```

### 14.2 Headers

**Common Headers**:
- `Accept: application/json`
- `Content-Type: application/json`
- `Accept-Language: ar` | `en` (for localization)
- `Authorization: Bearer {token}` (for authenticated endpoints)

### 14.3 Authentication

**Token Format**: `{id}|{hash}` (Laravel Sanctum)
**Storage**: Postman environment variable `{{token}}`
**Auto-save**: Postman test scripts save token from login/register responses

### 14.4 Localization

- **Header**: `Accept-Language: ar` or `en`
- **Multi-language Fields**: `title`, `description`, `city`, `address` support `{"en": "...", "ar": "..."}`
- **Response Language**: Backend returns localized strings based on header

### 14.5 Pagination

- **Zero-indexed**: `page: 0` = first page
- **Parameters**: `page`, `perPage`
- **Response**: `page`, `perPage`, `lastPage`, `total`

### 14.6 Filtering

**Format**:
```
filters[0][name]=governorate
filters[0][operation]=eq
filters[0][value]=1
```

**Operations**: `eq` (equals) - others likely supported but not documented

### 14.7 Ordering

**Format**:
```
orders[0][name]=price
orders[0][direction]=asc
```

**Directions**: `asc`, `desc`

---

## 15. Issues & Inconsistencies

### 15.1 Critical Issues

1. **Inconsistent Response Structure**
   - `/auth/me` returns direct object, not wrapped in `data`
   - Most endpoints wrap in `data` object

2. **Endpoint Naming Inconsistencies**
   - `/apartment` vs `/apartments/available`
   - `/reservation-modifications` vs `/modifications`
   - `/favorites` vs `/apartment/:id/favorite`

3. **Date Format Inconsistencies**
   - Registration: `2025-12-08` (ISO format)
   - Reservations: `2026-3-16` (inconsistent format)
   - Should standardize to ISO 8601

4. **OTP Endpoint Naming**
   - `send-otp` endpoint actually verifies OTP
   - `verify-otp` endpoint actually sends OTP
   - Names are swapped!

5. **Authentication Requirements**
   - `/media` (single) doesn't require auth
   - `/media/store-many` requires auth
   - Inconsistent security model

### 15.2 Medium Priority Issues

6. **Data Type Inconsistencies**
   - Price as string: `"300.00"`
   - Rooms as number: `4`
   - Should be consistent

7. **Query Parameters in Body**
   - Review rating in query params instead of body
   - Should use body for POST requests

8. **Missing Response Examples**
   - Many endpoints have empty `response` arrays
   - Makes integration harder

9. **Content-Type Header Duplication**
   - Some requests have duplicate `Content-Type` headers
   - Should be single header

10. **Localized Response Format**
    - Create/Update accepts: `{"en": "...", "ar": "..."}`
    - List returns: Single string (localized based on header)
    - Inconsistent structure

### 15.3 Low Priority Issues

11. **Variable Naming**
    - Collection variable: `baseUrl\n` (has newline character)
    - Should be cleaned

12. **Empty Body in Some Requests**
    - DELETE requests have empty body (correct)
    - Some PUT requests have empty body (should have data?)

13. **Missing Pagination**
    - Governorates endpoint doesn't show pagination
    - May not support it, or not documented

---

## 16. API Design Recommendations

### 16.1 Standardization

1. **Response Structure**: Always wrap in `data` object
2. **Date Format**: Use ISO 8601 consistently (`YYYY-MM-DD`)
3. **Endpoint Naming**: Use consistent plural/singular forms
4. **Data Types**: Standardize numeric vs string types
5. **Error Format**: Consistent error response structure

### 16.2 Security

1. **Authentication**: Consistent auth requirements
2. **Media Upload**: All uploads should require auth
3. **Token Refresh**: No refresh token endpoint visible

### 16.3 Documentation

1. **Response Examples**: Add examples for all endpoints
2. **Error Codes**: Document all possible error responses
3. **Filter Operations**: Document all supported filter operations
4. **Pagination**: Clarify which endpoints support pagination

---

## 17. Flutter Integration Notes

### 17.1 Models Needed

1. **Auth Models**
   - `AuthResponseModel` ✅ (exists)
   - `UserModel` ✅ (exists)
   - `RegisterRequestModel`
   - `LoginRequestModel`

2. **Apartment Models**
   - `ApartmentModel` ✅ (exists)
   - `ApartmentListResponseModel`
   - `ApartmentFilterModel`
   - `ApartmentCreateRequestModel`

3. **Media Models**
   - `MediaModel`
   - `MediaUploadResponseModel`

4. **Reservation Models**
   - `ReservationRequestModel`
   - `ReservationModel`
   - `ReservationModificationModel`

5. **Other Models**
   - `NotificationModel`
   - `ReviewModel`
   - `FavoriteModel`
   - `GovernorateModel`

### 17.2 Service Layer Structure

```
services/
├── auth_service.dart
├── apartment_service.dart
├── media_service.dart
├── reservation_service.dart
├── review_service.dart
├── favorite_service.dart
├── notification_service.dart
└── governorate_service.dart
```

### 17.3 Key Implementation Considerations

1. **Multi-language Support**
   - Handle `{"en": "...", "ar": "..."}` format
   - Extract based on current locale

2. **Date Handling**
   - Parse inconsistent date formats
   - Standardize to `DateTime` objects

3. **Pagination**
   - Zero-indexed pages (convert to 1-indexed if needed)
   - Implement infinite scroll or load more

4. **File Upload**
   - Use `FormData` for multipart uploads
   - Handle array format for multiple files

5. **Error Handling**
   - Parse `{"message": "..."}` format
   - Handle 401 (unauthorized) for token refresh

6. **Token Management**
   - Store token from login/register
   - Add to all authenticated requests
   - Handle token expiration

---

## 18. Summary Statistics

- **Total Endpoints**: ~50+
- **Authenticated Endpoints**: ~40+
- **Public Endpoints**: ~10
- **File Upload Endpoints**: 3
- **Main Features**: 8 groups
- **Response Formats**: Mostly consistent (except `/auth/me`)
- **Pagination Support**: Most list endpoints
- **Multi-language Support**: Yes (en/ar)
- **Date Format Issues**: 2+ inconsistencies
- **Naming Inconsistencies**: 5+ issues

---

## 19. Next Steps for Flutter Development

1. ✅ **Create Service Classes** for each feature group
2. ✅ **Create Model Classes** matching API responses
3. ⚠️ **Handle Inconsistencies** in service layer
4. ⚠️ **Implement Error Handling** for all endpoints
5. ⚠️ **Add Token Refresh** mechanism
6. ⚠️ **Standardize Date Parsing** across app
7. ⚠️ **Implement File Upload** with proper FormData
8. ⚠️ **Add Pagination Helpers** for list endpoints
9. ⚠️ **Create API Response Wrappers** for consistent parsing

---

## Conclusion

The API is well-structured overall but has several inconsistencies that need to be handled in the Flutter application. The main areas of concern are:

1. **Response structure inconsistencies** (especially `/auth/me`)
2. **Date format variations**
3. **Endpoint naming inconsistencies**
4. **Missing response examples** for many endpoints

The Flutter app should implement a robust service layer that handles these inconsistencies gracefully, with proper error handling and data transformation.
