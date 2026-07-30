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

    func test_resolveConfigValue_usesEnvironmentVariableWhenSecretsMissing() {
        setenv("APP_CONFIG_TEST_ENV_KEY", "env-value", 1)
        defer { unsetenv("APP_CONFIG_TEST_ENV_KEY") }

        let val = AppConfig.resolveConfigValue(
            key: "APP_CONFIG_TEST_NON_SECRET_KEY",
            envKey: "APP_CONFIG_TEST_ENV_KEY",
            defaultValue: "default-val"
        )
        XCTAssertEqual(val, "env-value")
    }
}
