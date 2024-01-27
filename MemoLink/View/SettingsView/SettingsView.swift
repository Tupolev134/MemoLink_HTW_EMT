import SwiftUI

struct SettingsView: View {
    @ObservedObject var contactStorage = ContactStorageController.shared
    @State private var contactNames = [String: String]()
    
    var body: some View {
        
        List {
            Section(header: Text("NFC TAGS")) {
                NavigationLink(destination: AddNfcTagToContactView()) {
                    Text("Add NFC tag to existing contact")
                }
                NavigationLink(destination: RemoveNfcTagView()) {
                    Text("Clear NFC tag")
                }
                NavigationLink(destination: AddContactView(contactStorage: contactStorage)) {
                    Text("Add new contact")
                }
            }
            
            
            Section(header: Text("nfc CONTACTS")) {
                ForEach($contactStorage.contacts) { $contact in
//                    NavigationLink(destination: ContactDetailView()) {
                    NavigationLink(destination: EditContactView(contact: $contact)) {
                        Text(contactNames[contact.contactIdentifier] ?? "Unbekannt")
                    }
                    .onAppear {
                        loadContactName(contactIdentifier: contact.contactIdentifier)
                    }
                }
            }
        }
        .onAppear(perform: contactStorage.load)
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarTitle("Settings")
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        
        
    }
    
    private func loadContactName(contactIdentifier: String) {
        CNContactsController.shared.fetchContactName(identifier: contactIdentifier) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let name):
                    self.contactNames[contactIdentifier] = name
                case .failure(let error):
                    print("Fehler beim Abrufen des Kontaktnamens: \(error)")
                    self.contactNames[contactIdentifier] = "Fehler beim Laden"
                }
            }
        }
    }
}


// Dummy Ansicht für das Entfernen eines NFC-Tags
struct RemoveNfcTagView: View {
    var body: some View {
        Text("Hier wird ein NFC-Tag entfernt.")
    }
}


#Preview {
    SettingsView()
}
