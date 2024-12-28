//
//  RandomGradientAnimationView.swift
//  Nest3
//
//  Created by Yongsik Kim on 9/15/24.
//

import SwiftUI

@available(iOS 18.0, *)
struct RandomGradientAnimationView: View {
    let colors: [Color]
    
    // FIXME: need to improve ramdom point generation not to insersect to each other
    private let dimension: (Int, Int) = (3, 3)
    
    let duration: CGFloat
    
    @State var pointSet: [SIMD2<Float>] = []
    @State var colorSet: [Color] = []
    @State var timer = Timer.publish(every: 0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Group {
            if pointSet.isEmpty == false, colorSet.isEmpty == false {
                MeshGradient(width: dimension.0,
                             height: dimension.0,
                             points: pointSet,
                             colors: colorSet)
            } else {
                EmptyView()
            }
        }
        .onReceive(timer) { _ in
            generate()
        }
        .onAppear {
            generate()
            cancelTimer()
            startTimer()
        }
        .onDisappear {
            cancelTimer()
        }
    }
    
    func cancelTimer() {
        timer.upstream.connect().cancel()
    }
    
    func startTimer() {
        timer = Timer.publish(every: duration, on: .main, in: .common).autoconnect()
    }
    
    @MainActor
    private func generate() {
        func generateColors() -> [Color] {
            (0..<(dimension.0 * dimension.1)).map { _ in colors.randomElement()! }
        }
        
        func generatePoints() -> [SIMD2<Float>] {
            var points: [SIMD2<Float>] = []
            for iy in 0..<dimension.1 {
                for ix in 0..<dimension.0 {
                    let x: Float = ix == 0 ? 0 : (ix == dimension.0 - 1 ? 1
                                                  : Float.random(in: 0.1..<1))
                    let y: Float = iy == 0 ? 0 : (iy == dimension.1 - 1 ? 1
                                                  : Float.random(in: 0.1..<1))
                    points.append(.init(x: x, y: y))
                }
            }
            
            return points
        }
        
        withAnimation(.easeInOut(duration: duration)) {
            colorSet = generateColors()
            pointSet = generatePoints()
        }
    }
}

#Preview {
    Color.clear.background {
        if #available(iOS 18.0, *) {
            RandomGradientAnimationView(colors: [.blue, .purple, .red],
                                        duration: 1)
        } else {
            // Fallback on earlier versions
        }
    }
    .ignoresSafeArea()
}
