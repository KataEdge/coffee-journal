import Foundation

public struct TasteParameter: Codable, Equatable, Sendable {
    public var acidity: Int     // 酸味 (1-5)
    public var sweetness: Int   // 甘味 (1-5)
    public var bitterness: Int  // 苦味 (1-5)
    public var body: Int        // コク・ボディ (1-5)
    public var aroma: Int       // 香り (1-5)

    public init(acidity: Int = 3, sweetness: Int = 3, bitterness: Int = 3, body: Int = 3, aroma: Int = 3) {
        self.acidity = min(max(acidity, 1), 5)
        self.sweetness = min(max(sweetness, 1), 5)
        self.bitterness = min(max(bitterness, 1), 5)
        self.body = min(max(body, 1), 5)
        self.aroma = min(max(aroma, 1), 5)
    }
}
