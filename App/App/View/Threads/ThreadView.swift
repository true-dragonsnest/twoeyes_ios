//
//  ThreadView.swift
//  App
//
//  Created by Yongsik Kim on 5/23/25.
//

import SwiftUI
import Kingfisher

struct ThreadView: View {
    let entity: EntityThread
    
    var body: some View {
        content
            .navigationTitle(entity.title ?? "Thread")
            .toolbarRole(.editor)
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .bottom) {
                commentInput
                    .padding()
            }
    }
    
    var content: some View {
        VStack {
            imageCarousel
                .padding(.horizontal, 16)
            Spacer()
        }
    }
    
    @ViewBuilder
    var imageCarousel: some View {
        let height: CGFloat = 300
        
        if let images = entity.images {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(Array(images.enumerated()), id: \.0) { index, image in
                        if let url = URL(fromString: image) {
                            KFImage(url)
                                .backgroundDecode(true)
                                .resizable()
                                .placeholder {
                                    Color.secondaryFill
                                }
                                .aspectRatio(contentMode: .fit)
                                .frame(height: height)
                        }
                    }
                }
            }
            .background(.clear)
            .frame(height: height)
            .borderedCapsule(cornerRadius: 12, strokeColor: .label3)
        }
    }
    
    // MARK: comment input
    @FocusState var focused
    var commentInput: some View {
        InputBar(text: "Drop a comment",
                 focused: $focused,
                 sendEnabled: true)
        { comment, commentAttachments in
            // TODO: code here
        }
    }
}
