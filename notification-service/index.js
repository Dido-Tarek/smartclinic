const express = require('express');
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const app = express();
app.use(express.json());

// ─── Helpers ─────────────────────────────────────────────────────────────────

/**
 * Builds the platform-specific config blocks that guarantee the notification
 * reaches the Android system tray (via the correct channel) and iOS lock screen.
 */
function platformConfig(data) {
  return {
    android: {
      priority: 'high',
      notification: {
        channelId: 'smartclinic_notifications', // must match Flutter channel ID
        priority: 'high',
        defaultSound: true,
        defaultVibrateTimings: true,
      },
    },
    apns: {
      headers: { 'apns-priority': '10' },
      payload: {
        aps: {
          sound: 'default',
          badge: 1,
          contentAvailable: true,
        },
      },
    },
    ...(data && { data }),
  };
}

// ─── POST /send-notification ──────────────────────────────────────────────────
// Body: { token: string, title: string, body: string, data?: object }
app.post('/send-notification', async (req, res) => {
  const { token, title, body, data } = req.body;

  if (!token || !title || !body) {
    return res.status(400).json({ error: 'token, title, and body are required' });
  }

  try {
    const message = {
      token,
      notification: { title, body },
      ...platformConfig(data),
    };

    const response = await admin.messaging().send(message);
    return res.status(200).json({ success: true, messageId: response });
  } catch (err) {
    console.error('FCM send error:', err);
    return res.status(500).json({ error: err.message });
  }
});

// ─── POST /send-multicast ─────────────────────────────────────────────────────
// Body: { tokens: string[], title: string, body: string, data?: object }
app.post('/send-multicast', async (req, res) => {
  const { tokens, title, body, data } = req.body;

  if (!tokens?.length || !title || !body) {
    return res.status(400).json({ error: 'tokens[], title, and body are required' });
  }

  try {
    const message = {
      tokens,
      notification: { title, body },
      ...platformConfig(data),
    };

    const response = await admin.messaging().sendEachForMulticast(message);
    return res.status(200).json({
      success: true,
      successCount: response.successCount,
      failureCount: response.failureCount,
    });
  } catch (err) {
    console.error('FCM multicast error:', err);
    return res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Notification service running on port ${PORT}`));
