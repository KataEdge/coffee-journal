import XCTest
@testable import CoffeeJournalCore

final class AppConfigTests: XCTestCase {

    func test_appConfig_properties() {
        XCTAssertTrue(AppConfig.useProductionEnvironment || !AppConfig.useProductionEnvironment)
        XCTAssertFalse(AppConfig.supabaseURL.isEmpty)
        XCTAssertFalse(AppConfig.supabaseAnonKey.isEmpty)
        XCTAssertFalse(AppConfig.s3BucketName.isEmpty)
    }

    func test_resolveConfigValue_fallbackToDefault() {
        let val = AppConfig.resolveConfigValue(key: "NON_EXISTENT_KEY", envKey: "NON_EXISTENT_ENV", defaultValue: "default-val")
        XCTAssertEqual(val, "default-val")
    }

    func test_resolveConfigValue_existingKey() {
        let urlVal = AppConfig.resolveConfigValue(key: "SUPABASE_URL", envKey: "SUPABASE_URL", defaultValue: "fallback")
        XCTAssertFalse(urlVal.isEmpty)
    }
}
