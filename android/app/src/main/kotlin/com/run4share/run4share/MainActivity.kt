package com.run4share.run4share

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.os.Bundle
import androidx.core.content.FileProvider
import java.io.File
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity: the health plugin asks Health Connect for
// permissions with registerForActivityResult.
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Health Connect opens us to show why we ask for its data: send the
        // user to the privacy policy instead of starting the app.
        if (intent?.action == "androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE" ||
            intent?.action == "android.intent.action.VIEW_PERMISSION_USAGE"
        ) {
            super.onCreate(savedInstanceState)
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(PRIVACY_POLICY)))
            finish()
            return
        }
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Android 13+: the system screen that sets this app's
                    // language. Returns false on older Android, where the
                    // app shows its own list instead.
                    "openAppLanguageSettings" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            val intent = Intent(Settings.ACTION_APP_LOCALE_SETTINGS)
                                .setData(Uri.fromParts("package", packageName, null))
                            startActivity(intent)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }
                    // The sticker-only PNG onto the clipboard, as an image a
                    // story editor can paste. The clipboard grants the
                    // pasting app read access to the content URI.
                    "copyImage" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.success(false)
                        } else {
                            try {
                                val uri = FileProvider.getUriForFile(
                                    this,
                                    "$packageName.clipboard",
                                    File(path),
                                )
                                val clip = ClipData.newUri(
                                    contentResolver,
                                    "run4share sticker",
                                    uri,
                                )
                                val clipboard =
                                    getSystemService(CLIPBOARD_SERVICE) as ClipboardManager
                                clipboard.setPrimaryClip(clip)
                                result.success(true)
                            } catch (e: Exception) {
                                result.success(false)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    companion object {
        private const val CHANNEL = "run4share/system"

        // Keep in step with AppLinks.privacyPolicy (lib/app/links.dart).
        private const val PRIVACY_POLICY =
            "https://franciscosouza.github.io/run4share/privacy/"
    }
}
