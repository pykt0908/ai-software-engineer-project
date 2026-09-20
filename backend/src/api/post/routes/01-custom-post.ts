export default {
  routes: [
    {
      method: 'POST',
      path: '/posts/:documentId/like',
      handler: 'post.like',
      config: {
        policies: [],
      },
    },
    {
      method: 'DELETE',
      path: '/posts/:documentId/like',
      handler: 'post.unlike',
      config: {
        policies: [],
      },
    },
  ],
};
