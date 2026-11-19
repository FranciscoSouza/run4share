package com.run4share.run4share

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageDecoder
import android.graphics.Matrix
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.os.Bundle
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.FileProvider
import androidx.exifinterface.media.ExifInterface
import java.io.File
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity: the health plugin asks Health Connect for
// permissions with registerForActivityResult.
class MainActivity : FlutterFragmentActivity() {
    // Android's own photo picker: no photo permission, which Google Play
    // requires of apps that pick a photo now and then. On phones without
    // it, the contract falls back to the system document picker.
    private var pendingPick: MethodChannel.Result? = null
    private val pickImage =
        registerForActivityResult(ActivityResultContracts.PickVisualMedia()) { uri ->
            val result = pendingPick ?: return@registerForActivityResult
            pendingPick = null
            if (uri == null) {
                result.success(null)
                return@registerForActivityResult
            }
            Thread {
                val path = try {
                    savePicked(uri)
                } catch (e: Exception) {
                    null
                }
                runOnUiThread { result.success(path) }
            }.start()
        }

    /// The picked image, upright, at most PICK_MAX_SIDE on its longest
    /// side, as a JPEG in the cache; returns its path.
    private fun savePicked(uri: Uri): String {
        val bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val source = ImageDecoder.createSource(contentResolver, uri)
            ImageDecoder.decodeBitmap(source) { decoder, info, _ ->
                val w = info.size.width
                val h = info.size.height
                val scale = minOf(1.0, PICK_MAX_SIDE.toDouble() / maxOf(w, h))
                decoder.setTargetSize(
                    maxOf(1, (w * scale).toInt()),
                    maxOf(1, (h * scale).toInt()),
                )
                decoder.allocator = ImageDecoder.ALLOCATOR_SOFTWARE
            }
        } else {
            decodeLegacy(uri)
        }
        val out = File(cacheDir, "picked").apply { mkdirs() }
        val file = File(out, "picked-${System.currentTimeMillis()}.jpg")
        file.outputStream().use { bitmap.compress(Bitmap.CompressFormat.JPEG, 92, it) }
        bitmap.recycle()
        return file.absolutePath
    }

    /// Android 8: sample down, then turn upright from the EXIF orientation.
    private fun decodeLegacy(uri: Uri): Bitmap {
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        contentResolver.openInputStream(uri)?.use { BitmapFactory.decodeStream(it, null, bounds) }
        var sample = 1
        while (maxOf(bounds.outWidth, bounds.outHeight) / (sample * 2) >= PICK_MAX_SIDE) sample *= 2
        val options = BitmapFactory.Options().apply { inSampleSize = sample }
        val decoded = contentResolver.openInputStream(uri)!!.use {
            BitmapFactory.decodeStream(it, null, options)!!
        }
        val rotation = contentResolver.openInputStream(uri)!!.use {
            when (ExifInterface(it).getAttributeInt(
                ExifInterface.TAG_ORIENTATION,
                ExifInterface.ORIENTATION_NORMAL,
            )) {
                ExifInterface.ORIENTATION_ROTATE_90 -> 90f
                ExifInterface.ORIENTATION_ROTATE_180 -> 180f
                ExifInterface.ORIENTATION_ROTATE_270 -> 270f
                else -> 0f
            }
        }
        val scale = minOf(1f, PICK_MAX_SIDE.toFloat() / maxOf(decoded.width, decoded.height))
        val matrix = Matrix().apply {
            postScale(scale, scale)
            postRotate(rotation)
        }
        return Bitmap.createBitmap(decoded, 0, 0, decoded.width, decoded.height, matrix, true)
    }

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
                    // One photo from Android's picker; null if cancelled.
                    "pickImage" -> {
                        pendingPick?.success(null)
                        pendingPick = result
                        pickImage.launch(
                            PickVisualMediaRequest(
                                ActivityResultContracts.PickVisualMedia.ImageOnly,
                            ),
                        )
                    }
                    else -> result.notImplemented()
                }
            }
    }

    companion object {
        private const val CHANNEL = "run4share/system"

        // The export size (exportPhotoMaxSide in Dart).
        private const val PICK_MAX_SIDE = 3072

        // Keep in step with AppLinks.privacyPolicy (lib/app/links.dart).
        private const val PRIVACY_POLICY =
            "https://franciscosouza.github.io/run4share/privacy/"
    }
}
