import Foundation
import Security

struct KeychainService {
    private let service: String
    
    init(service: String = Bundle.main.bundleIdentifier ?? "com.myplanner.app") {
        self.service = service
    }
    private func set(_ value: Data, forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: value,
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    @discardableResult
    func set<T: CustomStringConvertible>(_ value: T, forKey key: String) -> Bool {
        guard let data = value.description.data(using: .utf8) else {
            return false
        }
        return set(data, forKey: key)
    }

    // MARK: - Private Get Method

    private func getObject(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else { return nil }
        guard let found = item as? [String: Any] else { return nil }
        guard let data = found[kSecValueData as String] as? Data else { return nil }

        return data
    }

    // MARK: - Public Get Methods

    func getString(forKey key: String) -> String? {
        guard let data = getObject(forKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func get(forKey key: String) -> Any? {
        guard let data = getObject(forKey: key) else { return nil }
        guard let str = String(data: data, encoding: .utf8) else { return nil }

        // Type conversion
        let lowercased = str.lowercased()
        if lowercased == "true" { return true }
        if lowercased == "false" { return false }
        if let intValue = Int(str) { return intValue }
        if let doubleValue = Double(str) { return doubleValue }

        return str
    }

    // MARK: - Delete Method

    @discardableResult
    func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

}

// MARK: - API Key Convenience Methods

extension KeychainService {

    private static let apiKeyIdentifier = "claude_api_key"

    @discardableResult
    func saveAPIKey(_ apiKey: String) -> Bool {
        set(apiKey, forKey: Self.apiKeyIdentifier)
    }

    func retrieveAPIKey() -> String? {
        getString(forKey: Self.apiKeyIdentifier)
    }

    @discardableResult
    func deleteAPIKey() -> Bool {
        delete(forKey: Self.apiKeyIdentifier)
    }

    var hasAPIKey: Bool {
        retrieveAPIKey() != nil
    }
}
