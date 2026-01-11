import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

void main() {
  runApp(
    // Wrap the entire app in ProviderScope
    ProviderScope(
      child: MyApp(),
      retry: (retryCount, error) => null,
    ),
  );
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

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  print("Creating AuthService");
  final authService = AuthService();
  authService.autoChangeState();

  // Logic to run on dispose
  ref.onDispose(() {
    print("Disposing AuthService");
    // authService.dispose(); This is optional since I already use StreamProvider.autoDispose
  });
  return authService;
});

// StreamProvider to listen to auth state changes. The use of autoDispose is to clean up when not needed.
final authProvider = StreamProvider.autoDispose<String?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Auth State (Stream)")),
        body: AuthDisplayHandler(),
      ),
    );
  }
}

class AuthDisplayHandler extends ConsumerWidget {
  const AuthDisplayHandler({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return authState.when(
      data: (uid) => AuthDisplay(uid: uid),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text("Error: $error")),
    );
  }
}

class AuthDisplay extends StatelessWidget {
  final String? uid;
  const AuthDisplay({super.key, this.uid});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: uid == null
          ? Text("User is logged out")
          : Text("User is logged in with UID: $uid"),
    );
  }
}
