import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/models.dart';
import 'package:frontend/services/api_config.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/auth_service.dart';

void main() {
  setUpAll(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('ApiConfig Tests', () {
    test('resolveImageUrl correctly resolves relative Strapi paths', () {
      final resolved = ApiConfig.resolveImageUrl('/uploads/cat.jpg');
      expect(resolved, contains('/uploads/cat.jpg'));
      expect(resolved, startsWith('http'));
    });

    test('resolveImageUrl preserves full URLs', () {
      const fullUrl = 'https://example.com/cat.png';
      expect(ApiConfig.resolveImageUrl(fullUrl), equals(fullUrl));
    });

    test('resolveImageUrl returns null for null or empty string', () {
      expect(ApiConfig.resolveImageUrl(null), isNull);
      expect(ApiConfig.resolveImageUrl(''), isNull);
    });
  });

  group('Model Serialization Tests', () {
    test('CatUser.fromJson parses Strapi response correctly', () {
      final json = {
        'documentId': 'usr123',
        'username': 'whiskers',
        'displayName': 'Whiskers The Cat',
        'bio': 'Nap champion 💤',
        'category': 'Tabby',
        'website': 'whiskers.cat',
        'isPublic': true,
        'postsCount': 15,
        'followersCount': '1.2K',
        'followingCount': 50,
        'avatar': {
          'url': '/uploads/whiskers.jpg',
        },
      };

      final user = CatUser.fromJson(json);
      expect(user.id, 'usr123');
      expect(user.username, 'whiskers');
      expect(user.displayName, 'Whiskers The Cat');
      expect(user.bio, 'Nap champion 💤');
      expect(user.isPublic, isTrue);
      expect(user.postsCount, 15);
      expect(user.followersCount, '1.2K');
      expect(user.followingCount, 50);
      expect(user.avatarUrl, contains('/uploads/whiskers.jpg'));
    });

    test('CatUser.fromJson unwraps Strapi /api/me {"data": {...}} response', () {
      final json = {
        'data': {
          'documentId': 'idjr00zag5oivachch2arjek',
          'id': 1,
          'username': 'testcat',
          'email': 'testcat@example.com',
          'displayName': 'Meow ๆ',
          'bio': 'I love fish',
          'isPublic': true,
          'postsCount': 2,
          'followersCount': 10,
          'followingCount': 5,
        }
      };

      final user = CatUser.fromJson(json);
      expect(user.id, 'idjr00zag5oivachch2arjek');
      expect(user.username, 'testcat');
      expect(user.displayName, 'Meow ๆ');
      expect(user.bio, 'I love fish');
      expect(user.postsCount, 2);
    });

    test('CatUser.fromJson unwraps Strapi /auth/local {"user": {...}} response', () {
      final json = {
        'jwt': 'fake_jwt_token',
        'user': {
          'documentId': 'idjr00zag5oivachch2arjek',
          'id': 1,
          'username': 'testcat',
          'email': 'testcat@example.com',
          'displayName': 'Meow ๆ',
        }
      };

      final user = CatUser.fromJson(json);
      expect(user.id, 'idjr00zag5oivachch2arjek');
      expect(user.username, 'testcat');
      expect(user.displayName, 'Meow ๆ');
    });

    test('Post.fromJson parses Strapi response correctly', () {
      final json = {
        'documentId': 'post999',
        'caption': 'Caturday lounging! 🐾',
        'likeCount': 42,
        'isLiked': true,
        'createdAt': DateTime.now().toIso8601String(),
        'author': {
          'documentId': 'usr123',
          'username': 'whiskers',
          'displayName': 'Whiskers The Cat',
        },
        'images': [
          {'url': '/uploads/cat1.jpg'},
          {'url': '/uploads/cat2.jpg'},
        ],
      };

      final post = Post.fromJson(json);
      expect(post.id, 'post999');
      expect(post.caption, 'Caturday lounging! 🐾');
      expect(post.likesCount, 42);
      expect(post.isLiked, isTrue);
      expect(post.imageUrls.length, 2);
      expect(post.user.username, 'whiskers');
    });

    test('Post.fromJson parses /api/profiles/:username/posts response correctly', () {
      final json = {
        'documentId': 'mv9bhd0ac79fzanauuodwsxx',
        'id': 1,
        'caption': 'test this is first post',
        'createdAt': '2026-09-20T05:12:58.394Z',
        'author': {
          'documentId': 'idjr00zag5oivachch2arjek',
          'username': 'testcat',
          'displayName': 'Meow ๆ',
          'avatarUrl': null,
        },
        'images': [
          {
            'id': 2,
            'url': '/uploads/post_img_1789881178057_0_2a7981ac14.jpg',
            'width': 2730,
            'height': 2047,
          }
        ],
        'likeCount': 0,
        'isLiked': false,
      };

      final post = Post.fromJson(json);
      expect(post.id, 'mv9bhd0ac79fzanauuodwsxx');
      expect(post.caption, 'test this is first post');
      expect(post.user.username, 'testcat');
      expect(post.user.displayName, 'Meow ๆ');
      expect(post.imageUrls.length, 1);
      expect(post.imageUrls.first, contains('/uploads/post_img_1789881178057_0_2a7981ac14.jpg'));
    });
  });

  group('ApiClient Token Management Tests', () {
    test('saveTokens, getAccessToken, and clearTokens work as expected', () async {
      final client = ApiClient();
      await client.saveTokens(jwt: 'test_token_123', refreshToken: 'test_refresh_456');

      final token = await client.getAccessToken();
      expect(token, 'test_token_123');

      await client.clearTokens();
      final clearedToken = await client.getAccessToken();
      expect(clearedToken, isNull);
    });
  });

  group('AuthService Session Tests', () {
    test('AuthService login in test mode returns mock user', () async {
      final auth = AuthService();
      final user = await auth.login(identifier: 'testcat', password: 'password123');

      expect(user, isNotNull);
      expect(auth.currentUser, isNotNull);
    });

    test('CatUser toJson and fromJson round-trip successfully', () {
      const original = CatUser(
        id: 'usr_custom_1',
        username: 'persian_fluff',
        displayName: 'Fluffy Persian',
        avatarUrl: 'https://example.com/avatar.jpg',
        bio: 'Nap enthusiast',
        category: 'Persian Cat',
        isVerified: true,
        postsCount: 15,
        followersCount: '2.5k',
        followingCount: 120,
      );

      final json = original.toJson();
      final restored = CatUser.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.username, original.username);
      expect(restored.displayName, original.displayName);
      expect(restored.avatarUrl, original.avatarUrl);
      expect(restored.bio, original.bio);
      expect(restored.category, original.category);
      expect(restored.isVerified, original.isVerified);
      expect(restored.postsCount, original.postsCount);
      expect(restored.followersCount, original.followersCount);
      expect(restored.followingCount, original.followingCount);
    });

    test('saveLastUser updates AuthService lastUser property', () async {
      final auth = AuthService();
      const testUser = CatUser(
        id: 'usr_last_saved',
        username: 'real_last_cat',
        displayName: 'Real Cat',
        avatarUrl: 'https://example.com/cat.jpg',
        category: 'Siamese Cat',
      );

      await auth.saveLastUser(testUser, identifier: 'real_last_cat', password: 'securepass');
      expect(auth.lastUser.username, 'real_last_cat');
      expect(auth.lastUser.category, 'Siamese Cat');
    });
  });
}
