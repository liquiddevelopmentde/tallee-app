package de.liquid.tallee

import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener
import java.io.File

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val path = resolveIntent(intent) ?: return

        // Cold start: the Flutter framework (and thus its navigation channel
        // handler) is not ready yet. Pushing now would drop the message, so
        // defer until the first frame is rendered.
        val renderer = flutterEngine.renderer
        if (renderer.isDisplayingFlutterUi) {
            pushRoute(path)
        } else {
            renderer.addIsDisplayingFlutterUiListener(
                object : FlutterUiDisplayListener {
                    override fun onFlutterUiDisplayed() {
                        renderer.removeIsDisplayingFlutterUiListener(this)
                        pushRoute(path)
                    }

                    override fun onFlutterUiNoLongerDisplayed() {}
                },
            )
        }
    }

    // App already running (singleTask): the framework is ready, push directly.
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        resolveIntent(intent)?.let { pushRoute(it) }
    }

    // Hands the resolved file path to Flutter as a route, exactly like the
    // platform does on iOS. It arrives in Dart's onGenerateRoute.
    private fun pushRoute(route: String) {
        flutterEngine?.navigationChannel?.pushRoute(route)
    }

    // Resolves a VIEW/EDIT intent to a concrete, readable file path. Both
    // file:// and content:// URIs are copied into the cache directory so
    // Dart's File can read them directly.
    private fun resolveIntent(intent: Intent?): String? {
        if (intent?.action != Intent.ACTION_VIEW &&
            intent?.action != Intent.ACTION_EDIT
        ) {
            return null
        }
        val uri = intent.data ?: return null
        return copyUriToCache(uri)
    }

    private fun copyUriToCache(uri: Uri): String? {
        return try {
            val fileName = queryFileName(uri) ?: "import.tallee"
            val outFile = File(cacheDir, fileName)
            contentResolver.openInputStream(uri)?.use { input ->
                outFile.outputStream().use { output -> input.copyTo(output) }
            } ?: return null
            outFile.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private fun queryFileName(uri: Uri): String? {
        if (uri.scheme == "file") return uri.lastPathSegment
        var name: String? = null
        contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (index >= 0 && cursor.moveToFirst()) {
                name = cursor.getString(index)
            }
        }
        return name
    }
}
