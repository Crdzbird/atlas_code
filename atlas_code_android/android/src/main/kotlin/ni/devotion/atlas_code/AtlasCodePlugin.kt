package ni.devotion.atlas_code
import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.util.Locale

class AtlasCodePlugin : FlutterPlugin, AtlasCodeApi {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        AtlasCodeApi.setUp(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        AtlasCodeApi.setUp(binding.binaryMessenger, null)
    }

    override fun localizedCountryNames(languageTag: String): Map<String, String> {
        val target = Locale.forLanguageTag(languageTag)
        val names = mutableMapOf<String, String>()
        for (code in Locale.getISOCountries()) {
            val name = Locale.Builder().setRegion(code).build().getDisplayCountry(target)
            // getDisplayCountry echoes the code back when it has no
            // translation; omit those so Dart falls back to bundled names.
            if (name.isNotEmpty() && name != code) {
                names[code.uppercase(Locale.ROOT)] = name
            }
        }
        return names
    }
}
