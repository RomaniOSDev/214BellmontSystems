import UIKit

enum AppLink: String {
    case privacyPolicy = "https://bellmont214systems.site/privacy/252"
    case termsOfService = "https://bellmont214systems.site/terms/252"

    var url: URL? {
        URL(string: rawValue)
    }

    func open() {
        guard let url else { return }
        UIApplication.shared.open(url)
    }
}
