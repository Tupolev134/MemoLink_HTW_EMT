import Contacts
import Foundation

struct Contact: Identifiable, Codable {
    var id: UUID
    var contactIdentifier: String
    var nfcTagID: String?

    init(contactIdentifier: String, nfcTagID: String? = nil) {
        self.id = UUID()
        self.contactIdentifier = contactIdentifier
        self.nfcTagID = nfcTagID
    }
}
