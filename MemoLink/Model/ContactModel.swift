import Foundation

struct Contact: Identifiable {
    var id = UUID()        // eventuell NFC-Tag-ID
    var name: String
    var phoneNumber: String?
    var birthday: Date?
    var nfcTagIdentifier: String?

    init(name: String, phoneNumber: String? = nil, email: String? = nil, birthday: Date? = nil, nfcTagIdentifier: String? = nil) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.birthday = birthday
        self.nfcTagIdentifier = nfcTagIdentifier
    }

}
