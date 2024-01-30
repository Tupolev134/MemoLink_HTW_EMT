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
    
    func fetchContactDetails(identifier: String, completion: @escaping (Result<CNContact, Error>) -> Void) {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactBirthdayKey as CNKeyDescriptor,
            CNContactImageDataKey as CNKeyDescriptor
        ]
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let contact = try self.store.unifiedContact(withIdentifier: identifier, keysToFetch: keysToFetch)
                DispatchQueue.main.async {
                    completion(.success(contact))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func saveContactChanges(contact: CNMutableContact, completion: @escaping (Result<Void, Error>) -> Void) {
        let saveRequest = CNSaveRequest()
        saveRequest.update(contact)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.store.execute(saveRequest)
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func addNewContact(firstName: String, lastName: String, phoneNumber: String, birthday: Date?, completion: @escaping (Result<Void, Error>) -> Void) {
        let newContact = CNMutableContact()
        newContact.givenName = firstName
        newContact.familyName = lastName
        
        
        if !phoneNumber.isEmpty {
            let phoneValue = CNPhoneNumber(stringValue: phoneNumber)
            let phoneLabel = CNLabeledValue(label: CNLabelPhoneNumberMobile, value: phoneValue)
            newContact.phoneNumbers.append(phoneLabel)
        }
        
        if let birthdayDate = birthday {
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.day, .month, .year], from: birthdayDate)
            newContact.birthday = dateComponents
        }
        
        // CNSaveRequest vorbereiten und den neuen Kontakt hinzufügen
        let saveRequest = CNSaveRequest()
        saveRequest.add(newContact, toContainerWithIdentifier: nil)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.store.execute(saveRequest)
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchContactsHavingBirthdayToday(completion: @escaping (Result<[CNContact], Error>) -> Void) {
        let todayComponents = Calendar.current.dateComponents([.day, .month], from: Date())
        
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactBirthdayKey as CNKeyDescriptor
        ]
        
        DispatchQueue.global(qos: .userInitiated).async {
            var birthdayContacts: [CNContact] = []
            
            let request = CNContactFetchRequest(keysToFetch: keysToFetch)
            try? self.store.enumerateContacts(with: request) { contact, _ in
                if let birthday = contact.birthday,
                   birthday.day == todayComponents.day,
                   birthday.month == todayComponents.month {
                    birthdayContacts.append(contact)
                }
            }
            
            DispatchQueue.main.async {
                completion(.success(birthdayContacts))
            }
        }
    }

}
