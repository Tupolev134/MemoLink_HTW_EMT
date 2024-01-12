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
    
    func save(newContact: Contact) {
        contacts.append(newContact)
        do {
            let data = try JSONEncoder().encode(contacts)
            try data.write(to: fileURL)
        } catch {
            print("Error saving contacts: \(error)")
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
    
    func delete(contact: Contact) {
        contacts.removeAll { $0.id == contact.id }
//        save()
    }
}
