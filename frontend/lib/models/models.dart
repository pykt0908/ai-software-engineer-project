import '../services/api_config.dart';

class CatUser {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final String bio;
  final String category;
  final String website;
  final bool isVerified;
  final int postsCount;
  final String followersCount;
  final int followingCount;
  final bool isPublic;
  final bool isFollowing;

  const CatUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    this.bio = '',
    this.category = '',
    this.website = '',
    this.isVerified = false,
    this.postsCount = 0,
    this.followersCount = '0',
    this.followingCount = 0,
    this.isPublic = true,
    this.isFollowing = false,
  });

  factory CatUser.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> map;
    if (json['data'] is Map) {
      map = Map<String, dynamic>.from(json['data'] as Map);
    } else if (json['user'] is Map) {
      map = Map<String, dynamic>.from(json['user'] as Map);
    } else {
      map = json;
    }

    String? avatarUrl;
    if (map['avatar'] is Map) {
      avatarUrl = ApiConfig.resolveImageUrl(map['avatar']['url']?.toString());
    } else if (map['avatarUrl'] is String) {
      avatarUrl = ApiConfig.resolveImageUrl(map['avatarUrl']?.toString());
    }

    return CatUser(
      id: map['documentId']?.toString() ?? map['id']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? map['username']?.toString() ?? '',
      avatarUrl: avatarUrl ??
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDgHq4gqaix1Z8C7wnrG9dw8dQcSa6fwprjccleQOkLGHiHDm_S23rtMaEWSa93Wgjp2ubKkH2fMNZKfI_udBUhr2bUkoz5rb49FiL0FlMYlg_f_ECWWkJb4VYQKqgGmIYkn7mZr0eqo-es1dmY3QvgM7Xd4jiKHlMBmP1pH4bJTNFUkJh0lbGFXhUXK6KsZPKrCpMMFU9l0ZB65hPiJWdCMMStFnaTeUM7_sSSEQbTxXiqTOsFryu3mw',
      bio: map['bio']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Cat Lover',
      website: map['website']?.toString() ?? '',
      isVerified: map['isVerified'] == true || map['confirmed'] == true,
      postsCount: map['postsCount'] is int
          ? map['postsCount']
          : (int.tryParse(map['postsCount']?.toString() ?? '0') ?? 0),
      followersCount: map['followersCount']?.toString() ?? '0',
      followingCount: map['followingCount'] is int
          ? map['followingCount']
          : (int.tryParse(map['followingCount']?.toString() ?? '0') ?? 0),
      isPublic: map['isPublic'] != false,
      isFollowing: map['isFollowing'] == true,
    );
  }

  CatUser copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? category,
    String? website,
    bool? isVerified,
    int? postsCount,
    String? followersCount,
    int? followingCount,
    bool? isPublic,
    bool? isFollowing,
  }) {
    return CatUser(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      category: category ?? this.category,
      website: website ?? this.website,
      isVerified: isVerified ?? this.isVerified,
      postsCount: postsCount ?? this.postsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isPublic: isPublic ?? this.isPublic,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'category': category,
      'website': website,
      'isVerified': isVerified,
      'postsCount': postsCount,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'isPublic': isPublic,
      'isFollowing': isFollowing,
    };
  }
}

class Post {
  final String id;
  final CatUser user;
  final List<String> imageUrls;
  String caption;
  int likesCount;
  final int commentsCount;
  final String location;
  final String timestamp;
  bool isLiked;
  bool isSaved;

