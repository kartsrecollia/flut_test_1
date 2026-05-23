import 'dart:async';
import 'package:flutter/foundation.dart';

// Bridges a Stream<T> to a ChangeNotifier (Listenable) so GoRouter
// can call `redirect` whenever the stream emits a new value.
// This is the standard pattern for stream-driven GoRouter auth guards.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
