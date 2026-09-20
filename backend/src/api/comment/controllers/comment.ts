import { factories } from '@strapi/strapi';

export default factories.createCoreController('api::comment.comment', ({ strapi }) => ({
  async deleteOwn(ctx) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required');
    }

    const { documentId } = ctx.params;
    const comment = await strapi.documents('api::comment.comment').findOne({
      documentId,
      populate: ['author', 'post'],
    });

    if (!comment) {
      return ctx.notFound('Comment not found');
    }

    const isAuthor =
      comment.author?.id === user.id || comment.author?.documentId === user.documentId;

    let isPostOwner = false;
    const postDocumentId = comment.post?.documentId;
    if (postDocumentId) {
      const post = await strapi.documents('api::post.post').findOne({
        documentId: postDocumentId,
        populate: ['author'],
      });
      isPostOwner =
        post?.author?.id === user.id || post?.author?.documentId === user.documentId;
    }

    if (!isAuthor && !isPostOwner) {
      return ctx.forbidden('You can only delete your own comments');
    }

    await strapi.documents('api::comment.comment').delete({ documentId });

    let commentCount = 0;
    if (postDocumentId) {
      commentCount = await strapi.documents('api::comment.comment').count({
        filters: {
          post: { documentId: postDocumentId },
        },
      });
    }

    return {
      data: {
        deleted: true,
        commentCount,
      },
    };
  },
}));
