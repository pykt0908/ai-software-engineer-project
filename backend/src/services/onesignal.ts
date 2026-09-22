export type SendOneSignalPushParams = {
  externalUserIds: string[];
  title?: string;
  message: string;
  data?: Record<string, any>;
};

export type OneSignalResponse = {
  success: boolean;
  id?: string;
  recipients?: number;
  error?: string;
};

/**
 * Dispatches a push notification via OneSignal REST API.
 * Uses external_id to map Strapi User IDs to OneSignal player/subscription records.
 */
export async function sendOneSignalPush({
  externalUserIds,
  title = 'InstaCat',
  message,
  data = {},
}: SendOneSignalPushParams): Promise<OneSignalResponse> {
  const appId = process.env.ONESIGNAL_APP_ID;
  const apiKey = process.env.ONESIGNAL_REST_API_KEY;

  if (!appId || !apiKey) {
    // In dev / test environments without keys, log and return gracefully
    return {
      success: true,
      recipients: externalUserIds.length,
      error: 'OneSignal credentials not set (mock delivery in dev mode)',
    };
  }

  if (!externalUserIds.length) {
    return { success: true, recipients: 0 };
  }

  try {
    const payload = {
      app_id: appId,
      include_aliases: {
        external_id: externalUserIds.map(String),
      },
      target_channel: 'push',
      priority: 10,
      headings: {
        en: title,
      },
      contents: {
        en: message,
      },
      data,
    };

    const res = await fetch('https://api.onesignal.com/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        Authorization: `Key ${apiKey}`,
      },
      body: JSON.stringify(payload),
    });

    const result = (await res.json()) as any;

    if (!res.ok || result?.errors) {
      const errStr = Array.isArray(result?.errors)
        ? result.errors.join(', ')
        : typeof result?.errors === 'object'
        ? JSON.stringify(result.errors)
        : result?.errors || `HTTP error ${res.status}`;
      return {
        success: false,
        error: errStr,
      };
    }

    return {
      success: true,
      id: result.id,
      recipients: result.recipients || externalUserIds.length,
    };
  } catch (err: any) {
    return {
      success: false,
      error: err?.message || String(err),
    };
  }
}
