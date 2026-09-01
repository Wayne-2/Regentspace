// Static UI only — no Riverpod / Supabase. Simple mock provider.
// This file is kept to avoid broken imports but does nothing.
import 'model.dart';

// Mock global user — static demo
UserModel mockUser = UserModel.mock;

// Stub to satisfy old imports (not used in static build)
class UserNotifier {
  UserModel? state = UserModel.mock;
  void setUser(UserModel user) => state = user;
  void clearUser() => state = null;
}

final userProvider = mockUser;
