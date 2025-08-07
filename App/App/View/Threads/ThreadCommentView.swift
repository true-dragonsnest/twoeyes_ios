//
//  ThreadCommentView.swift
//  App
//
//  Created by Assistant on 5/8/25.
//

import SwiftUI
import Kingfisher

struct ThreadCommentView: View {
    let comment: EntityComment
    
    var body: some View {
        HStack(alignment: .top) {
            profileImage
            
            VStack(alignment: .leading) {
                header
                
                Text(comment.content)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                
                if comment.isAiGenerated {
                    aiGeneratedBadge
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var profileImage: some View {
        if let profileUrl = comment.userProfilePictureUrl,
           let url = URL(string: profileUrl) {
            KFImage(url)
                .placeholder {
                    Circle()
                        .fill(.secondary)
                        .frame(width: 32, height: 32)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 32, height: 32)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(.secondary)
                .frame(width: 32, height: 32)
        }
    }
    
    private var header: some View {
        HStack {
            Text(comment.userNickname ?? comment.userId)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(comment.createdAt, style: .relative)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var aiGeneratedBadge: some View {
        HStack {
            Image(systemName: "sparkles")
                .font(.caption)
                .foregroundColor(.blue)
            Text("AI Generated")
                .font(.caption)
                .foregroundColor(.blue)
        }
    }
}
