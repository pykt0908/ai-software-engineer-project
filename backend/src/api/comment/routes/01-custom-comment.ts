export default {
  routes: [
    {
      method: 'DELETE',
      path: '/comments/:documentId',
      handler: 'comment.deleteOwn',
      config: {
        policies: [],
      },
    },
  ],
};
