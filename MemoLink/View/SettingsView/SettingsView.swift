import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack{
            Spacer()
            NavigationLink(destination: ContactsView()) {
                LargeButton(text: "Contacts", action: {
                    // passt
                })
            }
            Spacer()
            LargeButton(text: "New NFC Tag") {
                //read nfc tag
            }
            Spacer()
            LargeButton(text: "Delete NFC Tag") {
                //delete nfc tag
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BG").edgesIgnoringSafeArea(.all))
        .navigationBarTitle("Settings", displayMode: .large)
        .foregroundStyle(Color("MemoLinkBlue"))
    }
    
    
}

#Preview {
    SettingsView()
}
