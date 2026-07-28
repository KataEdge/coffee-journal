import Foundation

public enum AppConfig {
    private static let secrets: [String: Any]? = {
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

    public static var supabaseURL: String {
        if let url = secrets?["SUPABASE_URL"] as? String, !url.isEmpty {
            return url
        }
        if let envURL = ProcessInfo.processInfo.environment["SUPABASE_URL"], !envURL.isEmpty {
            return envURL
        }
        return (Bundle.main.infoDictionary?["SUPABASE_URL"] as? String) ?? "https://placeholder.supabase.co"
    }

    public static var supabaseAnonKey: String {
        if let key = secrets?["SUPABASE_ANON_KEY"] as? String, !key.isEmpty {
            return key
        }
        if let envKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"], !envKey.isEmpty {
            return envKey
        }
        return (Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String) ?? "placeholder-key"
    }

    public static var s3BucketName: String {
        if let bucket = secrets?["AWS_S3_BUCKET_NAME"] as? String, !bucket.isEmpty {
            return bucket
        }
        if let envBucket = ProcessInfo.processInfo.environment["AWS_S3_BUCKET_NAME"], !envBucket.isEmpty {
            return envBucket
        }
        return (Bundle.main.infoDictionary?["AWS_S3_BUCKET_NAME"] as? String) ?? "coffee-journal-media"
    }
}

