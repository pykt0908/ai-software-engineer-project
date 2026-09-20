export default {
  routes: [
    {
      method: 'GET',
      path: '/feed/public',
      handler: 'feed.publicFeed',
      config: {
        auth: false,
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
  ],
};
