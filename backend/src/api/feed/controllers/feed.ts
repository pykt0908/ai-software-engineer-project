export default {
  async publicFeed(ctx: any) {
    const page = Math.max(1, parseInt(ctx.query.page || '1', 10));
    const pageSize = Math.min(20, Math.max(1, parseInt(ctx.query.pageSize || '10', 10)));
    const currentUser = ctx.state.user;

    const filters: any = {
      moderationStatus: 'visible',
      author: {
        isPublic: true,
        blocked: false,
      },
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

    // Batch resolve likes for current user if authenticated
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

  async followingFeed(ctx: any) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required');
    }

    const page = Math.max(1, parseInt(ctx.query.page || '1', 10));
    const pageSize = Math.min(20, Math.max(1, parseInt(ctx.query.pageSize || '10', 10)));

    // Find who this user follows
    const follows = await strapi.documents('api::follow.follow').findMany({
      filters: {
        follower: {
          id: user.id,
        },
      },
      populate: ['following'],
    });

    const followingIds = follows.map((f: any) => f.following?.id).filter(Boolean);

    if (followingIds.length === 0) {
      return {
        data: [],
        meta: {
          pagination: {
            page,
            pageSize,
            pageCount: 0,
            total: 0,
          },
        },
      };
    }

    const filters: any = {
      moderationStatus: 'visible',
      author: {
        id: {
          $in: followingIds,
        },
        blocked: false,
      },
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
    if (posts.length > 0) {
      const userLikes = await strapi.documents('api::post-like.post-like').findMany({
        filters: {
          user: {
            id: user.id,
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
