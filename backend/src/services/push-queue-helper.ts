import type { Core } from '@strapi/strapi';
import { processPushQueueBatch } from '../workers/push-worker';

export type PushEventType = 'like' | 'comment' | 'follow' | 'new_post';

export type EnqueuePushInput = {
  recipientId: number | string;
  actorId?: number | string;
  eventType: PushEventType;
  title?: string;
  message: string;
  payload?: Record<string, any>;
};

/**
 * Inserts a single push notification job into the push queue table.
 * Skips self-targeted notifications and triggers immediate dispatch.
 */
export async function enqueuePush(
  strapi: Core.Strapi,
  input: EnqueuePushInput,
) {
  if (!input.recipientId) return null;
  if (input.actorId && String(input.recipientId) === String(input.actorId)) {
    return null; // Skip self notification
  }

  try {
    // Deduplicate: ignore identical push notification enqueued within the last 10 seconds
    const tenSecondsAgo = new Date(Date.now() - 10000).toISOString();
    const duplicate = await strapi.documents('api::push-queue.push-queue').findFirst({
      filters: {
        recipient: { id: input.recipientId },
        eventType: input.eventType,
        ...(input.actorId ? { actor: { id: input.actorId } } : {}),
        createdAt: { $gte: tenSecondsAgo },
      },
    });

    if (duplicate) {
      strapi.log.info(`[PushQueue] Skipping duplicate push job for ${input.eventType}`);
      return null;
    }

    const job = await strapi.documents('api::push-queue.push-queue').create({
      data: {
        recipient: input.recipientId,
        ...(input.actorId ? { actor: input.actorId } : {}),
        eventType: input.eventType,
        title: input.title || 'InstaCat',
        message: input.message,
        payload: input.payload || {},
        status: 'pending',
        attempts: 0,
      } as any,
    });

    // Trigger immediate queue processing (fast dispatch without waiting for next tick)
    setImmediate(() => {
      processPushQueueBatch(strapi).catch(() => {});
    });

    return job;
  } catch (err) {
    strapi.log.warn(`[PushQueue] Failed to enqueue push job: ${err}`);
    return null;
  }
}

/**
 * Enqueues push notifications to all followers when a user creates a new post.
 */
export async function enqueueFollowersPush(
  strapi: Core.Strapi,
  {
    authorId,
    actorDisplayName,
    post,
  }: {
    authorId: number | string;
    actorDisplayName?: string;
    post: any;
  },
) {
  if (!authorId) return;

  try {
    const follows = await strapi.documents('api::follow.follow').findMany({
      filters: {
        following: { id: authorId },
      },
      populate: ['follower'],
    });

    if (!follows || follows.length === 0) return;

    const postRef = post.documentId || post.id;
    const authorName = actorDisplayName || 'Someone you follow';
    const message = `${authorName} shared a new post.`;

    for (const follow of follows) {
      const follower = (follow as any).follower;
      const followerId = follower?.id;
      if (followerId && String(followerId) !== String(authorId)) {
        await enqueuePush(strapi, {
          recipientId: followerId,
          actorId: authorId,
          eventType: 'new_post',
          title: 'InstaCat',
          message,
          payload: {
            postId: postRef,
            type: 'new_post',
            screen: 'post_detail',
          },
        });
      }
    }

    // Trigger immediate queue processing for followers push
    setImmediate(() => {
      processPushQueueBatch(strapi).catch(() => {});
    });
  } catch (err) {
    strapi.log.warn(`[PushQueue] Failed to enqueue followers push: ${err}`);
  }
}
