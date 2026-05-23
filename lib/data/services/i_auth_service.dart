import '../models/user_model.dart';

// ┌──────────────────────────────────────────────────────────────┐
// │  SERVICE LAYER                                               │
// │                                                              │
// │  A Service is a thin wrapper around ONE data source          │
// │  (a REST API, a GraphQL endpoint, a local SQLite DB…).       │
// │                                                              │
// │  Its ONLY jobs:                                              │
// │    1. Make the raw network/IO call                           │
// │    2. Parse the response into a DTO (UserModel)              │
// │    3. Throw on HTTP errors                                   │
// │                                                              │
// │  It does NOT:                                                │
// │    ✗ Cache data                                              │
// │    ✗ Convert DTOs → domain entities                          │
// │    ✗ Combine data from multiple sources                      │
// │    ✗ Implement any business rule                             │
// │                                                              │
// │  Think of it as a "typed HTTP client for one resource."      │
// └──────────────────────────────────────────────────────────────┘
abstract class IAuthService {
  Future<UserModel> login({required String email, required String password});
  Future<void> logout();
}
