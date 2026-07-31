#if canImport(Supabase)
import Foundation
import Supabase

public final class SupabaseCoffeeRepository: CoffeeRepositoryProtocol, @unchecked Sendable {
    private let client: SupabaseClient
    private let tableName = "tasting_notes"

    public init(client: SupabaseClient) {
        self.client = client
    }

    public convenience init() {
        let url = URL(string: AppConfig.supabaseURL) ?? URL(string: "https://placeholder.supabase.co")!
        let client = SupabaseClient(supabaseURL: url, supabaseKey: AppConfig.supabaseAnonKey)
        self.init(client: client)
    }

    public func fetchTastingNotes() async throws -> [CafeVisitNote] {
        do {
            let dtos: [TastingNoteDTO] = try await client
                .from(tableName)
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            return dtos.map { $0.toDomain() }
        } catch {
            throw wrapError(error)
        }
    }

    public func fetchTastingNotes(for userId: UUID) async throws -> [CafeVisitNote] {
        do {
            let dtos: [TastingNoteDTO] = try await client
                .from(tableName)
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("created_at", ascending: false)
                .execute()
                .value
            return dtos.map { $0.toDomain() }
        } catch {
            throw wrapError(error)
        }
    }

    public func fetchTastingNote(by id: UUID) async throws -> CafeVisitNote? {
        do {
            let dtos: [TastingNoteDTO] = try await client
                .from(tableName)
                .select()
                .eq("id", value: id.uuidString)
                .limit(1)
                .execute()
                .value
            return dtos.first?.toDomain()
        } catch {
            throw wrapError(error)
        }
    }

    public func createTastingNote(_ note: CafeVisitNote) async throws -> CafeVisitNote {
        try validateNote(note)
        do {
            let dto = TastingNoteDTO(from: note)
            let insertedDTO: TastingNoteDTO = try await client
                .from(tableName)
                .insert(dto)
                .select()
                .single()
                .execute()
                .value
            return insertedDTO.toDomain()
        } catch {
            throw wrapError(error)
        }
    }

    public func updateTastingNote(_ note: CafeVisitNote) async throws -> CafeVisitNote {
        try validateNote(note)
        do {
            let dto = TastingNoteDTO(from: note)
            let updatedDTO: TastingNoteDTO = try await client
                .from(tableName)
                .update(dto)
                .eq("id", value: note.id.uuidString)
                .select()
                .single()
                .execute()
                .value
            return updatedDTO.toDomain()
        } catch {
            throw wrapError(error)
        }
    }

    public func deleteTastingNote(id: UUID) async throws {
        do {
            try await client
                .from(tableName)
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
        } catch {
            throw wrapError(error)
        }
    }

    // MARK: - Internal Helper
    private func validateNote(_ note: CafeVisitNote) throws {
        if note.drinkName.count > 100 {
            throw AppError.validationError("ドリンク・コーヒー豆の名前は100文字以内で入力してください。")
        }
        if let comment = note.comment, comment.count > 2000 {
            throw AppError.validationError("コメントは2000文字以内で入力してください。")
        }
    }

    internal func wrapError(_ error: Error) -> AppError {
        if let appErr = error as? AppError {
            return appErr
        }
        return AppError.databaseError(error.localizedDescription)
    }
}
#endif
