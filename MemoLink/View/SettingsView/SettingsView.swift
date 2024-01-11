import SwiftUI

struct SettingsView: View {
    
    let dummyContacts = [
        Contact(contactIdentifier: "Eleanor", nfcTagID: "nfc1"),
        Contact(contactIdentifier: "Frederick", nfcTagID: "nfc2"),
        Contact(contactIdentifier: "Beatrice", nfcTagID: "nfc3"),
        Contact(contactIdentifier: "Archibald", nfcTagID: "nfc4"),
        Contact(contactIdentifier: "Harriet", nfcTagID: "nfc5"),
        Contact(contactIdentifier: "Theodore", nfcTagID: "nfc6")
    ]
    
    @State private var savedContacts = [Contact]()
    @State private var contactNames = [String: String]()
    
    var body: some View {
        
        List {
            Section(header: Text("NFC TAGS")) {
                NavigationLink(destination: AddNfcTagToContactView()) {
                    Text("Add NFC tag to contact")
                }
                NavigationLink(destination: RemoveNfcTagView()) {
                    Text("Clear NFC tag")
                }
            }
            
            
            Section(header: Text("nfc CONTACTS")) {
                ForEach(savedContacts) { contact in
                    NavigationLink(destination: ContactDetailView()) {
                        Text(contactNames[contact.contactIdentifier] ?? "Unbekannt")
                    }
                    .onAppear {
                        loadContactName(contactIdentifier: contact.contactIdentifier)
                    }
                }
            }
        }
        .onAppear(perform: loadSavedContacts)
        .listStyle(.insetGrouped)
        .navigationBarTitle("Settings")
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        
        
    }
    private func loadSavedContacts(){
        savedContacts = ContactStorageController().load()
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
