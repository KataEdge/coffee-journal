# SwiftUI Guidelines (iOS 17+)

## Architecture & State Management
- Use `@Observable` macro for ViewModels (Observation framework introduced in iOS 17).
- Separate presentation logic completely from UI views into ViewModels or UseCases.
- Pass dependencies explicitly via initializers or SwiftUI `@Environment`.

## UI Design & Styling
- Avoid generic colors. Use rich dark/light adaptive color palettes with modern typography.
- Use glassmorphism (`.background(.ultraThinMaterial)`), subtle drop shadows, dynamic gradients, and micro-animations for high-end polish.
- Provide `#Preview` macros for all components and views using Mock data.

## Component Structure
- Keep views small, modular, and single-purpose.
- Export reusable UI elements to `Presentation/Components/`.
