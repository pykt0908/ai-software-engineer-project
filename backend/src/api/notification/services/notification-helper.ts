import type { Core } from '@strapi/strapi';

type NotificationType = 'like' | 'comment' | 'follow';

type CreateNotificationInput = {
  recipientId: number | string;
  actorId: number | string;
  type: NotificationType;
  message: string;
  postId?: number | string;
  commentId?: number | string;
};

/**
 * Creates an in-app notification. Skips self-actions and duplicate recent events.
 */
export async function createNotification(
  strapi: Core.Strapi,
  input: CreateNotificationInput,
) {
  if (!input.recipientId || !input.actorId) return;
  if (input.recipientId === input.actorId) return;

  try {
    // Deduplicate: same actor/type/post within a short window (or unread follow).
    const filters: any = {
      recipient: { id: input.recipientId },
      actor: { id: input.actorId },
      type: input.type,
      isRead: false,
    };
    if (input.postId) {
      filters.post = { id: input.postId };
    }

    const existing = await strapi.documents('api::notification.notification').findFirst({
      filters,
    });

    if (existing) {
      // Bump timestamp by recreating for like/comment so it stays "new".
      if (input.type === 'follow') return;
      await strapi.documents('api::notification.notification').delete({
        documentId: existing.documentId,
      });
    }

    await strapi.documents('api::notification.notification').create({
      data: {
        recipient: input.recipientId,
        actor: input.actorId,
        type: input.type,
        message: input.message.slice(0, 200),
        isRead: false,
        ...(input.postId ? { post: input.postId } : {}),
        ...(input.commentId ? { comment: input.commentId } : {}),
      } as any,
    });
  } catch (err) {
    strapi.log.warn(`Failed to create notification: ${err}`);
  }
}

export function mapNotificationActor(actor: any) {
  return {
    documentId: actor?.documentId,
    username: actor?.username,
    displayName: actor?.displayName || actor?.username,
    avatarUrl: actor?.avatar?.url || null,
  };
}

export function mapNotification(n: any) {
  const postImages = Array.isArray(n.post?.images) ? n.post.images : [];
  const firstImage = postImages[0];
  return {
    documentId: n.documentId,
    id: n.id,
    type: n.type,
    message: n.message || '',
    isRead: n.isRead === true,
    createdAt: n.createdAt,
    actor: mapNotificationActor(n.actor),
    post: n.post
      ? {
          documentId: n.post.documentId,
          caption: n.post.caption || '',
          imageUrl: firstImage?.url || null,
        }
      : null,
    isFollowing: n.isFollowing === true,
  };
}
