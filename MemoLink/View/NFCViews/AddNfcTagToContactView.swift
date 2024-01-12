import Contacts
import SwiftUI

struct AddNfcTagToContactView: View {
    @State private var groupedContacts = [String: [CNContact]]()
    
    var body: some View {
        List {
            ForEach(groupedContacts.keys.sorted(), id: \.self) { key in
                Section(header: Text(key)) {
                    ForEach(groupedContacts[key] ?? [], id: \.identifier) { contact in
                        NavigationLink {
                            ScanNFCTagView(contactIdentifier: contact.identifier)
                        } label: {
                            Text(contact.givenName + " " + contact.familyName)
                        }
                    }
                }
            }
        }
        .onAppear(perform: {
            CNContactsController.shared.loadContacts { contacts in
                self.groupedContacts = contacts
            }
        })
        .listStyle(.insetGrouped)
        .navigationTitle("Select a contact")
        .toolbarTitleDisplayMode(.inline)
    }
}
