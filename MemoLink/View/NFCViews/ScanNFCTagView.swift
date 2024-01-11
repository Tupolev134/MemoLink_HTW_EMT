import SwiftUI

struct ScanNFCTagView: View {
    @Environment(\.presentationMode) var presentationMode
    var contactIdentifier: String
    let dummyNfcTagID = "dummy-nfc-tag-id" // Dummy-Wert für die NFC-Tag-ID
    @State private var showAlert = false

    var body: some View {
        Button("NFC gescannt") {
            saveContact()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Erfolg"),
                message: Text("Kontakt erfolgreich gespeichert"),
                dismissButton: .default(Text("OK")) {
                    // Schließt die aktuelle Ansicht beim Tippen auf "OK"
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }

    func saveContact() {
        let newContact = Contact(contactIdentifier: contactIdentifier, nfcTagID: dummyNfcTagID)
        ContactStorage.shared.save(contacts: [newContact])
        // Zeigt den Alert an, nachdem der Kontakt gespeichert wurde
        showAlert = true
    }
}
