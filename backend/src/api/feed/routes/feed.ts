export default {
  routes: [
    {
      method: 'GET',
      path: '/feed/public',
      handler: 'feed.publicFeed',
      config: {
        policies: [],
      },
    },
    {
      method: 'GET',
      path: '/feed/following',
      handler: 'feed.followingFeed',
      config: {
        policies: [],
      },
    },
    {
      method: 'POST',
      path: '/feed/seed',
      handler: 'feed.seed',
      config: {
        policies: [],
      },
    },
  ],
};
