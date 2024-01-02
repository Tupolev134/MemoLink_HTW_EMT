import Foundation

struct Contact: Identifiable {
    var id: String        // eventuell NFC-Tag-ID
    var name: String
    var phoneNumber: String?
    var birthday: Date?
    var nfcTagIdentifier: String?

    init(id: String, name: String, phoneNumber: String? = nil, email: String? = nil, birthday: Date? = nil, nfcTagIdentifier: String? = nil) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.birthday = birthday
        self.nfcTagIdentifier = nfcTagIdentifier
    }

}
