import XCTest
@testable import CoffeeJournalCore

final class ImageValidatorTests: XCTestCase {

    func test_detectFormat_jpeg() {
        let jpegHeader = Data([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01])
        let format = ImageValidator.detectFormat(data: jpegHeader)
        XCTAssertEqual(format, .jpeg)
    }

    func test_detectFormat_png() {
        let pngHeader = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D])
        let format = ImageValidator.detectFormat(data: pngHeader)
        XCTAssertEqual(format, .png)
    }

    func test_detectFormat_webp() {
        let webpHeader = Data([
            0x52, 0x49, 0x46, 0x46, // "RIFF"
            0x00, 0x00, 0x00, 0x00, // file size placeholder
            0x57, 0x45, 0x42, 0x50  // "WEBP"
        ])
        let format = ImageValidator.detectFormat(data: webpHeader)
        XCTAssertEqual(format, .webp)
    }

    func test_detectFormat_heic() {
        let heicHeader = Data([
            0x00, 0x00, 0x00, 0x18, // size
            0x66, 0x74, 0x79, 0x70, // "ftyp"
            0x68, 0x65, 0x69, 0x63  // "heic"
        ])
        let format = ImageValidator.detectFormat(data: heicHeader)
        XCTAssertEqual(format, .heic)
    }

    func test_validate_validData_returnsFormat() throws {
        let jpegData = Data([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01])
        let format = try ImageValidator.validate(data: jpegData)
        XCTAssertEqual(format, .jpeg)
    }

    func test_validate_emptyData_throwsValidationError() {
        let emptyData = Data()
        XCTAssertThrowsError(try ImageValidator.validate(data: emptyData)) { error in
            guard case AppError.validationError(let message) = error else {
                XCTFail("Expected AppError.validationError, got \(error)")
                return
            }
            XCTAssertTrue(message.contains("画像データが空です"))
        }
    }

    func test_validate_invalidHeader_throwsValidationError() {
        let invalidData = Data(repeating: 0x00, count: 20)
        XCTAssertThrowsError(try ImageValidator.validate(data: invalidData)) { error in
            guard case AppError.validationError(let message) = error else {
                XCTFail("Expected AppError.validationError, got \(error)")
                return
            }
            XCTAssertTrue(message.contains("未対応または不正な画像フォーマット"))
        }
    }

    func test_validate_sizeExceeded_throwsValidationError() {
        // Create 5MB + 1 byte data with JPEG header
        var oversizedData = Data([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01])
        oversizedData.append(Data(repeating: 0xAA, count: 5 * 1024 * 1024))

        XCTAssertThrowsError(try ImageValidator.validate(data: oversizedData)) { error in
            guard case AppError.validationError(let message) = error else {
                XCTFail("Expected AppError.validationError, got \(error)")
                return
            }
            XCTAssertTrue(message.contains("画像ファイルサイズ"))
        }
    }
}
