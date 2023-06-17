//
//  KeyChain.swift
//  FinalProject
//
//  Created by sergey on 17.06.2023.
//

import Foundation

class KeyChainService {
    /// Errors that can be thrown when the Keychain is queried.
    enum KeychainError: LocalizedError {
        /// The requested item was not found in the Keychain.
        case itemNotFound
        /// Attempted to save an item that already exists.
        /// Update the item instead.
        case duplicateItem
        /// The operation resulted in an unexpected status.
        case unexpectedStatus(OSStatus)
    }

    /// A service that can be used to group the tokens
    /// as the kSecAttrAccount should be unique.
    static let service = "com.vk.auth"
    
    func insertToken(_ token: Data, identifier: String, service: String = service) throws {
        let attributes = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: identifier,
            kSecValueData: token
        ] as CFDictionary

        let status = SecItemAdd(attributes, nil)
        guard status == errSecSuccess else {
            if status == errSecDuplicateItem {
                throw KeychainError.duplicateItem
            }
            throw KeychainError.unexpectedStatus(status)
        }
    }
    func getToken(identifier: String, service: String = service) throws -> String {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: identifier,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: true
        ] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                // Technically could make the return optional and return nil here
                // depending on how you like this to be taken care of
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unexpectedStatus(status)
        }
        // Lots of bang operators here, due to the nature of Keychain functionality.
        // You could work with more guards/if let or others.
        return String(data: result as! Data, encoding: .utf8)!
    }
}
