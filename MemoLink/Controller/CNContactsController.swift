import Foundation

import Contacts

class CNContactsController {
    static let shared = CNContactsController()
    private let store = CNContactStore()

    func loadContacts(completion: @escaping ([String: [CNContact]]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.store.requestAccess(for: .contacts) { granted, error in
                guard granted, error == nil else {
                    print("Error getting contacts: \(String(describing: error))")
                    DispatchQueue.main.async {
                        completion([:])
                    }
                    return
                }

                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey] as [CNKeyDescriptor]
                let request = CNContactFetchRequest(keysToFetch: keys)
                request.sortOrder = .userDefault

                var newContacts = [String: [CNContact]]()
                try? self.store.enumerateContacts(with: request) { contact, stop in
                    let key = String(contact.givenName.prefix(1))
                    newContacts[key, default: []].append(contact)
                }

                DispatchQueue.main.async {
                    completion(newContacts)
                }
            }
        }
    }
    
    func fetchContactName(identifier: String, completion: @escaping (Result<String, Error>) -> Void) {
            let keysToFetch: [CNKeyDescriptor] = [
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor
            ]

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let contact = try self.store.unifiedContact(withIdentifier: identifier, keysToFetch: keysToFetch)
                    let name = contact.givenName + " " + contact.familyName
                    DispatchQueue.main.async {
                        completion(.success(name))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
}
