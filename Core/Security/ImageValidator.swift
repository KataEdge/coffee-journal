import Foundation

public enum ImageFormat: String, Sendable {
    case jpeg
    case png
    case heic
    case webp
}

public struct ImageValidator: Sendable {
    public static let maxFileSizeBytes: Int = 5 * 1024 * 1024 // 5MB

    public static func validate(data: Data) throws -> ImageFormat {
        guard !data.isEmpty else {
            throw AppError.validationError("画像データが空です。")
        }

        if data.count > maxFileSizeBytes {
            let sizeMB = Double(data.count) / (1024.0 * 1024.0)
            let formattedSize = String(format: "%.1fMB", sizeMB)
            throw AppError.validationError("画像ファイルサイズ(\(formattedSize))が制限(5.0MB)を超えています。")
        }

        guard let format = detectFormat(data: data) else {
            throw AppError.validationError("未対応または不正な画像フォーマットです。JPEG、PNG、HEIC、WebP の画像のみ対応しています。")
        }

        return format
    }

    public static func detectFormat(data: Data) -> ImageFormat? {
        guard data.count >= 12 else { return nil }

        let bytes = [UInt8](data.prefix(12))

        // JPEG: FF D8 FF
        if bytes.count >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF {
            return .jpeg
        }

        // PNG: 89 50 4E 47 0D 0A 1A 0A
        if bytes.count >= 8 &&
            bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47 &&
            bytes[4] == 0x0D && bytes[5] == 0x0A && bytes[6] == 0x1A && bytes[7] == 0x0A {
            return .png
        }

        // WebP: RIFF (bytes 0..3) ... WEBP (bytes 8..11)
        if bytes.count >= 12 &&
            bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
            bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50 {
            return .webp
        }

        // HEIC/HEIF: "ftyp" at bytes 4..7
        if bytes.count >= 12 &&
            bytes[4] == 0x66 && bytes[5] == 0x74 && bytes[6] == 0x79 && bytes[7] == 0x70 {
            let brand = String(bytes: bytes[8...11], encoding: .ascii) ?? ""
            if brand.hasPrefix("he") || brand.hasPrefix("mif1") || brand.hasPrefix("msf1") {
                return .heic
            }
        }

        return nil
    }
}
