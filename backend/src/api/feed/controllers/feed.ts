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

    const data = await Promise.all(
      posts.map(async (post: any) => {
        const [likeCount, commentCount, likedByMe] = await Promise.all([
          strapi.documents('api::post-like.post-like').count({
            filters: {
              post: {
                documentId: post.documentId,
              },
            },
          }),
          strapi.documents('api::comment.comment').count({
            filters: {
              post: {
                documentId: post.documentId,
              },
            },
          }),
          currentUser
            ? strapi.documents('api::post-like.post-like').count({
                filters: {
                  post: { documentId: post.documentId },
                  user: { id: currentUser.id },
                },
              })
            : Promise.resolve(0),
        ]);

        return {
          documentId: post.documentId,
          id: post.id,
          caption: post.caption,
          location: post.location || '',
          taggedUsernames: Array.isArray(post.taggedUsernames) ? post.taggedUsernames : [],
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
          commentCount,
          isLiked: likedByMe > 0,
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

    const data = await Promise.all(
      posts.map(async (post: any) => {
        const [likeCount, commentCount, likedByMe] = await Promise.all([
          strapi.documents('api::post-like.post-like').count({
            filters: {
              post: {
                documentId: post.documentId,
              },
            },
          }),
          strapi.documents('api::comment.comment').count({
            filters: {
              post: {
                documentId: post.documentId,
              },
            },
          }),
          strapi.documents('api::post-like.post-like').count({
            filters: {
              post: { documentId: post.documentId },
              user: { id: user.id },
            },
          }),
        ]);

        return {
          documentId: post.documentId,
          id: post.id,
          caption: post.caption,
          location: post.location || '',
          taggedUsernames: Array.isArray(post.taggedUsernames) ? post.taggedUsernames : [],
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
          commentCount,
          isLiked: likedByMe > 0,
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
