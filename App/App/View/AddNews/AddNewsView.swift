//
//  AddNewsView.swift
//  App
//
//  Created by Yongsik Kim on 2/16/25.
//

import SwiftUI

struct AddNewsView: View {
    @State var url: String = ""
    
    @State var article: EntityArticle?
    @State var threadId: Int?
    @State var threads: [EntityThread]?
    @State var showThreads = false
    
//    @State var article: EntityArticle? = testArticle
//    @State var threadId: Int? = 0
//    @State var threads: [EntityThread]? = testThreads
//    @State var showThreads = false
    
    @FocusState var focused: Bool
    @State var inProgress = false
        
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
                VStack {
                    ArticleCardView(article: article, selected: true)
                        .frame(maxWidth: .infinity)
                        .overlay(alignment: .bottomTrailing) {
                            Group {
                                if let threadId, let thread = threads?.first(where: { $0.id == threadId }) {
                                    ThreadCardView(thread: thread)
                                        .frame(width: 200, height: 260)
                                } else if threadId == -1 {
                                    newThreadCard
                                }
                            }
                            .shadow(color: .black, radius: 8)
                            .offset(x: 20, y: 30)
                            .rotationEffect(.degrees(10))
                        }
                        .scaleEffect(0.8)
                    
                    Spacer()
                    
                    Button {
                        if threadId == nil {
                            loadThreads()
                        } else {
                            commit()
                        }
                    } label: {
                        Text(threadId == nil ? "Next" : "Done")
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(.appPrimary)
                            .clipShape(.rect(cornerRadius: 24))
                    }
                    .opacity(self.article != nil ? 1 : 0)
                    .padding(.bottom, 40)
                }
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
            
            if showThreads {
                VStack(spacing: 0) {
                    Spacer()
                    
                    threadListView
                        .padding(.vertical, 40)
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadii: .init(topLeading: 24, bottomLeading: 0, bottomTrailing: 0, topTrailing: 24)))
                }
                .transition(.move(edge: .bottom))
                .zIndex(2)
            }
            
            if inProgress {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    .zIndex(10)
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
            
            if article == nil {
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
                        .borderedCapsule(cornerRadius: 24, strokeColor: .label3)
                    
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
    }
    
    var newThreadCard: some View {
        Color.background
            .frame(width: 200, height: 200 + 60)
            .overlay {
                VStack(spacing: 12) {
                    Spacer()
                    Text("Create\na new thread.")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.label1)
                        .multilineTextAlignment(.center)
                    "plus".iconButton(font: .title2, monochrome: .appPrimary)
                        .bold()
                    Spacer()
                }
            }
            .borderedCapsule(cornerRadius: 12, strokeColor: .label3)
    }
    
    var threadListView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Please select the thread to which this article will be added.")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.label1)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if let threads {
                        ForEach(threads) { thread in
                            ThreadCardView(thread: thread)
                                .frame(width: 200, height: 260)
                                .overlay(alignment: .bottomTrailing) {
                                    Text("\(thread.similarity ?? 0)")
                                        .font(.footnote)
                                }
                                .onTapGesture {
                                    selectThread(thread.id)
                                }
                        }
                    }
                    newThreadCard
                        .onTapGesture {
                            selectThread(-1)
                        }
                }
                .padding(.horizontal, 16)
            }
            .scrollClipDisabled()
        }
    }
    
    func addArticle() {
        guard url.isEmpty == false else { return }
        
        Task {
            await MainActor.run {
                inProgress = true
                clear()
            }
            
            do {
                let article = try await UseCases.Articles.post(url: url)
                // FUCK: let article = testArticle
                await MainActor.run {
                    withAnimation {
                        self.article = article
                    }
                }
            } catch {
                ContentViewModel.shared.setError(error)
            }
            await MainActor.run { inProgress = false }
        }
    }
    
    func loadThreads() {
        guard let articleId = article?.id else { return }
        Task {
            await MainActor.run { inProgress = true }
            
            do {
                let threads = try await UseCases.Threads.findSimilar(to: articleId)
                // FUCK: let threads = testThreads
                await MainActor.run {
                    self.threads = threads
                    withAnimation {
                        showThreads = true
                    }
                }
            } catch {
                ContentViewModel.shared.setError(error)
            }
            
            await MainActor.run { inProgress = false }
        }
    }
    
    @MainActor
    func selectThread(_ threadId: Int?) {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        withAnimation {
            self.threadId = threadId
            showThreads = false
        }
    }
    
    func commit() {
        guard let threadId, let articleId = article?.id else { return }
        Task {
            await MainActor.run { inProgress = true }
            
            do {
                let _ = try await UseCases.Threads.addArticle(articleId: articleId,
                                                                  to: threadId < 0 ? nil : threadId)
                ContentViewModel.shared.setToastMessage("The news has been added")
            } catch {
                ContentViewModel.shared.setError(error)
            }
            
            await MainActor.run {
                inProgress = false
                clear()
                url = ""
            }
        }
    }
    
    @MainActor
    func clear() {
        withAnimation {
            article = nil
            threadId = nil
        }
    }
}
