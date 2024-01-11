import Contacts
import SwiftUI

struct AddNfcTagToContactView: View {
    @State private var groupedContacts = [String: [CNContact]]()

    var body: some View {
//        Text("Select a contact")
//            .font(.title2)
//            .frame(alignment: .leading)
//            .padding(.top)
        List {
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
        .navigationTitle("Select a contact")
        .toolbarTitleDisplayMode(.inline)
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

struct AddNfcTagToContactView_Previews: PreviewProvider {
    static var previews: some View {
        // Erstellen Sie hier statische Dummy-Kontakte für die Vorschau
        var previewContacts = [String: [CNContact]]()
        let names = ["Alice", "Bob", "Charlie", "David", "Eve"]
        for name in names {
            let contact = CNContact()
            // Normalerweise ist CNContact eine immutable Klasse,
            // hier nur für die Vorschau simuliert
            let mutableContact = contact.mutableCopy() as! CNMutableContact
            mutableContact.givenName = name
            let key = String(name.prefix(1))
            previewContacts[key, default: []].append(mutableContact.copy() as! CNContact)
        }

        return AddNfcTagToContactView()
    }
}
