import FlutterMacOS
import Foundation

public class AtlasCodePlugin: NSObject, FlutterPlugin, AtlasCodeApi {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let binaryMessenger = registrar.messenger
    let instance = AtlasCodePlugin()
    AtlasCodeApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)
    registrar.publish(instance)
  }

  func localizedCountryNames(languageTag: String) throws -> [String: String] {
    let target = Locale(identifier: languageTag)
    var names = [String: String]()
    for code in NSLocale.isoCountryCodes {
      if let name = target.localizedString(forRegionCode: code) {
        names[code.uppercased()] = name
      }
    }
    return names
  }
}
