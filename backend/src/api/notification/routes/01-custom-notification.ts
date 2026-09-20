export default {
  routes: [
    {
      method: 'GET',
      path: '/notifications',
      handler: 'notification.listMine',
      config: { policies: [] },
    },
    {
      method: 'GET',
      path: '/notifications/unread-count',
      handler: 'notification.unreadCount',
      config: { policies: [] },
    },
    {
      method: 'POST',
      path: '/notifications/mark-all-read',
      handler: 'notification.markAllRead',
      config: { policies: [] },
    },
    {
      method: 'PATCH',
      path: '/notifications/:documentId/read',
      handler: 'notification.markRead',
      config: { policies: [] },
    },
    {
      method: 'DELETE',
      path: '/notifications/:documentId',
      handler: 'notification.deleteMine',
      config: { policies: [] },
    },
  ],
};
