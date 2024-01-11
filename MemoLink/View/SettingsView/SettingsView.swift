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
                    ForEach(dummyContacts) { contact in
                        NavigationLink(destination: ContactDetailView()) {
                            Text(contact.contactIdentifier)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationBarTitle("Settings")
            .toolbarBackground(Color.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        
        
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
