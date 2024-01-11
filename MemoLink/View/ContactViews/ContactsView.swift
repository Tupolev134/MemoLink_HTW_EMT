import Contacts
import SwiftUI

struct ContactsView: View {
    @State private var contacts: [CNContact] = []
    
    var body: some View {
        List(contacts, id: \.identifier) { contact in
            Text(contact.givenName + " " + contact.familyName)
        }
        .onAppear(perform: loadContacts)
    }

    private func loadContacts() {
        let store = CNContactStore()

        DispatchQueue.global(qos: .userInitiated).async {
            store.requestAccess(for: .contacts) { granted, error in
                if let error = error {
                    print("Fehler beim Zugriff auf Kontakte: \(error)")
                    return
                }

                if granted {
                    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey]
                    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])

                    var fetchedContacts = [CNContact]()
                    try? store.enumerateContacts(with: request) { contact, stop in
                        fetchedContacts.append(contact)
                    }

                    DispatchQueue.main.async {
                        self.contacts = fetchedContacts
                    }
                }
            }
        }
    }

}
