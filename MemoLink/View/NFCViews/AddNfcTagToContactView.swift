import Contacts
import SwiftUI

struct AddNfcTagToContactView: View {
    @State private var groupedContacts = [String: [CNContact]]()

    var body: some View {
        List {
            Text("Select a contact")
                .font(.headline)
                .listRowBackground(Color.clear)

            ForEach(groupedContacts.keys.sorted(), id: \.self) { key in
                Section(header: Text(key)) {
                    ForEach(groupedContacts[key] ?? [], id: \.identifier) { contact in
                        Text(contact.givenName + " " + contact.familyName)
                    }
                }
            }
        }
        .onAppear(perform: loadContacts)
        .listStyle(.insetGrouped)
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
                    request.sortOrder = .userDefault

                    var newContacts = [String: [CNContact]]()

                    try? store.enumerateContacts(with: request) { contact, stop in
                        let key = String(contact.givenName.prefix(1))
                        newContacts[key, default: []].append(contact)
                    }

                    DispatchQueue.main.async {
                        self.groupedContacts = newContacts
                    }
                }
            }
        }
    }
}
