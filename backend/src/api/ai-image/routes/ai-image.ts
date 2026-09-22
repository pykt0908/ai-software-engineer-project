export default {
  routes: [
    {
      method: 'POST',
      path: '/ai/generate-edit-prompt',
      handler: 'ai-image.generateEditPrompt',
      config: {
        policies: [],
      },
    },
    {
      method: 'POST',
      path: '/ai/image-edit',
      handler: 'ai-image.editImage',
      config: {
        policies: [],
      },
    },
    {
      method: 'GET',
      path: '/ai/jobs/:documentId',
      handler: 'ai-image.getJob',
      config: {
        policies: [],
      },
    },
    {
      method: 'POST',
      path: '/ai/jobs/:documentId/cancel',
      handler: 'ai-image.cancelJob',
      config: {
        policies: [],
      },
    },
  ],
};
