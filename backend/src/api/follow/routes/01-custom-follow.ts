export default {
  routes: [
    {
      method: 'POST',
      path: '/users/:documentId/follow',
      handler: 'follow.followUser',
      config: {
        policies: [],
      },
    },
    {
      method: 'DELETE',
      path: '/users/:documentId/follow',
      handler: 'follow.unfollowUser',
      config: {
        policies: [],
      },
    },
  ],
};
