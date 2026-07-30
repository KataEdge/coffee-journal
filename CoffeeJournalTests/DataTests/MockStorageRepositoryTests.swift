import XCTest
@testable import CoffeeJournalCore

final class MockStorageRepositoryTests: XCTestCase {

    func test_mockStorageRepository_success() async throws {
        let repo = MockStorageRepository()

        let presignedURL = try await repo.generatePresignedUploadURL(fileName: "test.jpg", contentType: "image/jpeg")
        XCTAssertEqual(presignedURL, repo.mockPresignedURL)

        let publicURL = try await repo.uploadImageData(Data(), presignedURL: presignedURL, contentType: "image/jpeg")
        XCTAssertEqual(publicURL, repo.mockPublicURL)
    }

    func test_mockStorageRepository_error() async {
        let repo = MockStorageRepository()
        repo.shouldReturnError = AppError.networkError("Upload failed")

        do {
            _ = try await repo.generatePresignedUploadURL(fileName: "test.jpg", contentType: "image/jpeg")
            XCTFail("Should throw network error")
        } catch {
            XCTAssertTrue(error is AppError)
        }

        do {
            _ = try await repo.uploadImageData(Data(), presignedURL: repo.mockPresignedURL, contentType: "image/jpeg")
            XCTFail("Should throw network error")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }
}
