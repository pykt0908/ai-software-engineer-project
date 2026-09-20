export default {
  async getMe(ctx: any) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required');
    }

    const fullUser = await strapi.documents('plugin::users-permissions.user').findOne({
      documentId: user.documentId,
      populate: ['avatar'],
    });

    if (!fullUser) {
      return ctx.notFound('User not found');
    }

    const postsCount = await strapi.documents('api::post.post').count({
      filters: {
        author: {
          id: user.id,
        },
      },
    });

    const followersCount = await strapi.documents('api::follow.follow').count({
      filters: {
        following: {
          id: user.id,
        },
      },
    });

    const followingCount = await strapi.documents('api::follow.follow').count({
      filters: {
        follower: {
          id: user.id,
        },
      },
    });

    return {
      data: {
        documentId: fullUser.documentId,
        id: fullUser.id,
        username: fullUser.username,
        email: fullUser.email,
        displayName: fullUser.displayName || fullUser.username,
        bio: fullUser.bio || '',
        avatar: fullUser.avatar
          ? {
              id: fullUser.avatar.id,
              url: fullUser.avatar.url,
            }
          : null,
        isPublic: fullUser.isPublic ?? true,
        postsCount,
        followersCount,
        followingCount,
      },
    };
  },

  async updateMe(ctx: any) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required');
    }

    const body = ctx.request.body.data || ctx.request.body || {};
    const updateData: Record<string, any> = {};

    if (typeof body.displayName !== 'undefined') {
      updateData.displayName = String(body.displayName).trim();
    }
    if (typeof body.bio !== 'undefined') {
      updateData.bio = String(body.bio).trim();
    }
    if (typeof body.isPublic !== 'undefined') {
      updateData.isPublic = Boolean(body.isPublic);
    }
    if (typeof body.avatar !== 'undefined') {
      updateData.avatar = body.avatar;
    }

    const updatedUser = await strapi.documents('plugin::users-permissions.user').update({
      documentId: user.documentId,
      data: updateData,
      populate: ['avatar'],
    });

    if (!updatedUser) {
      return ctx.badRequest('Failed to update profile');
    }

    const postsCount = await strapi.documents('api::post.post').count({
      filters: {
        author: {
          id: user.id,
        },
      },
    });

    const followersCount = await strapi.documents('api::follow.follow').count({
      filters: {
        following: {
          id: user.id,
        },
      },
    });

    const followingCount = await strapi.documents('api::follow.follow').count({
      filters: {
        follower: {
          id: user.id,
        },
      },
    });

    return {
      data: {
        documentId: updatedUser.documentId,
        id: updatedUser.id,
        username: updatedUser.username,
        email: updatedUser.email,
        displayName: updatedUser.displayName || updatedUser.username,
        bio: updatedUser.bio || '',
        avatar: updatedUser.avatar
          ? {
              id: updatedUser.avatar.id,
              url: updatedUser.avatar.url,
            }
          : null,
        isPublic: updatedUser.isPublic ?? true,
        postsCount,
        followersCount,
        followingCount,
      },
    };
  },

  async getProfile(ctx: any) {
    const { username } = ctx.params;
    const currentUser = ctx.state.user;

    const targetUser = await strapi.documents('plugin::users-permissions.user').findFirst({
      filters: {
        username,
        blocked: false,
      },
      populate: ['avatar'],
    });

    if (!targetUser) {
      return ctx.notFound('User not found');
    }

    const postsCount = await strapi.documents('api::post.post').count({
      filters: {
        author: {
          id: targetUser.id,
        },
        moderationStatus: 'visible',
      },
    });

    const followersCount = await strapi.documents('api::follow.follow').count({
      filters: {
        following: {
          id: targetUser.id,
        },
      },
    });

    const followingCount = await strapi.documents('api::follow.follow').count({
      filters: {
        follower: {
          id: targetUser.id,
        },
      },
    });

    let isFollowing = false;
    if (currentUser) {
      const followRecord = await strapi.documents('api::follow.follow').findFirst({
        filters: {
          follower: {
            id: currentUser.id,
          },
          following: {
            id: targetUser.id,
          },
        },
      });
      isFollowing = !!followRecord;
    }

    return {
      data: {
        documentId: targetUser.documentId,
        id: targetUser.id,
        username: targetUser.username,
        displayName: targetUser.displayName || targetUser.username,
        bio: targetUser.bio || '',
        avatar: targetUser.avatar
          ? {
              id: targetUser.avatar.id,
              url: targetUser.avatar.url,
            }
          : null,
        isPublic: targetUser.isPublic ?? true,
        postsCount,
        followersCount,
        followingCount,
        isFollowing,
      },
    };
  },

  async getUserPosts(ctx: any) {
    const { username } = ctx.params;
    const currentUser = ctx.state.user;

    const targetUser = await strapi.documents('plugin::users-permissions.user').findFirst({
      filters: {
        username,
        blocked: false,
      },
    });

    if (!targetUser) {
      return ctx.notFound('User not found');
    }

    const isOwner = currentUser && currentUser.id === targetUser.id;
    if (targetUser.isPublic === false && !isOwner) {
      let isFollowing = false;
      if (currentUser) {
        const followRecord = await strapi.documents('api::follow.follow').findFirst({
          filters: {
            follower: { id: currentUser.id },
            following: { id: targetUser.id },
          },
        });
        isFollowing = !!followRecord;
      }
      if (!isFollowing) {
        return ctx.forbidden('This account is private');
      }
    }

    const page = Math.max(1, parseInt(ctx.query.page || '1', 10));
    const pageSize = Math.min(50, Math.max(1, parseInt(ctx.query.pageSize || '30', 10)));

    const filters: any = {
      author: {
        id: targetUser.id,
      },
      moderationStatus: 'visible',
    };

    const total = await strapi.documents('api::post.post').count({
      filters,
    });

    const posts = await strapi.documents('api::post.post').findMany({
      filters,
      sort: 'createdAt:desc',
      start: (page - 1) * pageSize,
      limit: pageSize,
      populate: ['images', 'author', 'author.avatar'],
    });

    let likedPostIds = new Set<string>();
    if (currentUser && posts.length > 0) {
      const userLikes = await strapi.documents('api::post-like.post-like').findMany({
        filters: {
          user: {
            id: currentUser.id,
          },
          post: {
            documentId: {
              $in: posts.map((p: any) => p.documentId),
            },
          },
        },
        populate: ['post'],
      });
      for (const like of userLikes) {
        if (like.post?.documentId) {
          likedPostIds.add(like.post.documentId);
        }
      }
    }

    const data = await Promise.all(
      posts.map(async (post: any) => {
        const likeCount = await strapi.documents('api::post-like.post-like').count({
          filters: {
            post: {
              documentId: post.documentId,
            },
          },
        });

        return {
          documentId: post.documentId,
          id: post.id,
          caption: post.caption,
          createdAt: post.createdAt,
          author: {
            documentId: post.author?.documentId,
            username: post.author?.username,
            displayName: post.author?.displayName || post.author?.username,
            avatarUrl: post.author?.avatar?.url || null,
          },
          images: Array.isArray(post.images)
            ? post.images.map((img: any) => ({
                id: img.id,
                url: img.url,
                width: img.width,
                height: img.height,
              }))
            : [],
          likeCount,
          isLiked: likedPostIds.has(post.documentId),
        };
      })
    );

    return {
      data,
      meta: {
        pagination: {
          page,
          pageSize,
          pageCount: Math.ceil(total / pageSize),
          total,
        },
      },
    };
  },
};
