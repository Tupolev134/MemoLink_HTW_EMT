import SwiftUI
import CoreNFC

struct ScanNFCTagView: View {
    @Environment(\.presentationMode) var presentationMode
    var contactIdentifier: String
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @StateObject private var nfcManager = NFCWriteManager()
    
    var body: some View {
        Button("Start NFC Session") {
            startNfcSession()
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
    
    func startNfcSession() {
        let uuidString = UUID().uuidString
        print("Generated UUID: \(uuidString)")

        if let payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: uuidString, locale: Locale(identifier: "en")) {
            print("NFC Payload created successfully.")
            nfcManager.message = NFCNDEFMessage(records: [payload])

            nfcManager.beginWrite{ (success: Bool, error: Error?) in
                DispatchQueue.main.async {
                    if success {
                        // Save contact if NFC write was successful
                        self.saveContact(with: uuidString)
                        self.alertMessage = "NFC Write Successful and Contact Saved"
                    } else {
                        // Handle the error scenario, maybe update the UI to show an error message
                        self.alertMessage = "NFC Write Failed: \(error?.localizedDescription ?? "Unknown error")"
                    }
                    self.showAlert = true
                }
            }
        } else {
            print("Failed to create NFC payload.")
            self.alertTitle = "Error"
            self.alertMessage = "Failed to create NFC payload."
            self.showAlert = true
        }
    }

    func saveContact(with uuidString: String) {
        let newContact = Contact(contactIdentifier: contactIdentifier, nfcTagID: uuidString)
        ContactStorageController.shared.save(newContact: newContact)
    }

}

