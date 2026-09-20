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
    {
      method: 'GET',
      path: '/posts/:documentId/comments',
      handler: 'post.listComments',
      config: {
        policies: [],
        auth: false,
      },
    },
    {
      method: 'POST',
      path: '/posts/:documentId/comments',
      handler: 'post.createComment',
      config: {
        policies: [],
      },
    },
  ],
};
