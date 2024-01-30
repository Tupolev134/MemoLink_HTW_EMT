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
    @State private var birthdayContacts: [String] = []
    @State private var showAddContactView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if !birthdayContacts.isEmpty {
                    Text("Happy Birthday: \(birthdayContacts.joined(separator: ", "))")
                        .font(.headline)
                        .padding()
                }
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
                fetchBirthdayContacts()
                setupNFCReadManager()
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
                destination: ContactView(contact: contactStorage.getContact(byNfcTagId: nfcDataHandler.lastScannedUUID ?? "") ?? Contact.defaultContact)
                    .onDisappear {
                        nfcDataHandler.lastScannedUUID = nil
                    },
                isActive: $navigateToContactView
            ) {
                EmptyView()
            }
            NavigationLink(
                destination: AddNfcTagToContactView(),
                isActive: $showAddContactView
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
    
    private func fetchBirthdayContacts() {
            CNContactsController.shared.fetchContactsHavingBirthdayToday { result in
                switch result {
                case .success(let contacts):
                    self.birthdayContacts = contacts.map { "\($0.givenName) \($0.familyName)" }
                case .failure(let error):
                    print("Error fetching birthday contacts: \(error)")
                }
            }
        }
    
    private func setupNFCReadManager() {
        nfcReadManager.onAlert = { title, message in
            alertTitle = title
            alertMessage = message
            showingAlert = true
        }

        nfcReadManager.onEmptyTagDetected = {
            showAddContactView = true
        }

        if nfcDataHandler.lastScannedUUID != nil {
            navigateToContactView = true
        } else {
            startScanning()
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
