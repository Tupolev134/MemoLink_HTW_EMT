import Foundation

class ContactStorageController: ObservableObject {
    static let shared = ContactStorageController()
    private let fileURL: URL
    @Published var contacts: [Contact] = []
    
    init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documentsDirectory.appendingPathComponent("contacts.json")
        load()
    }
    
    func handleCall(for contactID: UUID, callLimit: Int, cooldownDuration: Int) {
        guard let index = contacts.firstIndex(where: { $0.id == contactID }) else { return }

        var contact = contacts[index]
        if contact.callCount < callLimit {
            contact.callCount += 1
            if contact.callCount == callLimit {
                contact.cooldownEnds = Date().addingTimeInterval(Double(cooldownDuration))
            }
        } else if let cooldownEnds = contact.cooldownEnds, Date() > cooldownEnds {
            contact.callCount = 0
            contact.cooldownEnds = nil
        } else {
            return
        }
        contacts[index] = contact
        save()
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(contacts)
            try data.write(to: fileURL)
        } catch {
            print("Error saving contacts: \(error)")
        }
    }
    
    func save(newContact: Contact) {
        contacts.append(newContact)
        do {
            let data = try JSONEncoder().encode(contacts)
            try data.write(to: fileURL)
        } catch {
            print("Error saving contacts: \(error)")
        }
    }
    
    func updateContact(updatedContact: Contact) {
        if let index = contacts.firstIndex(where: { $0.id == updatedContact.id }) {
            contacts[index] = updatedContact
            save()
        }
    }
    
    func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("contacts.json file does not exist yet.")
            contacts = []
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            contacts = try JSONDecoder().decode([Contact].self, from: data)
        } catch {
            print("Error loading contacts: \(error)")
            contacts = []
        }
    }
    
    func getContact(byNfcTagId nfcTagId: String) -> Contact? {
        return contacts.first { $0.nfcTagID == nfcTagId }
    }
    
    func delete(contact: Contact) {
        contacts.removeAll { $0.id == contact.id }
        save()
    }
}
