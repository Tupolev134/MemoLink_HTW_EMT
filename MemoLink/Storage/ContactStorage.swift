import Foundation

class ContactStorage {
    static let shared = ContactStorage()
    private let fileURL: URL

    init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documentsDirectory.appendingPathComponent("contacts.json")
    }

    func save(contacts: [Contact]) {
        do {
            let data = try JSONEncoder().encode(contacts)
            try data.write(to: fileURL)
        } catch {
            print("Error saving contacts: \(error)")
        }
    }

    func load() -> [Contact] {
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([Contact].self, from: data)
        } catch {
            print("Error loading contacts: \(error)")
            return []
        }
    }
}
