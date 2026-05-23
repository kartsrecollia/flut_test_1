import '../../domain/entities/user.dart';

// ┌──────────────────────────────────────────────────────────────┐
// │  REPOSITORY LAYER                                            │
// │                                                              │
// │  A Repository is the single source of truth for a domain    │
// │  concept. It sits BETWEEN the Service and the business       │
// │  logic (Cubits/Blocs). It:                                   │
// │                                                              │
// │    1. Converts DTOs → domain entities (User, not UserModel)  │
// │    2. Caches / persists data locally when needed             │
// │    3. Combines multiple Services into one coherent API       │
// │       (e.g. merge AuthService + ProfileService)              │
// │    4. Maps low-level HTTP errors → domain exceptions         │
// │    5. Manages reactive state via streams                     │
// │                                                              │
// │  Key difference from a Service:                              │
// │    Service  = "talk to ONE endpoint, give me raw data"       │
// │    Repository = "give me the truth about Users, I don't      │
// │                  care where it comes from"                   │
// │                                                              │
// │  Cubits depend on IAuthRepository (the interface), not on    │
// │  a concrete class — that's what makes everything testable.   │
// └──────────────────────────────────────────────────────────────┘
abstract class IAuthRepository {
  /// Emits the logged-in [User], or null after logout.
  /// GoRouter listens here to redirect on auth changes.
  Stream<User?> get authStateStream;

  /// The currently signed-in user, or null if logged out.
  User? get currentUser;

  Future<User> login({required String email, required String password});
  Future<void> logout();
}
