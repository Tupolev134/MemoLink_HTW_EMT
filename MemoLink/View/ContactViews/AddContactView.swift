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
                DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
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
                
    }
    
}
