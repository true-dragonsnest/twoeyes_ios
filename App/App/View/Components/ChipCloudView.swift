//
//  ChipCloudView.swift
//  App
//
//  Created by Yongsik Kim on 12/29/24.
//

import SwiftUI

struct ChipCloudView<Content: View>: View {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    @ViewBuilder let content: () -> Content
    
    init(horizontalSpacing: CGFloat = 8,
         verticalSpacing: CGFloat = 8,
         @ViewBuilder content: @escaping () -> Content)
    {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.content = content
    }
    
    var body: some View {
        ChipCloudLayout(horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing) {
            content()
        }
    }
}

private struct ChipCloudLayout: Layout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    
    init(horizontalSpacing: CGFloat, verticalSpacing: CGFloat) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(proposal) }
        let maxViewHeight = sizes.map { $0.height }.max() ?? 0
        var currentRowWidth: CGFloat = 0
        var totalHeight: CGFloat = maxViewHeight
        var totalWidth: CGFloat = 0
        
        for size in sizes {
            if currentRowWidth + horizontalSpacing + size.width > proposal.width ?? 0 {
                totalHeight += maxViewHeight + verticalSpacing
                currentRowWidth = size.width
            } else {
                currentRowWidth += size.width + horizontalSpacing
            }
            totalWidth = max(totalWidth, currentRowWidth)
        }
        
        return .init(width: proposal.width ?? totalWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(proposal) }
        let maxViewHeight = sizes.map { $0.height }.max() ?? 0
        var point = CGPoint(x: bounds.minX, y: bounds.minY)
        
        for index in subviews.indices {
            if point.x + sizes[index].width > bounds.maxX {
                point.x = bounds.minX
                point.y += maxViewHeight + verticalSpacing
            }
            subviews[index].place(at: point, proposal: ProposedViewSize(sizes[index]))
            point.x += sizes[index].width + horizontalSpacing
        }
    }
}
