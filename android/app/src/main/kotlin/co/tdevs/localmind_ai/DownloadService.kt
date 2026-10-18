package co.tdevs.localmind_ai

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder

/**
 * Keeps the app process alive while a user-started model download runs, so it
 * continues when the app is in the background. The download itself happens in
 * Dart; this service only holds the foreground notification.
 */
class DownloadService : Service() {
    companion object {
        private const val CHANNEL_ID = "model_downloads"
        private const val NOTIFICATION_ID = 4201
        const val EXTRA_TITLE = "title"
        const val EXTRA_TEXT = "text"
        const val EXTRA_PROGRESS = "progress"
        const val EXTRA_CHANNEL_NAME = "channelName"

        fun buildNotification(
            context: Context,
            title: String,
            text: String,
            progress: Int,
        ): Notification {
            val open = PendingIntent.getActivity(
                context,
                0,
                Intent(context, MainActivity::class.java)
                    .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
                PendingIntent.FLAG_IMMUTABLE,
            )
            return Notification.Builder(context, CHANNEL_ID)
                .setSmallIcon(android.R.drawable.stat_sys_download)
                .setContentTitle(title)
                .setContentText(text)
                .setContentIntent(open)
                .setOngoing(true)
                .setOnlyAlertOnce(true)
                .setCategory(Notification.CATEGORY_PROGRESS)
                .apply {
                    if (progress in 0..100) setProgress(100, progress, false)
                    else setProgress(0, 0, true)
                }
                .build()
        }

        fun update(context: Context, title: String, text: String, progress: Int) {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.notify(NOTIFICATION_ID, buildNotification(context, title, text, progress))
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelName = intent?.getStringExtra(EXTRA_CHANNEL_NAME) ?: "Model downloads"
        nm.createNotificationChannel(
            NotificationChannel(CHANNEL_ID, channelName, NotificationManager.IMPORTANCE_LOW)
        )
        val notification = buildNotification(
            this,
            intent?.getStringExtra(EXTRA_TITLE) ?: "",
            intent?.getStringExtra(EXTRA_TEXT) ?: "",
            intent?.getIntExtra(EXTRA_PROGRESS, -1) ?: -1,
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
        return START_NOT_STICKY
    }

    override fun onTimeout(startId: Int, fgsType: Int) {
        // Android 15 caps dataSync services; stop cleanly. The partial file is
        // kept and the download can be resumed from the app.
        stopSelf()
    }
}
