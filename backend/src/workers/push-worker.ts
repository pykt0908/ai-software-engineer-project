import type { Core } from '@strapi/strapi';
import { sendOneSignalPush } from '../services/onesignal';

let isRunning = false;

/**
 * Processes a batch of pending push notification jobs from the push_queue table.
 */
export async function processPushQueueBatch(strapiInstance?: Core.Strapi, batchSize = 50) {
  const strapi = strapiInstance || (global as any).strapi;
  if (!strapi || !strapi.documents) {
    return;
  }

  if (isRunning) {
    return;
  }

  isRunning = true;
  try {
    // 1. Fetch pending jobs
    const jobs = await strapi.documents('api::push-queue.push-queue').findMany({
      filters: {
        status: 'pending',
        attempts: {
          $lt: 3,
        },
      },
      limit: batchSize,
      sort: ['createdAt:asc'],
      populate: ['recipient', 'actor'],
    });

    if (!jobs || jobs.length === 0) {
      return;
    }

    strapi.log.info(`[PushWorker] Processing ${jobs.length} pending push jobs...`);

    for (const job of jobs) {
      const recipient = (job as any).recipient;
      // Prefer documentId as Flutter registers OneSignal with user.documentId
      const targetExternalIds = [
        recipient?.documentId ? String(recipient.documentId) : null,
      ].filter((x): x is string => Boolean(x));

      // Fallback to integer id if documentId not present
      if (targetExternalIds.length === 0 && recipient?.id) {
        targetExternalIds.push(String(recipient.id));
      }

      if (targetExternalIds.length === 0) {
        // Invalid recipient, mark failed
        await strapi.documents('api::push-queue.push-queue').update({
          documentId: job.documentId,
          data: {
            status: 'failed',
            lastError: 'Missing recipient user reference',
            processedAt: new Date().toISOString(),
          } as any,
        });
        continue;
      }

      // Mark processing
      await strapi.documents('api::push-queue.push-queue').update({
        documentId: job.documentId,
        data: {
          status: 'processing',
        } as any,
      });

      // Dispatch to OneSignal via External ID
      const result = await sendOneSignalPush({
        externalUserIds: targetExternalIds,
        title: job.title || 'InstaCat',
        message: job.message || '',
        data: (job.payload as Record<string, any>) || {},
      });

      if (result.success) {
        await strapi.documents('api::push-queue.push-queue').update({
          documentId: job.documentId,
          data: {
            status: 'completed',
            processedAt: new Date().toISOString(),
            lastError: result.error ? `Dev note: ${result.error}` : null,
          } as any,
        });
      } else {
        const isPermanent =
          result.error?.includes('not subscribed') ||
          result.error?.includes('invalid_aliases') ||
          result.error?.includes('not found');

        const nextAttempts = isPermanent ? 3 : ((job as any).attempts || 0) + 1;
        await strapi.documents('api::push-queue.push-queue').update({
          documentId: job.documentId,
          data: {
            status: nextAttempts >= 3 ? 'failed' : 'pending',
            attempts: nextAttempts,
            lastError: result.error || 'Unknown dispatch error',
            processedAt: new Date().toISOString(),
          } as any,
        });
      }
    }
  } catch (err) {
    if (strapi && strapi.log) {
      strapi.log.error(`[PushWorker] Error while processing queue: ${err}`);
    } else {
      console.error(`[PushWorker] Error while processing queue: ${err}`);
    }
  } finally {
    isRunning = false;
  }
}

/**
 * Initializes the background queue worker timer.
 */
export function startPushWorker(strapi: Core.Strapi, intervalMs = 5000) {
  const app = strapi || (global as any).strapi;
  if (!app) {
    console.error('[PushWorker] Cannot start worker: Strapi instance is missing');
    return null;
  }

  app.log.info(`[PushWorker] Starting background push queue worker (interval: ${intervalMs}ms)`);
  
  // Run first pass after 1 second
  setTimeout(() => {
    processPushQueueBatch(app).catch((err) => {
      app.log.error(`[PushWorker] Initial run error: ${err}`);
    });
  }, 1000);

  const timer = setInterval(() => {
    processPushQueueBatch(app).catch((err) => {
      app.log.error(`[PushWorker] Interval run error: ${err}`);
    });
  }, intervalMs);

  return timer;
}
