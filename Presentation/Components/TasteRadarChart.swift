import SwiftUI

public struct TasteRadarChart: View {
    public let taste: TasteParameter
    public var maxScore: Double = 5.0
    public var accentColor: Color = Color.amberAccent

    public init(taste: TasteParameter, maxScore: Double = 5.0, accentColor: Color = Color.amberAccent) {
        self.taste = taste
        self.maxScore = maxScore
        self.accentColor = accentColor
    }

    private let labels = ["酸味", "甘味", "苦味", "コク", "香り"]

    private var scores: [Double] {
        [
            Double(taste.acidity),
            Double(taste.sweetness),
            Double(taste.bitterness),
            Double(taste.body),
            Double(taste.aroma)
        ]
    }

    public var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 * 0.7

            ZStack {
                // Background grid pentagons (1 to 5)
                ForEach(1...5, id: \.self) { level in
                    let gridRadius = radius * (Double(level) / maxScore)
                    radarPentagonPath(center: center, radius: gridRadius)
                        .stroke(Color.secondary.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: level == 5 ? [] : [3, 3]))
                }

                // Grid axis lines
                ForEach(0..<5, id: \.self) { index in
                    let angle = angleForIndex(index)
                    Path { path in
                        path.move(to: center)
                        path.addLine(to: pointForAngle(angle, radius: radius, center: center))
                    }
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                }

                // Radar filled area
                radarDataPath(center: center, radius: radius)
                    .fill(
                        LinearGradient(
                            colors: [accentColor.opacity(0.6), accentColor.opacity(0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Radar outline
                radarDataPath(center: center, radius: radius)
                    .stroke(accentColor, lineWidth: 2.5)

                // Data points
                ForEach(0..<5, id: \.self) { index in
                    let angle = angleForIndex(index)
                    let valueRadius = radius * (scores[index] / maxScore)
                    let point = pointForAngle(angle, radius: valueRadius, center: center)
                    Circle()
                        .fill(accentColor)
                        .frame(width: 6, height: 6)
                        .position(point)
                }

                // Labels
                ForEach(0..<5, id: \.self) { index in
                    let angle = angleForIndex(index)
                    let labelPoint = pointForAngle(angle, radius: radius + 18, center: center)
                    Text(labels[index])
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .position(labelPoint)
                }
            }
        }
        .frame(height: 180)
    }

    private func angleForIndex(_ index: Int) -> Double {
        let step = (2.0 * Double.pi) / 5.0
        return -Double.pi / 2.0 + (Double(index) * step)
    }

    private func pointForAngle(_ angle: Double, radius: Double, center: CGPoint) -> CGPoint {
        CGPoint(
            x: center.x + CGFloat(cos(angle) * radius),
            y: center.y + CGFloat(sin(angle) * radius)
        )
    }

    private func radarPentagonPath(center: CGPoint, radius: Double) -> Path {
        var path = Path()
        for i in 0..<5 {
            let point = pointForAngle(angleForIndex(i), radius: radius, center: center)
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }

    private func radarDataPath(center: CGPoint, radius: Double) -> Path {
        var path = Path()
        for i in 0..<5 {
            let valRadius = radius * (scores[i] / maxScore)
            let point = pointForAngle(angleForIndex(i), radius: valRadius, center: center)
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    TasteRadarChart(taste: TasteParameter(acidity: 4, sweetness: 3, bitterness: 2, body: 4, aroma: 5))
        .padding()
}
