import Foundation

public struct PasswordValidationResult: Equatable, Sendable {
    public let isValid: Bool
    public let errorMessage: String?

    public init(isValid: Bool, errorMessage: String? = nil) {
        self.isValid = isValid
        self.errorMessage = errorMessage
    }
}

public struct PasswordValidator: Sendable {
    public static func validate(password: String) -> PasswordValidationResult {
        if password.count < 8 {
            return PasswordValidationResult(
                isValid: false,
                errorMessage: "パスワードは8文字以上で入力してください。"
            )
        }

        let hasLetter = password.rangeOfCharacter(from: .letters) != nil
        let hasDigit = password.rangeOfCharacter(from: .decimalDigits) != nil

        if !hasLetter || !hasDigit {
            return PasswordValidationResult(
                isValid: false,
                errorMessage: "パスワードには英字と数字の両方を含める必要があります。"
            )
        }

        return PasswordValidationResult(isValid: true)
    }

    public static func validateOrThrow(password: String) throws {
        let result = validate(password: password)
        if !result.isValid, let message = result.errorMessage {
            throw AppError.validationError(message)
        }
    }
}
