import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/main.dart';

const List<int> _kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUrl ||
        invocation.memberName == #openUrl ||
        invocation.memberName == #open ||
        invocation.memberName == #get) {
      return Future<HttpClientRequest>.value(_MockHttpClientRequest());
    }
    return null;
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close) {
      return Future<HttpClientResponse>.value(_MockHttpClientResponse());
    }
    return null;
  }
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  @override
  final HttpHeaders headers = _MockHttpHeaders();
  @override
  final int statusCode = 200;
  @override
  final int contentLength = _kTransparentImage.length;
  @override
  final HttpClientResponseCompressionState compressionState =
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('InstaCat app loads and shows OneTapLoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();
    expect(find.text('Insta'), findsOneWidget);
    expect(find.text('Cat'), findsOneWidget);
    expect(find.text('mochi_the_ragdoll'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Switch accounts'), findsOneWidget);
  });

  testWidgets('Navigation between OneTapLoginScreen and LoginScreen works', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    // Tap Switch accounts to go to full LoginScreen
    await tester.tap(find.text('Switch accounts'));
    await tester.pumpAndSettle();

    // Verify LoginScreen is shown
    expect(find.text('Log in with Facebook'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('One-Tap Login as @mochi_the_ragdoll'), findsOneWidget);

    // Tap to return to OneTapLoginScreen
    await tester.tap(find.text('One-Tap Login as @mochi_the_ragdoll'));
    await tester.pumpAndSettle();

    expect(find.text('Switch accounts'), findsOneWidget);
  });

  testWidgets('Explore screen search bar renders correctly after login', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    // One-tap log in
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    // Tap on Explore tab in bottom navigation bar
    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Search cats, breeds, #hashtags...'), findsOneWidget);
    expect(find.text('Trending'), findsOneWidget);
    expect(find.text('Reels'), findsOneWidget);
  });

  testWidgets('Tapping bell button in top bar navigates to NotificationScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    // One-tap log in
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    // Tap bell icon on the top bar
    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pumpAndSettle();

    // Verify NotificationScreen content
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Likes'), findsOneWidget);
    expect(find.text('Comments'), findsOneWidget);
    expect(find.text('Follows'), findsOneWidget);
    expect(find.text('Treats'), findsOneWidget);
    expect(find.text('New'), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) =>
          widget is RichText && widget.text.toPlainText().contains('biscuit_paw')),
      findsWidgets,
    );

    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    // Back on Feed
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
  });

  testWidgets('Tapping Sign up from OneTapLoginScreen navigates to RegisterScreen and back', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    // Tap "Sign up."
    await tester.tap(find.text('Sign up.'));
    await tester.pumpAndSettle();

    // Verify RegisterScreen is shown
    expect(find.text('Sign up to share and discover adorable cat moments 🐾'), findsOneWidget);
    expect(find.text('Username (e.g. fluffy_cat)'), findsOneWidget);
    expect(find.text('Email address (e.g. cat@example.com)'), findsOneWidget);
    expect(find.text('Password (min 6 characters)'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Already have an account?'), findsOneWidget);

    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    // Back on OneTapLoginScreen
    expect(find.text('Switch accounts'), findsOneWidget);
  });

  testWidgets('RegisterScreen validates required fields on submit', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    // Tap "Sign up."
    await tester.tap(find.text('Sign up.'));
    await tester.pumpAndSettle();

    // Tap "Sign Up" button without filling inputs
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pumpAndSettle();

    // Expect validation message
    expect(find.text('Please fill in all required fields'), findsOneWidget);
  });

  testWidgets('Logging out from ProfileScreen returns to OneTapLoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    // One-tap log in
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    // Navigate to Profile tab (last tab index 4)
    await tester.tap(find.byKey(const ValueKey('nav_profile')));
    await tester.pumpAndSettle();

    // Open options menu (hamburger icon)
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Tap Log Out option in bottom sheet
    await tester.tap(find.widgetWithText(ListTile, 'Log Out'));
    await tester.pumpAndSettle();

    // Verify confirmation dialog is displayed
    expect(find.text('Log Out'), findsWidgets);
    expect(find.text('Cancel'), findsOneWidget);

    // Confirm logout by tapping Log Out button in dialog
    await tester.tap(find.widgetWithText(ElevatedButton, 'Log Out'));
    await tester.pumpAndSettle();

    // Verify returned to OneTapLoginScreen
    expect(find.text('Switch accounts'), findsOneWidget);
  });
}