  Post({
    required this.id,
    required this.user,
    required this.imageUrls,
    required this.caption,
    required this.likesCount,
    required this.commentsCount,
    required this.location,
    required this.timestamp,
    this.isLiked = false,
    this.isSaved = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final List<String> images = [];
    if (json['images'] is List) {
      for (final img in json['images']) {
        if (img is Map && img['url'] != null) {
          final resolved = ApiConfig.resolveImageUrl(img['url'].toString());
          if (resolved != null) images.add(resolved);
        } else if (img is String) {
          final resolved = ApiConfig.resolveImageUrl(img);
          if (resolved != null) images.add(resolved);
        }
      }
    }

    CatUser postAuthor;
    if (json['author'] is Map<String, dynamic>) {
      postAuthor = CatUser.fromJson(json['author']);
    } else {
      postAuthor = const CatUser(
        id: 'user_unknown',
        username: 'cat_friend',
        displayName: 'Cat Friend',
        avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDgHq4gqaix1Z8C7wnrG9dw8dQcSa6fwprjccleQOkLGHiHDm_S23rtMaEWSa93Wgjp2ubKkH2fMNZKfI_udBUhr2bUkoz5rb49FiL0FlMYlg_f_ECWWkJb4VYQKqgGmIYkn7mZr0eqo-es1dmY3QvgM7Xd4jiKHlMBmP1pH4bJTNFUkJh0lbGFXhUXK6KsZPKrCpMMFU9l0ZB65hPiJWdCMMStFnaTeUM7_sSSEQbTxXiqTOsFryu3mw',
      );
    }

    String formattedTime = 'Just now';
    if (json['createdAt'] != null) {
      final parsed = DateTime.tryParse(json['createdAt'].toString());
      if (parsed != null) {
        final diff = DateTime.now().difference(parsed);
        if (diff.inMinutes < 1) {
          formattedTime = 'Just now';
        } else if (diff.inHours < 1) {
          formattedTime = '${diff.inMinutes}m';
        } else if (diff.inDays < 1) {
          formattedTime = '${diff.inHours}h';
        } else {
          formattedTime = '${diff.inDays}d';
        }
      }
    }

    return Post(
      id: json['documentId']?.toString() ?? json['id']?.toString() ?? '',
      user: postAuthor,
      imageUrls: images.isNotEmpty
          ? images
          : [
              'https://lh3.googleusercontent.com/aida-public/AB6AXuC0XD-x0dfUjXw3MIH4Lhlyk6wMnHcQp-CBshOZ3azaTzmv0uS67O_9nIHwDGpP7lRmeFng2pWrK1mMwbMXMrGPi4PvSbqLIOCZnDBBbCRYzXuVkXH6NBAy19G-G1Cn3Wi-EAQUnaetj2Un35INsvDzibHUVTFn22q0uArSDNfmqjtFOijKJb2d3YQLmrCGC-FPdw7IQgqzgAVUPjnX8ISOjnzIW154VDqYeJmuKM9mzpg6272nT3s8-Q'
            ],
      caption: json['caption']?.toString() ?? '',
      likesCount: json['likeCount'] is int
          ? json['likeCount']
          : (int.tryParse(json['likeCount']?.toString() ?? '0') ?? 0),
      commentsCount: 0,
      location: 'Tokyo, Japan',
      timestamp: formattedTime,
      isLiked: json['isLiked'] == true,
    );
  }
}

class Comment {
  final String id;
  final CatUser user;
  final String text;
  final String timestamp;
  int likesCount;
  bool isLiked;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.user,
    required this.text,
    required this.timestamp,
    this.likesCount = 0,
    this.isLiked = false,
    this.replies = const [],
  });
}

class Story {
  final String id;
  final CatUser user;
  final bool isViewed;
  final bool isCurrentUser;

  const Story({
    required this.id,
    required this.user,
    this.isViewed = false,
    this.isCurrentUser = false,
  });
}

class StoryHighlight {
  final String id;
  final String title;
  final String coverImageUrl;
  final bool isNew;

  const StoryHighlight({
    required this.id,
    required this.title,
    required this.coverImageUrl,
    this.isNew = false,
  });
}

enum NotificationType {
  like,
  comment,
  follow,
  mention,
  treat,
}

class NotificationItem {
  final String id;
  final CatUser user;
  final NotificationType type;
  final String message;
  final String timeAgo;
  final String? postImageUrl;
  final String? postCaption;
  final bool isRead;
  final bool isFollowing;

  const NotificationItem({
    required this.id,
    required this.user,
    required this.type,
    required this.message,
    required this.timeAgo,
    this.postImageUrl,
    this.postCaption,
    this.isRead = false,
    this.isFollowing = false,
  });

  NotificationItem copyWith({
    String? id,
    CatUser? user,
    NotificationType? type,
    String? message,
    String? timeAgo,
    String? postImageUrl,
    String? postCaption,
    bool? isRead,
    bool? isFollowing,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      user: user ?? this.user,
      type: type ?? this.type,
      message: message ?? this.message,
      timeAgo: timeAgo ?? this.timeAgo,
      postImageUrl: postImageUrl ?? this.postImageUrl,
      postCaption: postCaption ?? this.postCaption,
      isRead: isRead ?? this.isRead,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
