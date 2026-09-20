export default {
  routes: [
    {
      method: 'GET',
      path: '/me',
      handler: 'profile.getMe',
      config: {
        policies: [],
      },
    },
    {
      method: 'PUT',
      path: '/me',
      handler: 'profile.updateMe',
      config: {
        policies: [],
      },
    },
    {
      method: 'GET',
      path: '/profiles/search',
      handler: 'profile.searchUsers',
      config: {
        auth: false,
        policies: [],
      },
    },
    {
      method: 'GET',
      path: '/profiles/:username',
      handler: 'profile.getProfile',
      config: {
        policies: [],
      },
    },
    {
      method: 'GET',
      path: '/profiles/:username/posts',
      handler: 'profile.getUserPosts',
      config: {
        policies: [],
      },
    },
  ],
};
