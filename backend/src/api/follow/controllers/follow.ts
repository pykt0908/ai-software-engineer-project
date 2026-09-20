import { factories } from '@strapi/strapi';

export default factories.createCoreController('api::follow.follow', ({ strapi }) => ({
  async followUser(ctx) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required');
    }

    const { documentId } = ctx.params;
    const targetUser = await strapi.documents('plugin::users-permissions.user').findOne({
      documentId,
    });

    if (!targetUser) {
      return ctx.notFound('User not found');
    }

    if (targetUser.id === user.id || targetUser.documentId === user.documentId) {
      return ctx.badRequest('You cannot follow yourself');
    }

    const existing = await strapi.documents('api::follow.follow').findFirst({
      filters: {
        follower: {
          id: user.id,
        },
        following: {
          id: targetUser.id,
        },
      },
    });

    if (!existing) {
      await strapi.documents('api::follow.follow').create({
        data: {
          follower: user.id,
          following: targetUser.id,
        },
      });
    }

    const followersCount = await strapi.documents('api::follow.follow').count({
      filters: {
        following: {
          id: targetUser.id,
        },
      },
    });

    return {
      data: {
        following: true,
        followersCount,
      },
    };
  },

  async unfollowUser(ctx) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required');
    }

    const { documentId } = ctx.params;
    const targetUser = await strapi.documents('plugin::users-permissions.user').findOne({
      documentId,
    });

    if (!targetUser) {
      return ctx.notFound('User not found');
    }

    const existing = await strapi.documents('api::follow.follow').findFirst({
      filters: {
        follower: {
          id: user.id,
        },
        following: {
          id: targetUser.id,
        },
      },
    });

    if (existing) {
      await strapi.documents('api::follow.follow').delete({
        documentId: existing.documentId,
      });
    }

    const followersCount = await strapi.documents('api::follow.follow').count({
      filters: {
        following: {
          id: targetUser.id,
        },
      },
    });

    return {
      data: {
        following: false,
        followersCount,
      },
    };
  },
}));
