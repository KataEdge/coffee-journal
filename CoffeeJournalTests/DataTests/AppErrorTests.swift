import XCTest
@testable import CoffeeJournalCore

final class AppErrorTests: XCTestCase {

    func test_appError_descriptions() {
        let errors: [(AppError, String)] = [
            (.networkError("Timeout"), "ネットワークエラー: Timeout"),
            (.databaseError("RLS Violation"), "データベースエラー: RLS Violation"),
            (.authenticationRequired, "ログインが必要です。"),
            (.authenticationError("Invalid Credentials"), "認証エラー: Invalid Credentials"),
            (.uploadFailed("S3 Error"), "画像アップロードに失敗しました: S3 Error"),
            (.invalidData, "無効なデータです。"),
            (.unknown("Crash"), "不明なエラーが発生しました: Crash")
        ]

        for (err, expectedDesc) in errors {
            XCTAssertEqual(err.errorDescription, expectedDesc)
        }
    }
}
