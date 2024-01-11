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

//class ContactManager {
//    let store = CNContactStore()
//
//    func fetchContactDetails(identifier: String, completion: @escaping (Result<CNContact, Error>) -> Void) {
//        let keysToFetch: [CNKeyDescriptor] = [
//            CNContactGivenNameKey as CNKeyDescriptor,
//            CNContactFamilyNameKey as CNKeyDescriptor,
//            CNContactPhoneNumbersKey as CNKeyDescriptor,
//            CNContactBirthdayKey as CNKeyDescriptor
//        ]
//
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                let contact = try self.store.unifiedContact(withIdentifier: identifier, keysToFetch: keysToFetch)
//                DispatchQueue.main.async {
//                    completion(.success(contact))
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//            }
//        }
//    }
//}
