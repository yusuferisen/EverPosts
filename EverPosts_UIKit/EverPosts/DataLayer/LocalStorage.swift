//
//  LocalStorage.swift
//  EverPosts
//

import Foundation

protocol LocalStorageProtocol {
    func save<T: Codable>(_ object: T, key: String)
    func append<T: Codable>(_ object: T, key: String)
    func append<T: Codable>(contentsOf objects: [T], key: String)
    func retrieve<T: Codable>(key: String) -> T?
    func clear(key: String)
}

class UserDefaultsStorage: LocalStorageProtocol {
    func save<T: Codable>(_ object: T, key: String) {
        if let data = try? JSONEncoder().encode(object) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func append<T: Codable>(_ object: T, key: String) {
        var existing: [T] = retrieve(key: key) ?? []
        existing.append(object)
        save(existing, key: key)
    }
    
    func append<T: Codable>(contentsOf objects: [T], key: String) {
        var existing: [T] = retrieve(key: key) ?? []
        existing.append(contentsOf: objects)
        save(existing, key: key)
    }
    
    func retrieve<T: Codable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    func clear(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
