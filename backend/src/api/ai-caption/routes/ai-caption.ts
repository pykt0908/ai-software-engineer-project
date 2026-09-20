export default {
  routes: [
    {
      method: 'POST',
      path: '/ai-caption/generate',
      handler: 'ai-caption.generate',
      config: {
        policies: [],
      },
    },
  ],
};
