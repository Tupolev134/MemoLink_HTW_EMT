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
                title: Text("Success"),
                message: Text("Contact successfully saved"),
                dismissButton: .default(Text("Okay")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }

    func saveContact() {
        let newContact = Contact(contactIdentifier: contactIdentifier, nfcTagID: dummyNfcTagID)
        ContactStorageController.shared.save(contacts: [newContact])
        showAlert = true
    }
}
