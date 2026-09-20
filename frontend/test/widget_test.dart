import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/main.dart';
import 'package:frontend/services/auth_service.dart';
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

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
    FlutterSecureStorage.setMockInitialValues({});
  });

  setUp(() {
    AuthService().resetForTest();
    FlutterSecureStorage.setMockInitialValues({
      'instacat_last_password': 'password123',
    });
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
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);

    // Tap back button (chevron_left) to return to OneTapLoginScreen
    await tester.tap(find.byIcon(Icons.chevron_left));
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

  testWidgets('LoginScreen username and password fields have no predata', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    // Tap Switch accounts to open LoginScreen
    await tester.tap(find.text('Switch accounts'));
    await tester.pumpAndSettle();

    // Find all TextFields on LoginScreen
    final textFields = tester.widgetList<TextField>(find.byType(TextField)).toList();
    expect(textFields.length, 2);

    // Verify both are empty
    expect(textFields[0].controller?.text, isEmpty);
    expect(textFields[1].controller?.text, isEmpty);

    // Verify hint texts
    expect(find.text('Phone number, username, or email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('Editing username updates and displays immediately on ProfileScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    // Log in
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    // Navigate to Profile tab
    await tester.tap(find.byKey(const ValueKey('nav_profile')));
    await tester.pumpAndSettle();

    // Initially shows default username
    expect(find.text('mochi_the_ragdoll'), findsWidgets);

    // Tap Edit Profile
    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();

    // Verify EditProfileScreen is shown
    expect(find.text('Edit Profile'), findsOneWidget);

    // Find the username text field by searching for text 'mochi_the_ragdoll'
    final usernameField = find.widgetWithText(TextField, 'mochi_the_ragdoll');
    expect(usernameField, findsOneWidget);

    // Clear and enter new username
    await tester.enterText(usernameField, 'new_cool_cat');
    await tester.pumpAndSettle();

    // Tap Done (save) button
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Verify returned to ProfileScreen and 'new_cool_cat' is immediately displayed in the AppBar!
    expect(find.text('new_cool_cat'), findsWidgets);
  });

  testWidgets('OneTapLoginScreen remembers and displays the last logged in user after logout', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    // Initially displays default or first user
    expect(find.text('mochi_the_ragdoll'), findsOneWidget);

    // Log in
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    // Navigate to Profile tab
    await tester.tap(find.byKey(const ValueKey('nav_profile')));
    await tester.pumpAndSettle();

    // Edit profile username
    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();

    final usernameField = find.widgetWithText(TextField, 'mochi_the_ragdoll');
    await tester.enterText(usernameField, 'persian_king');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Verify username changed to persian_king
    expect(find.text('persian_king'), findsWidgets);

    // Now log out
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Log Out'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Log Out'));
    await tester.pumpAndSettle();

    // Returned to OneTapLoginScreen: verify it now displays 'persian_king'!
    expect(find.text('persian_king'), findsOneWidget);

    // Tapping 'Log In' after logout MUST require password!
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    // Verify Password Prompt Bottom Sheet is shown
    expect(find.text('Enter password to continue'), findsOneWidget);
    expect(find.text('Log in as @persian_king'), findsOneWidget);

    // Enter correct password and submit
    await tester.enterText(find.byKey(const ValueKey('input_modal_password')), 'password123');
    await tester.pumpAndSettle();

    // Tap Log In inside the bottom sheet
    await tester.tap(find.byKey(const ValueKey('btn_modal_login')));
    await tester.pumpAndSettle();

    // Successfully logged back in and returned to app!
    expect(find.byType(MainShell), findsOneWidget);
    expect(find.text('Your Story'), findsOneWidget);
  });

  testWidgets('Searching users in ExploreScreen shows real search results and opens profile', (WidgetTester tester) async {
    await tester.pumpWidget(const InstaCatApp());
    await tester.pumpAndSettle();

    // Log in
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    // Navigate to Explore tab
    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();

    // Find search field and type 'milo'
    final searchField = find.widgetWithText(TextField, 'Search cats, breeds, #hashtags...');
    expect(searchField, findsOneWidget);

    await tester.enterText(searchField, 'milo');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Verify search results display 'milo_the_scottish'
    expect(find.text('milo_the_scottish'), findsOneWidget);

    // Tap user result to open their profile
    await tester.tap(find.text('milo_the_scottish'));
    await tester.pumpAndSettle();

    // Verify profile screen of milo opened with back button
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    // Tap back button to return to explore search
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('milo_the_scottish'), findsOneWidget);
  });
}


