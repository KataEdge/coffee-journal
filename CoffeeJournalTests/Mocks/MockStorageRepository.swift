import Foundation
@testable import CoffeeJournalCore


public final class MockStorageRepository: StorageRepositoryProtocol, @unchecked Sendable {
    public var mockPresignedURL = URL(string: "https://example-s3.amazonaws.com/upload-target")!
    public var mockPublicURL = "https://example-s3.amazonaws.com/tasting-notes/mock.jpg"
    public var shouldReturnError: Error?

    public init() {}

    public func generatePresignedUploadURL(fileName: String, contentType: String) async throws -> URL {
        if let error = shouldReturnError { throw error }
        return mockPresignedURL
    }

    public func uploadImageData(_ data: Data, presignedURL: URL, contentType: String) async throws -> String {
        if let error = shouldReturnError { throw error }
        return mockPublicURL
    }
}
