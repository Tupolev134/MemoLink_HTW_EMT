import SwiftUI
import CoreNFC

struct ScanNFCTagView: View {
    @Environment(\.presentationMode) var presentationMode
    var contactIdentifier: String
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var shouldAutoDismiss = false
    @StateObject private var nfcManager = NFCWriteManager()
    
    var body: some View {
        VStack {
            Text("Scanning NFC Tag...")
                .font(.title)
                .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: nil)
        }
        .onAppear {
            self.startNfcSession()
        }
        .onChange(of: shouldAutoDismiss) { autoDismiss in
            if autoDismiss {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // 2 seconds delay
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    func startNfcSession() {
        let uuidString = UUID().uuidString
        let customURL = "memolink://\(uuidString)"
        
        if let payload = NFCNDEFPayload.wellKnownTypeURIPayload(string: customURL) {
            nfcManager.message = NFCNDEFMessage(records: [payload])
            
            nfcManager.beginWrite { (success: Bool, error: Error?) in
                DispatchQueue.main.async {
                    if success {
                        self.saveContact(with: uuidString)
                        self.alertTitle = "Success"
                        self.alertMessage = "NFC Write Successful and Contact Saved"
                        self.shouldAutoDismiss = true
                    } else {
                        self.alertTitle = "Error"
                        self.alertMessage = error?.localizedDescription ?? "Unknown error"
                        self.showRetryAlert()
                    }
                    self.showAlert = true
                }
            }
        }
    }

    private func showRetryAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // 5 seconds delay for retry option
            self.alertTitle = "Retry?"
            self.alertMessage = "Tap to retry NFC scanning."
            self.showAlert = true
        }
    }
    

    func saveContact(with uuidString: String) {
        let newContact = Contact(contactIdentifier: contactIdentifier, nfcTagID: uuidString)
        ContactStorageController.shared.save(newContact: newContact)
    }

}

