import Foundation

public struct TasteParameter: Codable, Equatable, Sendable {
    public var acidity: Int     // 酸味 (1-10)
    public var sweetness: Int   // 甘味 (1-10)
    public var bitterness: Int  // 苦味 (1-10)
    public var body: Int        // コク・ボディ (1-10)
    public var aroma: Int       // 香り (1-10)

    public init(acidity: Int = 5, sweetness: Int = 5, bitterness: Int = 5, body: Int = 5, aroma: Int = 5) {
        self.acidity = min(max(acidity, 1), 10)
        self.sweetness = min(max(sweetness, 1), 10)
        self.bitterness = min(max(bitterness, 1), 10)
        self.body = min(max(body, 1), 10)
        self.aroma = min(max(aroma, 1), 10)
    }
}
