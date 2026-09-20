import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/data/mock_data.dart';
import 'package:frontend/main.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/screens/feed_screen.dart';
import 'package:frontend/screens/main_shell.dart';

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

Future<void> _seedLastUser() async {
  await AuthService().saveLastUser(
    MockData.currentUser,
    identifier: 'mochi_the_ragdoll',
    password: 'password123',
  );
}

Future<void> _loginFromSwitchScreen(WidgetTester tester) async {
  final fields = find.byType(TextField);
  expect(fields, findsAtLeastNWidgets(2));
  await tester.enterText(fields.at(1), 'password123');
  await tester.pump();
  await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
    FlutterSecureStorage.setMockInitialValues({});
  });

  setUp(() async {
    AuthService().resetForTest();
    FlutterSecureStorage.setMockInitialValues({
      'instacat_last_password': 'password123',
    });
    await _seedLastUser();
  });

  testWidgets('InstaCat app loads and shows SwitchAccountScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();
    expect(find.text('Insta'), findsOneWidget);
    expect(find.text('Cat'), findsOneWidget);
    expect(find.text('Switch accounts'), findsOneWidget);
    expect(find.text('mochi_the_ragdoll'), findsWidgets);
    expect(find.widgetWithText(ElevatedButton, 'Log In'), findsOneWidget);
  });

  testWidgets('First-run SwitchAccountScreen has no fake mochi user', (WidgetTester tester) async {
    AuthService().resetForTest();
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    expect(find.text('Switch accounts'), findsOneWidget);
    expect(find.text('mochi_the_ragdoll'), findsNothing);
    expect(find.text('Sign up.'), findsOneWidget);
    expect(find.text('Tap to use this account'), findsNothing);
  });

  testWidgets('SwitchAccountScreen shows username and password fields', (WidgetTester tester) async {
    AuthService().resetForTest();
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    final textFields = tester.widgetList<TextField>(find.byType(TextField)).toList();
    expect(textFields.length, 2);
    expect(textFields[0].controller?.text, isEmpty);
    expect(textFields[1].controller?.text, isEmpty);
    expect(find.text('Phone number, username, or email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('Explore screen search bar renders correctly after login', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    await _loginFromSwitchScreen(tester);

    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Search cats, breeds, #hashtags...'), findsOneWidget);
    expect(find.text('Trending'), findsOneWidget);
    expect(find.text('Reels'), findsOneWidget);
  });

  testWidgets('Tapping bell button in top bar navigates to NotificationScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    await _loginFromSwitchScreen(tester);

    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Likes'), findsOneWidget);
    expect(find.text('Comments'), findsOneWidget);
    expect(find.text('Follows'), findsOneWidget);
    expect(find.text('No notifications yet'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
  });

  testWidgets('Tapping Sign up from SwitchAccountScreen navigates to RegisterScreen and back', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign up.'));
    await tester.pumpAndSettle();

    expect(find.text('Sign up to share and discover adorable cat moments 🐾'), findsOneWidget);
    expect(find.text('Username (e.g. fluffy_cat)'), findsOneWidget);
    expect(find.text('Email address (e.g. cat@example.com)'), findsOneWidget);
    expect(find.text('Password (min 6 characters)'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Already have an account?'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    expect(find.text('Switch accounts'), findsOneWidget);
  });

  testWidgets('RegisterScreen validates required fields on submit', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign up.'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Please fill in all required fields'), findsOneWidget);
  });

  testWidgets('Logging out from ProfileScreen returns to SwitchAccountScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    await _loginFromSwitchScreen(tester);

    await tester.tap(find.byKey(const ValueKey('nav_profile')));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Log Out'));
    await tester.pumpAndSettle();

    expect(find.text('Log Out'), findsWidgets);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Log Out'));
    await tester.pumpAndSettle();

    expect(find.text('Switch accounts'), findsOneWidget);
  });

  testWidgets('Editing username updates and displays immediately on ProfileScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    await _loginFromSwitchScreen(tester);

    await tester.tap(find.byKey(const ValueKey('nav_profile')));
    await tester.pumpAndSettle();

    expect(find.text('mochi_the_ragdoll'), findsWidgets);

    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsOneWidget);

    final usernameField = find.widgetWithText(TextField, 'mochi_the_ragdoll');
    expect(usernameField, findsOneWidget);

    await tester.enterText(usernameField, 'new_cool_cat');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('new_cool_cat'), findsWidgets);
  });

  testWidgets('SwitchAccountScreen remembers last user after logout and logs in with password', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    expect(find.text('mochi_the_ragdoll'), findsWidgets);

    await _loginFromSwitchScreen(tester);

    await tester.tap(find.byKey(const ValueKey('nav_profile')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();

    final usernameField = find.widgetWithText(TextField, 'mochi_the_ragdoll');
    await tester.enterText(usernameField, 'persian_king');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('persian_king'), findsWidgets);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Log Out'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Log Out'));
    await tester.pumpAndSettle();

    expect(find.text('Switch accounts'), findsOneWidget);
    expect(find.text('persian_king'), findsWidgets);

    await _loginFromSwitchScreen(tester);

    expect(find.byType(MainShell), findsOneWidget);
    expect(find.text('Your Story'), findsOneWidget);
  });

  testWidgets('FeedScreen shows public feed without For You / Following toggle', (WidgetTester tester) async {
    AuthService().currentUserNotifier.value = MockData.currentUser;

    await tester.pumpWidget(
      const MaterialApp(
        home: FeedScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('For You'), findsNothing);
    expect(find.text('Following'), findsNothing);
    expect(find.byType(FeedScreen), findsOneWidget);
  });

  testWidgets('Searching users in ExploreScreen shows real search results and opens profile', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    await _loginFromSwitchScreen(tester);

    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();

    final searchField = find.widgetWithText(TextField, 'Search cats, breeds, #hashtags...');
    expect(searchField, findsOneWidget);

    await tester.enterText(searchField, 'milo');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('milo_the_scottish'), findsOneWidget);

    await tester.tap(find.text('milo_the_scottish'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('milo_the_scottish'), findsOneWidget);
  });
}
