import Foundation

public enum AppConfig {
    public static var supabaseURL: String {
        return (Bundle.main.infoDictionary?["SUPABASE_URL"] as? String) ?? "https://placeholder.supabase.co"
    }

    public static var supabaseAnonKey: String {
        return (Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String) ?? "placeholder-key"
    }

    public static var s3BucketName: String {
        return (Bundle.main.infoDictionary?["AWS_S3_BUCKET_NAME"] as? String) ?? "coffee-journal-media"
    }
}
