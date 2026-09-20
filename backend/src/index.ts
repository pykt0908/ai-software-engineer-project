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
        'api::profile.profile.getProfile',
        'api::profile.profile.getUserPosts',
        'api::profile.profile.searchUsers',
        'api::post.post.findOne',
        'plugin::users-permissions.auth.callback',
        'plugin::users-permissions.auth.register',
        'plugin::users-permissions.auth.refresh',
      ];

      const authActions = [
        'api::feed.feed.publicFeed',
        'api::feed.feed.followingFeed',
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
        'api::follow.follow.followUser',
        'api::follow.follow.unfollowUser',
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
    } catch (err) {
      console.error('Error during Strapi bootstrap permission configuration:', err);
    }
  },
};
