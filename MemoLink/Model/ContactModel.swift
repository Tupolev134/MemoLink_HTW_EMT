import Contacts
import Foundation

struct Contact: Identifiable, Codable {
    var id: UUID
    var contactIdentifier: String
    var nfcTagID: String?
    var callCount: Int = 0
    var cooldownEnds: Date?
    
    init(contactIdentifier: String, nfcTagID: String? = nil) {
        self.id = UUID()
        self.contactIdentifier = contactIdentifier
        self.nfcTagID = nfcTagID
    }
    
    static var defaultContact: Contact {
        return Contact(contactIdentifier: "Default", nfcTagID: nil)
    }
}
