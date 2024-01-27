import Contacts
import SwiftUI

struct ContactView: View {
    var contact: Contact
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = ""
    @State private var birthday: String = ""
    @ObservedObject var contactStorage = ContactStorageController.shared
    
    var body: some View {
        VStack(alignment: .leading){
            Text("*\(birthday)")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .padding(.horizontal)
            Spacer()
            LargeButton(text: "Call \(firstName)") {
                makePhoneCall(phoneNumber: phoneNumber)
            }
            Spacer()
            LargeButton(text: "Text \(firstName)") {
                textContact()
            }
            Spacer()
//            LargeButton(text: "Show chat") {
//                showChat()
//            }
//            Spacer()
        }
        .onAppear{loadContactDetails()}
        .navigationTitle(firstName + " " + lastName)
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func loadContactDetails() {
        CNContactsController.shared.fetchContactDetails(identifier: contact.contactIdentifier) { result in
            switch result {
            case .success(let cnContact):
                self.firstName = cnContact.givenName
                self.lastName = cnContact.familyName
                self.phoneNumber = cnContact.phoneNumbers.first?.value.stringValue ?? ""
                if let birthdayDate = cnContact.birthday?.date {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .long
                    self.birthday = dateFormatter.string(from: birthdayDate)
                }
            case .failure(let error):
                print("Error fetching contact details: \(error)")
            }
        }
    }
    
    func makePhoneCall(phoneNumber: String) {
        guard let url = URL(string: "tel://\(phoneNumber)"),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    func textContact(){
        print("text")
    }
    
    func showChat(){
        let whatsappURL = URL(string: "https://wa.me/\(phoneNumber)")
        
        if let url = whatsappURL, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("WhatsApp is not installed or unknown number")
        }
    }
}


