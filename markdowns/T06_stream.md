# Riverpod Tutorial: Stream Provider for Auth State

# Starter Code

```dart
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

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

class AuthDisplayHandler extends StatelessWidget {
  const AuthDisplayHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthDisplay(uid: "user_12345");
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
```

## 2. Install and import Library

Install the Riverpod package:

```bash
flutter pub add flutter_riverpod
```

Import the Riverpod package:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

## 3. ProviderScope

For widgets to be able to read providers, we need to wrap the entire application in a "ProviderScope" widget. This is where the state of our providers will be stored.

```dart
void main() {
  runApp(
    // Wrap the entire app in ProviderScope
    ProviderScope(child: MyApp()),
  );
}
```

## 4. Create Provider for AuthService

This is the provider for our AuthService. We use a regular Provider here because we want to manage the lifecycle of AuthService manually.

```dart
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
```

## 5. Create StreamProvider for Auth State

We create a StreamProvider that listens to the auth state changes from AuthService. The StreamProvider will automatically handle listening and cancelling the stream subscription.

```dart
// StreamProvider to listen to auth state changes.
final authProvider = StreamProvider.autoDispose<String?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
```

Note that we use `autoDispose` here to automatically clean up the stream subscription when no longer needed. If we only use `StreamProvider` without `autoDispose`, we would need to manually manage the lifecycle of the stream subscription.

## 6. Use the StreamProvider in the Widget

Change AuthDisplayHandler to a ConsumerWidget to read the authProvider.

```dart
class AuthDisplayHandler extends ConsumerWidget {...}
```

Add the WidgetRef parameter to the build method:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {...}
```

Inside the build method, use ref.watch to listen to the authProvider:

```dart
final authState = ref.watch(authProvider);
```

`authState` is an AsyncValue, so we can use when to handle different states:

```dart
return authState.when(
    data: (uid) => AuthDisplay(uid: uid),
    loading: () => Center(child: CircularProgressIndicator()),
    error: (error, stack) => Center(child: Text("Error: $error")),
);
```

You should now have a working implementation of a StreamProvider that listens to auth state changes and updates the UI accordingly!
