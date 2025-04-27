//
//  AddNewsView.swift
//  App
//
//  Created by Yongsik Kim on 2/16/25.
//

import SwiftUI

struct AddNewsView: View {
    @State var url: String = ""
    @State var inProgress = false
    @State var next = false
    
    @State var article: EntityArticle?
    
    @FocusState var focused: Bool
        
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack {
                inputView
                    .padding(.horizontal)
                
                if article != nil {
                    Spacer()
                        .border(.yellow)
                }
            }
            
            if let article {
                ArticleCardView(article: article, selected: true)
                    .frame(maxWidth: .infinity)
                    .scaleEffect(0.7)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
            
            if inProgress {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
            }
        }
        .overlay(alignment: .bottom) {
            if next {
                Button {
                    withAnimation {
                    }
                } label: {
                    Text("Add")
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(.appPrimary)
                        .clipShape(.rect(cornerRadius: 24))
                        .padding(.bottom, 40)
                }
            }
        }
    }
    
    var inputView: some View {
        VStack(spacing: 20) {
            Text("Post a news")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.label2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                TextField("Enter news URL", text: $url)
                    .foregroundStyle(.label1)
                    .font(.headline)
                    .onSubmit {
                        "submit : \(url)".ld()
                        addArticle()
                    }
                    .focused($focused)
                    .submitLabel(.go)
                    .padding()
                    .background(Color.primaryFill)
                    .clipShape(.rect(cornerRadius: 24))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(.label3, lineWidth: 1)
                    }
                
                Button {
                    let pasteboard = UIPasteboard.general
                    if pasteboard.hasStrings {
                        url = pasteboard.string ?? ""
                        focused = true
                    }
                } label: {
                    Text("Paste")
                        .foregroundStyle(.white)
                        .font(.headline)
                        .padding()
                        .background(.appPrimary)
                        .clipShape(.rect(cornerRadius: 24))
                }
            }
        }
    }
    
    func addArticle() {
        guard url.isEmpty == false else { return }
        
        Task {
            await MainActor.run { inProgress = true }
            
            do {
                let article = try await UseCases.Articles.post(url: url)
                await MainActor.run {
                    withAnimation {
                        self.article = article
                    }
                }
            } catch {
                ContentViewModel.shared.error = error
            }
            await MainActor.run { inProgress = false }
        }
    }
}

#Preview {
    AddNewsView()
}
