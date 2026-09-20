import { factories } from '@strapi/strapi';

export default factories.createCoreController('api::post.post', ({ strapi }) => ({
  async create(ctx) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required');
    }

    const body = ctx.request.body.data || ctx.request.body || {};
    const { caption, images } = body;

    if (!images || !Array.isArray(images) || images.length === 0 || images.length > 10) {
      return ctx.badRequest('A post must contain between 1 and 10 images');
    }

    const newPost = await strapi.documents('api::post.post').create({
      data: {
        caption: typeof caption === 'string' ? caption.slice(0, 2200) : '',
        images: images,
        moderationStatus: 'visible',
        author: user.id,
      },
      populate: ['images', 'author', 'author.avatar'],
    });

    return {
      data: {
        documentId: newPost.documentId,
        id: newPost.id,
        caption: newPost.caption,
        createdAt: newPost.createdAt,
        author: {
          documentId: user.documentId,
          username: user.username,
          displayName: user.displayName || user.username,
          avatarUrl: user.avatar?.url || null,
        },
        images: Array.isArray(newPost.images) ? newPost.images.map((img: any) => ({
          id: img.id,
          url: img.url,
          width: img.width,
          height: img.height,
        })) : [],
        likeCount: 0,
        isLiked: false,
      },
    };
  },

  async update(ctx) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required');
    }

    const { documentId } = ctx.params;
    const post = await strapi.documents('api::post.post').findOne({
      documentId,
      populate: ['author', 'images'],
    });

    if (!post) {
      return ctx.notFound('Post not found');
    }

    if (post.author?.id !== user.id && post.author?.documentId !== user.documentId) {
      return ctx.forbidden('You can only update your own posts');
    }

    const body = ctx.request.body.data || ctx.request.body || {};
    const updateData: Record<string, any> = {};

    if (typeof body.caption !== 'undefined') {
      updateData.caption = String(body.caption).slice(0, 2200);
    }
    if (Array.isArray(body.images)) {
      if (body.images.length === 0 || body.images.length > 10) {
        return ctx.badRequest('A post must contain between 1 and 10 images');
      }
      updateData.images = body.images;
    }

    const updated = await strapi.documents('api::post.post').update({
      documentId,
      data: updateData,
      populate: ['images', 'author', 'author.avatar'],
    });

    if (!updated) {
      return ctx.badRequest('Failed to update post');
    }

    return {
      data: {
        documentId: updated.documentId,
        id: updated.id,
        caption: updated.caption,
        createdAt: updated.createdAt,
        author: {
          documentId: user.documentId,
          username: user.username,
          displayName: user.displayName || user.username,
          avatarUrl: user.avatar?.url || null,
        },
        images: Array.isArray(updated.images) ? updated.images.map((img: any) => ({
          id: img.id,
          url: img.url,
          width: img.width,
          height: img.height,
        })) : [],
      },
    };
  },

  async delete(ctx) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required');
    }

    const { documentId } = ctx.params;
    const post = await strapi.documents('api::post.post').findOne({
      documentId,
      populate: ['author'],
    });

    if (!post) {
      return ctx.notFound('Post not found');
    }

    if (post.author?.id !== user.id && post.author?.documentId !== user.documentId) {
      return ctx.forbidden('You can only delete your own posts');
    }

    // Remove likes associated with this post first
    const likes = await strapi.documents('api::post-like.post-like').findMany({
      filters: {
        post: {
          documentId,
        },
      },
    });

    for (const like of likes) {
      await strapi.documents('api::post-like.post-like').delete({
        documentId: like.documentId,
      });
    }

    await strapi.documents('api::post.post').delete({
      documentId,
    });

    return {
      data: {
        message: 'Post deleted successfully',
      },
    };
  },

  async findOne(ctx) {
    const { documentId } = ctx.params;
    const currentUser = ctx.state.user;

    const post = await strapi.documents('api::post.post').findOne({
      documentId,
      populate: ['images', 'author', 'author.avatar'],
    });

    if (!post || post.moderationStatus === 'hidden') {
      return ctx.notFound('Post not found');
    }

    const likesCount = await strapi.documents('api::post-like.post-like').count({
      filters: {
        post: {
          documentId,
        },
      },
    });

    let isLiked = false;
    if (currentUser) {
      const userLike = await strapi.documents('api::post-like.post-like').findFirst({
        filters: {
          post: {
            documentId,
          },
          user: {
            id: currentUser.id,
          },
        },
      });
      isLiked = !!userLike;
    }

    return {
      data: {
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
        images: Array.isArray(post.images) ? post.images.map((img: any) => ({
          id: img.id,
          url: img.url,
          width: img.width,
          height: img.height,
        })) : [],
        likeCount: likesCount,
        isLiked,
      },
    };
  },

  async like(ctx) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required to like posts');
    }

    const { documentId } = ctx.params;
    const post = await strapi.documents('api::post.post').findOne({
      documentId,
    });

    if (!post) {
      return ctx.notFound('Post not found');
    }

    // Check existing like
    const existing = await strapi.documents('api::post-like.post-like').findFirst({
      filters: {
        post: {
          documentId,
        },
        user: {
          id: user.id,
        },
      },
    });

    if (!existing) {
      await strapi.documents('api::post-like.post-like').create({
        data: {
          post: post.id,
          user: user.id,
        },
      });
    }

    const likeCount = await strapi.documents('api::post-like.post-like').count({
      filters: {
        post: {
          documentId,
        },
      },
    });

    return {
      data: {
        liked: true,
        likeCount,
      },
    };
  },

  async unlike(ctx) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required');
    }

    const { documentId } = ctx.params;
    const post = await strapi.documents('api::post.post').findOne({
      documentId,
    });

    if (!post) {
      return ctx.notFound('Post not found');
    }

    const existing = await strapi.documents('api::post-like.post-like').findFirst({
      filters: {
        post: {
          documentId,
        },
        user: {
          id: user.id,
        },
      },
    });

    if (existing) {
      await strapi.documents('api::post-like.post-like').delete({
        documentId: existing.documentId,
      });
    }

    const likeCount = await strapi.documents('api::post-like.post-like').count({
      filters: {
        post: {
          documentId,
        },
      },
    });

    return {
      data: {
        liked: false,
        likeCount,
      },
    };
  },
}));
