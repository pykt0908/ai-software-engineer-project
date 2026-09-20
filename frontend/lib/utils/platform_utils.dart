import 'platform_utils_stub.dart'
    if (dart.library.io) 'platform_utils_io.dart' as impl;

/// True when running under `flutter test` (VM). Always false on web.
bool get isFlutterTest => impl.isFlutterTest;
