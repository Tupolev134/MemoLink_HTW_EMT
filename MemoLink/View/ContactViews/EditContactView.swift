import SwiftUI
import Contacts

struct EditContactView: View {
    @Binding var contact: Contact
    @Environment(\.presentationMode) var presentationMode
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = ""
    @ObservedObject var contactStorage = ContactStorageController.shared
    @State private var showingUpdateAlert = false
    @State private var updateAlertMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("First name", text: $firstName)
                TextField("Last name", text: $lastName)
            }
            
            Section(header: Text("Phone")) {
                TextField("Phone", text: $phoneNumber)
            }
            
            Section {
                Button("Unpair NFC tag") {
                    // Your unpair logic here
                }
            }
        }
        .navigationBarTitle("Edit Contact", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }, trailing: Button("Save") {
            saveContactChanges()
        })
        .alert(isPresented: $showingUpdateAlert) {
            Alert(
                title: Text("Update"),
                message: Text(updateAlertMessage),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            loadContactDetails()
        }
    }
    
    private func loadContactDetails() {
        CNContactsController.shared.fetchContactDetails(identifier: contact.contactIdentifier) { result in
            switch result {
            case .success(let cnContact):
                self.firstName = cnContact.givenName
                self.lastName = cnContact.familyName
                self.phoneNumber = cnContact.phoneNumbers.first?.value.stringValue ?? ""
            case .failure(let error):
                print("Error fetching contact details: \(error)")
            }
        }
    }
    
    private func saveContactChanges() {
        CNContactsController.shared.fetchContactDetails(identifier: contact.contactIdentifier) { result in
            switch result {
            case .success(let contact):
                guard let mutableContact = contact.mutableCopy() as? CNMutableContact else { return }
                
                mutableContact.givenName = firstName
                mutableContact.familyName = lastName
                let phoneValue = CNPhoneNumber(stringValue: phoneNumber)
                let labeledValue = CNLabeledValue(label: CNLabelPhoneNumberMobile, value: phoneValue)
                mutableContact.phoneNumbers = [labeledValue]
                
                CNContactsController.shared.saveContactChanges(contact: mutableContact) { saveResult in
                    DispatchQueue.main.async {
                        switch saveResult {
                        case .success:
                            self.updateAlertMessage = "Contact was successfully updated."
                            self.showingUpdateAlert = true
                            // The alert dismissal action will handle popping the view
                        case .failure(let error):
                            self.updateAlertMessage = "Failed to update contact: \(error.localizedDescription)"
                            self.showingUpdateAlert = true
                        }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Failed to fetch contact for editing: \(error)")
                    // Handle the error
                }
            }
        }
    }
    
}
