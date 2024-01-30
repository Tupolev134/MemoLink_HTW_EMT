import SwiftUI

struct StartView: View {
    @ObservedObject var contactStorage = ContactStorageController.shared
    // state for background read nfc tags
    @ObservedObject private var nfcDataHandler = NFCDataHandler.shared
    @StateObject private var nfcReadManager = NFCReadManager()
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var navigateToContactView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "arrow.down")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .foregroundColor(.accentColor)
                    .padding(.bottom,60)
    
                Spacer()
                
                Button(action: {startScanning()}, label: {
                    Text("Scan Contact")
                        .font(.system(size: 32))
                        .bold()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .foregroundColor(Color("BG"))
                        .background(Color.accentColor)
                        .cornerRadius(10)
                })
                .padding()
                
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    NavigationLink{
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if nfcDataHandler.lastScannedUUID != nil {
                        navigateToContactView = true
                    } else {
                        startScanning()
                    }
                }
            }
            .onChange(of: nfcDataHandler.lastScannedUUID) { _ in
                if nfcDataHandler.lastScannedUUID != nil {
                    navigateToContactView = true
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    primaryButton: .default(Text("Retry")) {
                        startScanning()
                    },
                    secondaryButton: .cancel()
                )
            }
            NavigationLink(
                destination: ContactView(contact: contactStorage.getContact(byNfcTagId: nfcDataHandler.lastScannedUUID ?? "") ?? Contact.defaultContact),
                isActive: $navigateToContactView
            ) {
                EmptyView()
            }
        }
    }
    
    private func startScanning() {
        nfcReadManager.onAlert = { title, message in
            self.alertTitle = title
            self.alertMessage = message
            self.showingAlert = true
        }
        nfcReadManager.beginScanning()
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
