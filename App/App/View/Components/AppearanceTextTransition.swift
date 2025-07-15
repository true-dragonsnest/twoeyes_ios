//
//  AppearanceTextTransition.swift
//  App
//
//  Created by Yongsik Kim on 4/27/25.
//

import SwiftUI

struct EmphasisAttribute: TextAttribute {}

/// A text renderer that animates its content character by character.
struct AppearanceEffectRenderer: TextRenderer, Animatable {
    /// The amount of time that passes from the start of the animation.
    /// Animatable.
    var elapsedTime: TimeInterval

    /// The amount of time the app spends animating an individual character.
    var characterDuration: TimeInterval

    /// The amount of time the entire animation takes.
    var totalDuration: TimeInterval

    var spring: Spring {
        .snappy(duration: characterDuration - 0.05, extraBounce: 0.4)
    }

    var animatableData: Double {
        get { elapsedTime }
        set { elapsedTime = newValue }
    }

    init(elapsedTime: TimeInterval, characterDuration: Double = 0.4, totalDuration: TimeInterval) {
        self.elapsedTime = min(elapsedTime, totalDuration)
        self.characterDuration = min(characterDuration, totalDuration)
        self.totalDuration = totalDuration
    }

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        // Count total characters in emphasized text
        var totalCharCount = 0
        for unit in layout.flattenedRuns {
            if unit[EmphasisAttribute.self] != nil {
                totalCharCount += unit.count
            }
        }
        
        // Keep track of the current character index across all runs
        var currentCharacterIndex = 0
        
        for unit in layout.flattenedRuns {
            if unit[EmphasisAttribute.self] != nil {
                // Process each character individually
                for slice in unit {
                    // Calculate the delay based on character index
                    let delay = characterDelay(totalCount: totalCharCount)
                    
                    // The time that the current character starts animating,
                    // relative to the start of the animation.
                    let timeOffset = TimeInterval(currentCharacterIndex) * delay
                    
                    // The amount of time that passes for the current character.
                    let characterTime = max(0, min(elapsedTime - timeOffset, characterDuration))
                    
                    // Make a copy of the context so that individual characters
                    // don't affect each other.
                    var copy = context
                    draw(slice, at: characterTime, in: &copy)
                    
                    currentCharacterIndex += 1
                }
            } else {
                // Make a copy of the context so that individual runs
                // don't affect each other.
                var copy = context
                // Runs that don't have a tag of `EmphasisAttribute` quickly
                // fade in.
                copy.opacity = UnitCurve.easeIn.value(at: elapsedTime / 0.2)
                copy.draw(unit)
            }
        }
    }

    func draw(_ slice: Text.Layout.RunSlice, at time: TimeInterval, in context: inout GraphicsContext) {
        // Calculate a progress value in unit space for blur and
        // opacity, which derive from `UnitCurve`.
        let progress = time / characterDuration

        let opacity = UnitCurve.easeIn.value(at: 1.4 * progress)

        let blurRadius =
            slice.typographicBounds.rect.height / 16 *
            UnitCurve.easeIn.value(at: 1 - progress)

        // The y-translation derives from a spring, which requires a
        // time in seconds.
        let translationY = spring.value(
            fromValue: -slice.typographicBounds.descent,
            toValue: 0,
            initialVelocity: 0,
            time: time)

        context.translateBy(x: 0, y: translationY)
        context.addFilter(.blur(radius: blurRadius))
        context.opacity = opacity
        context.draw(slice, options: .disablesSubpixelQuantization)
    }

    /// Calculates how much time passes between the start of two consecutive
    /// character animations.
    ///
    /// For example, if there's a total duration of 1 s and a character
    /// duration of 0.5 s, the delay for two characters is 0.5 s.
    /// The first character starts at 0 s, and the second character starts at 0.5 s
    /// and finishes at 1 s.
    ///
    /// However, to animate many characters in the same duration,
    /// the delay is distributed evenly to ensure animation completes within totalDuration.
    func characterDelay(totalCount: Int) -> TimeInterval {
        guard totalCount > 1 else { return 0 }
        
        let count = TimeInterval(totalCount)
        let remainingTime = totalDuration - characterDuration
        
        // Ensure all characters complete their animation within totalDuration
        return remainingTime / (count - 1)
    }
}

extension Text.Layout {
    /// A helper function for easier access to all runs in a layout.
    var flattenedRuns: some RandomAccessCollection<Text.Layout.Run> {
        self.flatMap { line in
            line
        }
    }

    /// A helper function for easier access to all run slices in a layout.
    var flattenedRunSlices: some RandomAccessCollection<Text.Layout.RunSlice> {
        flattenedRuns.flatMap(\.self)
    }
}

struct AppearanceTextTransition: Transition {
    let onComplete: (() -> Void)?
    
    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
    }
    
    static var properties: TransitionProperties {
        TransitionProperties(hasMotion: true)
    }

    func body(content: Content, phase: TransitionPhase) -> some View {
        let duration = 1.5  // Longer duration to accommodate character-by-character animation
        let elapsedTime = phase.isIdentity ? duration : 0
        let renderer = AppearanceEffectRenderer(
            elapsedTime: elapsedTime,
            characterDuration: 0.4,  // Duration per character
            totalDuration: duration
        )

        content.transaction { transaction in
            // Force the animation of `elapsedTime` to pace linearly and
            // drive per-character springs based on its value.
            if !transaction.disablesAnimations {
                transaction.animation = .linear(duration: duration)
            }
        } body: { view in
            view.textRenderer(renderer)
                .onAnimationCompleted(for: elapsedTime) {
                    if phase.isIdentity {
                        onComplete?()
                    }
                }
        }
    }
}

// Animation completion detection extension
extension View {
    func onAnimationCompleted<Value: VectorArithmetic>(for value: Value, completion: @escaping () -> Void) -> some View {
        self.modifier(AnimationCompletionObserver(observedValue: value, completion: completion))
    }
}

struct AnimationCompletionObserver<Value: VectorArithmetic>: AnimatableModifier {
    var animatableData: Value {
        didSet {
            notifyCompletionIfFinished()
        }
    }
    
    private var targetValue: Value
    private let completion: () -> Void
    
    init(observedValue: Value, completion: @escaping () -> Void) {
        self.completion = completion
        self.animatableData = observedValue
        self.targetValue = observedValue
    }
    
    private func notifyCompletionIfFinished() {
        if animatableData == targetValue {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
    }
}

#Preview {
    @Previewable @State var visible = false
    VStack {
        if visible {
            Text("Character by Character Animation\nEach letter appears one at a time\nWatch the magical effect!")
                .customAttribute(EmphasisAttribute())
                .foregroundStyle(.primary)
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(AppearanceTextTransition())
        }
        
        Button {
            withAnimation(.easeInOut.delay(visible ? 0.5 : 0)) {
                visible.toggle()
            }
        } label: {
            Text("Toggle")
        }
    }
}
