import 'dart:async';

void main() {
  final authService = AuthService();
  authService.autoChangeState();

  // Listen to auth state changes
  authService.authStateChanges.listen((uid) {
    if (uid != null) {
      print("User logged in with UID: $uid");
    } else {
      print("User logged out");
    }
  });
}

// Simulated auth service with stream
class AuthService {
  // The Stream returned by stream is a broadcast stream. It can be listened to more than once.
  final _controller = StreamController<String?>.broadcast();
  Stream<String?> get authStateChanges => _controller.stream;

  void simulateLogin(String uid) => _controller.add(uid);
  void simulateLogout() => _controller.add(null);
  void dispose() => _controller.close();
  void autoChangeState() {
    // Simulate auth state changes
    Timer.periodic(Duration(seconds: 2), (timer) {
      if (timer.tick % 2 == 0) {
        simulateLogin("user_${timer.tick}");
      } else {
        simulateLogout();
      }
    });
  }
}
