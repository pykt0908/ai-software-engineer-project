import { factories } from '@strapi/strapi';
import { createNotification } from '../../notification/services/notification-helper';

function mapAuthor(author: any) {
  return {
    documentId: author?.documentId,
    username: author?.username,
    displayName: author?.displayName || author?.username,
    avatarUrl: author?.avatar?.url || null,
  };
}

function mapComment(comment: any) {
  return {
    documentId: comment.documentId,
    id: comment.id,
    text: comment.text,
    createdAt: comment.createdAt,
    author: mapAuthor(comment.author),
  };
}

/** Core routes use `:id`; custom routes use `:documentId`. */
function getDocumentId(ctx: any): string {
  return String(ctx.params.documentId || ctx.params.id || '');
}

function normalizeLocation(value: unknown): string {
  if (typeof value !== 'string') return '';
  return value.trim().slice(0, 120);
}

function normalizeTaggedUsernames(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  const seen = new Set<string>();
  const result: string[] = [];
  for (const item of value) {
    const name = String(item || '')
      .trim()
      .replace(/^@+/, '')
      .slice(0, 50);
    if (!name) continue;
    const key = name.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    result.push(name);
    if (result.length >= 20) break;
  }
  return result;
}

export default factories.createCoreController('api::post.post', ({ strapi }) => ({
  async create(ctx) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required');
    }

    const body = ctx.request.body.data || ctx.request.body || {};
    const { caption, images } = body;
    const location = normalizeLocation(body.location);
    const taggedUsernames = normalizeTaggedUsernames(body.taggedUsernames);

    if (!images || !Array.isArray(images) || images.length === 0 || images.length > 10) {
      return ctx.badRequest('A post must contain between 1 and 10 images');
    }

    const newPost = await strapi.documents('api::post.post').create({
      data: {
        caption: typeof caption === 'string' ? caption.slice(0, 2200) : '',
        location: location || undefined,
        taggedUsernames,
        images: images,
        moderationStatus: 'visible',
        author: user.id,
      },
      populate: ['images', 'author', 'author.avatar'],
    }) as any;

    return {
      data: {
        documentId: newPost.documentId,
        id: newPost.id,
        caption: newPost.caption,
        location: newPost.location || '',
        taggedUsernames: Array.isArray(newPost.taggedUsernames) ? newPost.taggedUsernames : [],
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
        commentCount: 0,
        isLiked: false,
      },
    };
  },

  async update(ctx) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required');
    }

    const documentId = getDocumentId(ctx);
    if (!documentId) {
      return ctx.badRequest('Missing post id');
    }
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
    if (typeof body.location !== 'undefined') {
      updateData.location = normalizeLocation(body.location) || undefined;
    }
    if (typeof body.taggedUsernames !== 'undefined') {
      updateData.taggedUsernames = normalizeTaggedUsernames(body.taggedUsernames);
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

    const [likeCount, commentCount, likedByMe] = await Promise.all([
      strapi.documents('api::post-like.post-like').count({
        filters: { post: { documentId } },
      }),
      strapi.documents('api::comment.comment').count({
        filters: { post: { documentId } },
      }),
      strapi.documents('api::post-like.post-like').count({
        filters: {
          post: { documentId },
          user: { id: user.id },
        },
      }),
    ]);

    return {
      data: {
        documentId: updated.documentId,
        id: updated.id,
        caption: updated.caption,
        location: updated.location || '',
        taggedUsernames: Array.isArray(updated.taggedUsernames) ? updated.taggedUsernames : [],
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
        likeCount,
        commentCount,
        isLiked: likedByMe > 0,
      },
    };
  },

  async delete(ctx) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required');
    }

    const documentId = getDocumentId(ctx);
    if (!documentId) {
      return ctx.badRequest('Missing post id');
    }
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

    const likes = await strapi.documents('api::post-like.post-like').findMany({
      filters: {
        post: { documentId },
      },
    });

    for (const like of likes) {
      await strapi.documents('api::post-like.post-like').delete({
        documentId: like.documentId,
      });
    }

    const comments = await strapi.documents('api::comment.comment').findMany({
      filters: {
        post: { documentId },
      },
    });

    for (const comment of comments) {
      await strapi.documents('api::comment.comment').delete({
        documentId: comment.documentId,
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
    const documentId = getDocumentId(ctx);
    if (!documentId) {
      return ctx.badRequest('Missing post id');
    }
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
        post: { documentId },
      },
    });

    const commentCount = await strapi.documents('api::comment.comment').count({
      filters: {
        post: { documentId },
      },
    });

    let isLiked = false;
    if (currentUser) {
      const userLike = await strapi.documents('api::post-like.post-like').findFirst({
        filters: {
          post: { documentId },
          user: { id: currentUser.id },
        },
      });
      isLiked = !!userLike;
    }

    return {
      data: {
        documentId: post.documentId,
        id: post.id,
        caption: post.caption,
        location: post.location || '',
        taggedUsernames: Array.isArray(post.taggedUsernames) ? post.taggedUsernames : [],
        createdAt: post.createdAt,
        author: mapAuthor(post.author),
        images: Array.isArray(post.images) ? post.images.map((img: any) => ({
          id: img.id,
          url: img.url,
          width: img.width,
          height: img.height,
        })) : [],
        likeCount: likesCount,
        commentCount,
        isLiked,
      },
    };
  },

  async like(ctx) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required to like posts');
    }

    const documentId = getDocumentId(ctx);
    if (!documentId) {
      return ctx.badRequest('Missing post id');
    }
    const post = await strapi.documents('api::post.post').findOne({
      documentId,
      populate: ['author'],
    });

    if (!post) {
      return ctx.notFound('Post not found');
    }

    const existing = await strapi.documents('api::post-like.post-like').findFirst({
      filters: {
        post: { documentId },
        user: { id: user.id },
      },
    });

    if (!existing) {
      await strapi.documents('api::post-like.post-like').create({
        data: {
          post: post.id,
          user: user.id,
        },
      });

      const authorId = (post as any).author?.id;
      if (authorId) {
        await createNotification(strapi, {
          recipientId: authorId,
          actorId: user.id,
          type: 'like',
          message: 'liked your post.',
          postId: post.id,
        });
      }
    }

    const likeCount = await strapi.documents('api::post-like.post-like').count({
      filters: {
        post: { documentId },
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

    const documentId = getDocumentId(ctx);
    if (!documentId) {
      return ctx.badRequest('Missing post id');
    }
    const post = await strapi.documents('api::post.post').findOne({
      documentId,
    });

    if (!post) {
      return ctx.notFound('Post not found');
    }

    const existing = await strapi.documents('api::post-like.post-like').findFirst({
      filters: {
        post: { documentId },
        user: { id: user.id },
      },
    });

    if (existing) {
      await strapi.documents('api::post-like.post-like').delete({
        documentId: existing.documentId,
      });
    }

    const likeCount = await strapi.documents('api::post-like.post-like').count({
      filters: {
        post: { documentId },
      },
    });

    return {
      data: {
        liked: false,
        likeCount,
      },
    };
  },

  async listComments(ctx) {
    const documentId = getDocumentId(ctx);
    if (!documentId) {
      return ctx.badRequest('Missing post id');
    }
    const page = Math.max(1, parseInt(String(ctx.query.page ?? '1'), 10) || 1);
    const pageSize = Math.min(50, Math.max(1, parseInt(String(ctx.query.pageSize ?? '20'), 10) || 20));

    const post = await strapi.documents('api::post.post').findOne({
      documentId,
    });

    if (!post || post.moderationStatus === 'hidden') {
      return ctx.notFound('Post not found');
    }

    const filters = {
      post: { documentId },
    };

    const total = await strapi.documents('api::comment.comment').count({ filters });

    const comments = await strapi.documents('api::comment.comment').findMany({
      filters,
      sort: 'createdAt:asc',
      start: (page - 1) * pageSize,
      limit: pageSize,
      populate: ['author', 'author.avatar'],
    });

    return {
      data: comments.map(mapComment),
      meta: {
        commentCount: total,
        pagination: {
          page,
          pageSize,
          pageCount: Math.ceil(total / pageSize),
          total,
        },
      },
    };
  },

  async createComment(ctx) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required');
    }

    const documentId = getDocumentId(ctx);
    if (!documentId) {
      return ctx.badRequest('Missing post id');
    }
    const body = ctx.request.body.data || ctx.request.body || {};
    const text = typeof body.text === 'string' ? body.text.trim() : '';

    if (!text) {
      return ctx.badRequest('Comment text is required');
    }
    if (text.length > 1000) {
      return ctx.badRequest('Comment must be at most 1000 characters');
    }

    const post = await strapi.documents('api::post.post').findOne({
      documentId,
      populate: ['author'],
    });

    if (!post || post.moderationStatus === 'hidden') {
      return ctx.notFound('Post not found');
    }

    const created = await strapi.documents('api::comment.comment').create({
      data: {
        text,
        author: user.id,
        post: post.id,
      },
      populate: ['author', 'author.avatar'],
    });

    const authorId = (post as any).author?.id;
    if (authorId) {
      const preview = text.length > 80 ? `${text.slice(0, 77)}...` : text;
      await createNotification(strapi, {
        recipientId: authorId,
        actorId: user.id,
        type: 'comment',
        message: `commented: ${preview}`,
        postId: post.id,
        commentId: (created as any).id,
      });
    }

    const commentCount = await strapi.documents('api::comment.comment').count({
      filters: {
        post: { documentId },
      },
    });

    return {
      data: mapComment(created),
      meta: { commentCount },
    };
  },
}));
