import XCTest
@testable import CoffeeJournalCore

final class PasswordValidatorTests: XCTestCase {

    func test_validate_validPassword_returnsSuccess() {
        let result = PasswordValidator.validate(password: "Coffee1234")
        XCTAssertTrue(result.isValid)
        XCTAssertNil(result.errorMessage)
    }

    func test_validate_tooShort_returnsInvalid() {
        let result = PasswordValidator.validate(password: "Pass1")
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "パスワードは8文字以上で入力してください。")
    }

    func test_validate_onlyLetters_returnsInvalid() {
        let result = PasswordValidator.validate(password: "PasswordOnly")
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "パスワードには英字と数字の両方を含める必要があります。")
    }

    func test_validate_onlyDigits_returnsInvalid() {
        let result = PasswordValidator.validate(password: "123456789")
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "パスワードには英字と数字の両方を含める必要があります。")
    }

    func test_validateOrThrow_validPassword_doesNotThrow() throws {
        XCTAssertNoThrow(try PasswordValidator.validateOrThrow(password: "SecurePass2026"))
    }

    func test_validateOrThrow_invalidPassword_throwsValidationError() {
        XCTAssertThrowsError(try PasswordValidator.validateOrThrow(password: "short")) { error in
            guard case AppError.validationError(let message) = error else {
                XCTFail("Expected AppError.validationError, got \(error)")
                return
            }
            XCTAssertEqual(message, "パスワードは8文字以上で入力してください。")
        }
    }
}
