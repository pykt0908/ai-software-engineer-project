import { factories } from '@strapi/strapi';
import { mapNotification } from '../services/notification-helper';

export default factories.createCoreController(
  'api::notification.notification',
  ({ strapi }) => ({
    async listMine(ctx) {
      const user = ctx.state.user;
      if (!user) {
        return ctx.unauthorized('Authentication required');
      }

      const page = Math.max(1, parseInt(String(ctx.query.page || '1'), 10) || 1);
      const pageSize = Math.min(
        50,
        Math.max(1, parseInt(String(ctx.query.pageSize || '30'), 10) || 30),
      );
      const type = typeof ctx.query.type === 'string' ? ctx.query.type : '';

      const filters: any = {
        recipient: { id: user.id },
      };
      if (type && ['like', 'comment', 'follow'].includes(type)) {
        filters.type = type;
      }

      const [items, total] = await Promise.all([
        strapi.documents('api::notification.notification').findMany({
          filters,
          populate: ['actor', 'actor.avatar', 'post', 'post.images'],
          sort: [{ createdAt: 'desc' }],
          start: (page - 1) * pageSize,
          limit: pageSize,
        }),
        strapi.documents('api::notification.notification').count({ filters }),
      ]);

      // Enrich follow notifications with whether current user follows the actor.
      const data = [];
      for (const item of items as any[]) {
        let isFollowing = false;
        if (item.type === 'follow' && item.actor?.id) {
          const rel = await strapi.documents('api::follow.follow').findFirst({
            filters: {
              follower: { id: user.id },
              following: { id: item.actor.id },
            },
          });
          isFollowing = !!rel;
        }
        data.push(mapNotification({ ...item, isFollowing }));
      }

      return {
        data,
        meta: {
          page,
          pageSize,
          total,
        },
      };
    },

    async unreadCount(ctx) {
      const user = ctx.state.user;
      if (!user) {
        return ctx.unauthorized('Authentication required');
      }

      const count = await strapi.documents('api::notification.notification').count({
        filters: {
          recipient: { id: user.id },
          isRead: false,
        },
      });

      return { data: { unreadCount: count } };
    },

    async markRead(ctx) {
      const user = ctx.state.user;
      if (!user) {
        return ctx.unauthorized('Authentication required');
      }

      const documentId = String(ctx.params.documentId || '');
      if (!documentId) {
        return ctx.badRequest('Missing notification id');
      }

      const item = await strapi.documents('api::notification.notification').findOne({
        documentId,
        populate: ['recipient'],
      });

      if (!item) {
        return ctx.notFound('Notification not found');
      }

      if ((item as any).recipient?.id !== user.id) {
        return ctx.forbidden('Not your notification');
      }

      const updated = await strapi.documents('api::notification.notification').update({
        documentId,
        data: { isRead: true } as any,
        populate: ['actor', 'actor.avatar', 'post', 'post.images'],
      });

      return { data: mapNotification(updated) };
    },

    async markAllRead(ctx) {
      const user = ctx.state.user;
      if (!user) {
        return ctx.unauthorized('Authentication required');
      }

      const unread = await strapi.documents('api::notification.notification').findMany({
        filters: {
          recipient: { id: user.id },
          isRead: false,
        },
        limit: 200,
      });

      for (const item of unread as any[]) {
        await strapi.documents('api::notification.notification').update({
          documentId: item.documentId,
          data: { isRead: true } as any,
        });
      }

      return { data: { marked: (unread as any[]).length } };
    },

    async deleteMine(ctx) {
      const user = ctx.state.user;
      if (!user) {
        return ctx.unauthorized('Authentication required');
      }

      const documentId = String(ctx.params.documentId || '');
      if (!documentId) {
        return ctx.badRequest('Missing notification id');
      }

      const item = await strapi.documents('api::notification.notification').findOne({
        documentId,
        populate: ['recipient'],
      });

      if (!item) {
        return ctx.notFound('Notification not found');
      }

      if ((item as any).recipient?.id !== user.id) {
        return ctx.forbidden('Not your notification');
      }

      await strapi.documents('api::notification.notification').delete({ documentId });
      return { data: { deleted: true } };
    },
  }),
);
