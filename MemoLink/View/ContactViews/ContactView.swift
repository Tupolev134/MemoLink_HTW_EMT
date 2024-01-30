import Contacts
import SwiftUI

struct ContactView: View {
    var contact: Contact
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = ""
    @State private var birthday: String = ""
    @ObservedObject var contactStorage = ContactStorageController.shared
    
    @State private var callCount = 0
    @State private var cooldownEnds: Date? = nil
    let callLimit = 3
    let cooldownDuration = 3600 // 1 hour in seconds
    
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
                showChat()
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
    

    private func makePhoneCall(phoneNumber: String) {
        if callCount < callLimit {
            if let url = URL(string: "tel://\(phoneNumber)"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                callCount += 1
                if callCount == callLimit {
                    cooldownEnds = Date().addingTimeInterval(Double(cooldownDuration))
                }
            }
        } else if let cooldownEnds = cooldownEnds, Date() > cooldownEnds {
            callCount = 0
            self.cooldownEnds = nil // Resetting cooldownEnds to nil
            makePhoneCall(phoneNumber: phoneNumber)
        } else {
            // Handle the cooldown (e.g., show an alert or disable the call button)
        }
    }
    
    func showChat() {
        let cleanNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
        let modifiedNumber = cleanNumber.hasPrefix("00") ? "+" + cleanNumber.dropFirst(2) : cleanNumber
        let whatsappURL = URL(string: "https://wa.me/\(modifiedNumber)")

        if let url = whatsappURL, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("WhatsApp is not installed or unknown number")
        }
    }
}


