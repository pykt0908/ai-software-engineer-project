import type { Core } from '@strapi/strapi';

export default {
  register({ strapi }: { strapi: Core.Strapi }) {},

  async bootstrap({ strapi }: { strapi: Core.Strapi }) {
    try {
      const publicRole = await strapi.db.query('plugin::users-permissions.role').findOne({
        where: { type: 'public' },
      });
      const authRole = await strapi.db.query('plugin::users-permissions.role').findOne({
        where: { type: 'authenticated' },
      });

      if (!publicRole || !authRole) {
        return;
      }

      const publicActions = [
        'api::feed.feed.publicFeed',
        'api::feed.feed.seed',
        'api::profile.profile.getProfile',
        'api::profile.profile.getUserPosts',
        'api::profile.profile.searchUsers',
        'api::post.post.findOne',
        'api::post.post.listComments',
        'plugin::users-permissions.auth.callback',
        'plugin::users-permissions.auth.register',
        'plugin::users-permissions.auth.refresh',
      ];

      const authActions = [
        'api::feed.feed.publicFeed',
        'api::feed.feed.followingFeed',
        'api::feed.feed.seed',
        'api::profile.profile.getMe',
        'api::profile.profile.updateMe',
        'api::profile.profile.getProfile',
        'api::profile.profile.getUserPosts',
        'api::profile.profile.searchUsers',
        'api::post.post.create',
        'api::post.post.findOne',
        'api::post.post.update',
        'api::post.post.delete',
        'api::post.post.like',
        'api::post.post.unlike',
        'api::post.post.listComments',
        'api::post.post.createComment',
        'api::comment.comment.deleteOwn',
        'api::follow.follow.followUser',
        'api::follow.follow.unfollowUser',
        'api::notification.notification.listMine',
        'api::notification.notification.unreadCount',
        'api::notification.notification.markRead',
        'api::notification.notification.markAllRead',
        'api::notification.notification.deleteMine',
        'api::ai-caption.ai-caption.generate',
        'api::ai-image.ai-image.generateEditPrompt',
        'api::ai-image.ai-image.editImage',
        'api::ai-image.ai-image.getJob',
        'api::ai-image.ai-image.cancelJob',
        'plugin::upload.content-api.upload',
        'plugin::upload.content-api.destroy',
        'plugin::upload.content-api.find',
        'plugin::upload.content-api.findOne',
        'plugin::users-permissions.auth.changePassword',
        'plugin::users-permissions.auth.refresh',
        'plugin::users-permissions.auth.logout',
        'plugin::users-permissions.user.me',
      ];

      for (const action of publicActions) {
        const existing = await strapi.db.query('plugin::users-permissions.permission').findOne({
          where: { action, role: publicRole.id },
        });
        if (!existing) {
          await strapi.db.query('plugin::users-permissions.permission').create({
            data: { action, role: publicRole.id },
          });
        }
      }

      for (const action of authActions) {
        const existing = await strapi.db.query('plugin::users-permissions.permission').findOne({
          where: { action, role: authRole.id },
        });
        if (!existing) {
          await strapi.db.query('plugin::users-permissions.permission').create({
            data: { action, role: authRole.id },
          });
        }
      }

      // Also ensure email confirmation is disabled per spec.md Section 10
      const pluginStore = strapi.store({ type: 'plugin', name: 'users-permissions' });
      const advancedSettings: any = await pluginStore.get({ key: 'advanced' });
      if (advancedSettings && advancedSettings.email_confirmation === true) {
        advancedSettings.email_confirmation = false;
        await pluginStore.set({ key: 'advanced', value: advancedSettings });
      }

      // Check if there are any posts; if empty, auto-seed mock cats
      const postCount = await strapi.documents('api::post.post').count({
        filters: { moderationStatus: 'visible' },
      });
      if (postCount === 0) {
        console.log('No posts found in database. Auto-seeding mock cats...');
        try {
          const { seedMockCats } = await import('./seed-mock-cats');
          await seedMockCats();
          console.log('Auto-seeding mock cats completed successfully.');
        } catch (seedErr) {
          console.error('Auto-seed mock cats error:', seedErr);
        }
      }

      // Start background Push Notification queue worker
      try {
        const { startPushWorker } = await import('./workers/push-worker');
        startPushWorker(strapi);
      } catch (workerErr) {
        strapi.log.error(`Failed to start PushWorker: ${workerErr}`);
      }
    } catch (err) {
      console.error('Error during Strapi bootstrap permission configuration:', err);
    }
  },
};
