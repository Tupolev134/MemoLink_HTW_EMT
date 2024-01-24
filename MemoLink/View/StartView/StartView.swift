import SwiftUI

struct StartView: View {
    @ObservedObject var contactStorage = ContactStorageController.shared
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @StateObject private var nfcManager = NFCReadManager()
    @State private var navigateToContactView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "shareplay")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(.accentColor)
                Text("Hold your phone near a image of a person")
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .frame(alignment: .center)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .padding()
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    NavigationLink{
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                    
                }
            }.onAppear {
                nfcManager.onAlert = { title, message in
                    self.alertTitle = title
                    self.alertMessage = message
                    self.showingAlert = true
                }
                nfcManager.beginScanning()
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            NavigationLink(destination: ContactView(contact: contactStorage.getContact(byNfcTagId: nfcManager.lastScannedContactID ?? "") ?? Contact.defaultContact), isActive: $navigateToContactView) {
                            EmptyView()
                        }
                    }
                    .onChange(of: nfcManager.lastScannedContactID) { _ in
                        print(nfcManager.lastScannedContactID)
                        if nfcManager.lastScannedContactID != nil {
                            navigateToContactView = true
                        }
                    }
                }
            
        }



struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
