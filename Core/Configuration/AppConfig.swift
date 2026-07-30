import Foundation

public enum AppConfig {
    /// 本番環境 (Supabase) とデモ環境 (Mock) の切り替えフラグ
    public static var useProductionEnvironment: Bool = true

    internal static let secrets: [String: Any]? = {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            return dict
        }
        let pwdSecretsPath = FileManager.default.currentDirectoryPath + "/Secrets.plist"
        if let dict = NSDictionary(contentsOfFile: pwdSecretsPath) as? [String: Any] {
            return dict
        }
        return nil
    }()

    internal static func resolveConfigValue(key: String, envKey: String, defaultValue: String) -> String {
        if let val = secrets?[key] as? String, !val.isEmpty {
            return val
        }
        if let envVal = ProcessInfo.processInfo.environment[envKey], !envVal.isEmpty {
            return envVal
        }
        return (Bundle.main.infoDictionary?[key] as? String) ?? defaultValue
    }

    public static var supabaseURL: String {
        resolveConfigValue(key: "SUPABASE_URL", envKey: "SUPABASE_URL", defaultValue: "https://placeholder.supabase.co")
    }

    public static var supabaseAnonKey: String {
        resolveConfigValue(key: "SUPABASE_ANON_KEY", envKey: "SUPABASE_ANON_KEY", defaultValue: "placeholder-key")
    }

    public static var s3BucketName: String {
        resolveConfigValue(key: "AWS_S3_BUCKET_NAME", envKey: "AWS_S3_BUCKET_NAME", defaultValue: "coffee-journal-media")
    }
}
