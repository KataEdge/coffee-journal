import Foundation

public protocol StorageRepositoryProtocol: Sendable {
    /// Requests a presigned upload URL for S3
    func generatePresignedUploadURL(fileName: String, contentType: String) async throws -> URL
    
    /// Uploads raw image data directly to S3 using a presigned URL
    func uploadImageData(_ data: Data, presignedURL: URL, contentType: String) async throws -> String
}
