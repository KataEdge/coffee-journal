import Foundation
import Supabase

public final class MemoryAuthStorage: AuthLocalStorage, @unchecked Sendable {
    private var storage: [String: Data] = [:]

    public init() {}

    public func store(key: String, value: Data) throws {
        storage[key] = value
    }

    public func retrieve(key: String) throws -> Data? {
        return storage[key]
    }

    public func remove(key: String) throws {
        storage.removeValue(forKey: key)
    }
}
