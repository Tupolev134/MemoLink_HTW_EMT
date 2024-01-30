import SwiftUI
import Contacts

struct AddContactView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var contactStorage = ContactStorageController.shared
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = ""
    @State private var birthday: Date = Date()
    @State private var showingSaveAlert = false
    @State private var saveAlertMessage: String = ""
    var onEmptyTagDetected: (() -> Void)?
    
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("First name", text: $firstName)
                TextField("Last name", text: $lastName)
            }
            
            Section(header: Text("Phone")) {
                TextField("Phone", text: $phoneNumber)
            }
            
            Section(header: Text("Birthday")) {
                DatePicker("", selection: $birthday, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
        
            }
            
            //            Section {
            //                Button("Save Contact") {
            //                    saveNewContact()
            //                }
            //            }
        }
        .navigationBarTitle("New Contact", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }, trailing: Button("Save") {
            saveNewContact()
        })
        .alert(isPresented: $showingSaveAlert) {
            Alert(
                title: Text("Save Contact"),
                message: Text(saveAlertMessage),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func saveNewContact() {
        CNContactsController.shared.addNewContact(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, birthday: birthday) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.saveAlertMessage = "Contact successfully saved."
                    self.showingSaveAlert = true
                case .failure(let error):
                    self.saveAlertMessage = "Failed to save contact: \(error.localizedDescription)"
                    self.showingSaveAlert = true
                }
            }
        }
        
        //TODO: open ScanNewNFCTagView
    }
    
}
