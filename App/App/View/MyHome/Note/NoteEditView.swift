//
//  NoteEditView.swift
//  App
//
//  Created by Yongsik Kim on 12/28/24.
//

import SwiftUI

struct NoteEditView: View {
    @EnvironmentObject var myHomeViewModel: MyHomeViewModel
    @Environment(\.sceneSize) var sceneSize
    
    @Bindable var model: NoteModel
    
    @State var tagInputFocused: Bool? = false
    
    @State var progressMessage: String?
    @State var showAlert = false
    
    var body: some View {
        contentView
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarRole(.editor)
            .toolbar(.hidden, for: .tabBar)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Confirm"),
                    message: Text("Are you sure to skip AI flashcard generation?"),
                    primaryButton: .destructive(Text("Cancel")),
                    secondaryButton: .default(Text("Skip"))
                )
            }
            .onAppear {
                guard model.image != nil else {
                    ContentViewModel.shared.error = AppError.notInited("Wrong note image".le())
                    myHomeViewModel.navPop()
                    return
                }
            }
    }
    
    var contentView: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    imageView
                    infoView
                        .padding(.horizontal, 16)
                    noteTypeView
                    tagView
                        .padding(.horizontal, 16)
                    aiView
                    Divider()
                    actionButton
                        .padding(.vertical)
                }
            }
            .contentShape(.rect)
            .onTapGesture {
                tagInputFocused = false
            }
            
            if let progressMessage {
                ModalProgressView(text: progressMessage)
                    .ignoresSafeArea()
            }
        }
    }
    
    @ViewBuilder
    var imageView: some View {
        if let image = model.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .clipShape(.rect(cornerRadius: 8))
        }
    }
    
    var infoView: some View {
        VStack {
            HStack {
                Text("Note title")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.label1)
                Spacer()
            }
            TextField("Input note title", text: $model.title)
                .font(.headline)
                .foregroundStyle(.label1)
                .padding()
                .background(.secondaryFill)
                .clipShape(.rect(cornerRadius: 24))
        }
    }
    
    var noteTypeView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Note type")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.label1)
                Spacer()
            }
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(EntityNote.NoteType.allCases, id: \.self) { type in
                        VStack(spacing: 4) {
                            type.symbolName.iconButton(font: .system(size: 40), monochrome: .label1)
                                .frame(width: 64, height: 64)
                            Text(type.displayText)
                                .foregroundStyle(.label1)
                                .font(.footnote)
                                .lineLimit(1)
                        }
                        .frame(width: 64)
                        .padding()
                        .background(.secondaryFill)
                        .clipShape(.rect(cornerRadius: 16))
                        .overlay {
                            if type == model.noteType {
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(.appPrimary, lineWidth: 2)
                            }
                        }
                        .contentShape(.rect)
                        .onTapGesture {
                            model.noteType = type
                        }
                    }
                }
            }
            .contentMargins(.horizontal, 16)
        }
    }
    
    var tagView: some View {
        VStack {
            HStack {
                Text("Tags")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.label1)
                Spacer()
            }
            
            TagInputView(tags: $model.tags,
                         focused: $tagInputFocused,
                         appendWhenOutFocus: true,
                         onReturn: {})
            .padding()
            .background(.secondaryFill)
            .clipShape(.rect(cornerRadius: 24))
        }
        .contentShape(.rect)
        .onTapGesture {
            tagInputFocused = true
        }
    }
    
    var aiView: some View {
        VStack(spacing: 8) {
            VStack(spacing: 4) {
                HStack {
                    Text("AI flashcard")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.label1)
                    Spacer()
                }
                HStack {
                    Text("note.ai.generation.guide")
                        .font(.footnote)
                        .foregroundStyle(.label3)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            
            cardView
            
            if model.noteType == .custom {
                userPromptView
                    .padding(.horizontal, 16)
            }
            
            HStack(spacing: 32) {
                Spacer()
                ActionButton(text: model.cards.isEmpty ? "✨ AI Gen".localized : "🔄 Re-Gen".localized,
                             disabled: false) {
                    generate()
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var cardView: some View {
        if model.cards.isEmpty == false {
            ScrollView(.horizontal, showsIndicators: false) {
                let cardWidth = sceneSize.width - 32 * 2 - 16 * 2
                let cardHeight = cardWidth * 9 / 16
                LazyHStack(spacing: 16) {
                    ForEach(0..<model.cards.count, id: \.self) { i in
                        CardView(card: model.cards[i])
                            .frame(width: cardWidth, height: cardHeight)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollClipDisabled()
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.horizontal, 32 + 16)
            .padding(.vertical)
        }
    }
    
    var userPromptView: some View {
        VStack {
            TextField("note.ai.generation.user.prompt.guide", text: $model.userPrompt)
                .font(.headline)
                .foregroundStyle(.label1)
                .padding()
                .background(.secondaryFill)
                .clipShape(.rect(cornerRadius: 24))
        }
    }
    
    var actionButton: some View {
        ActionButton(text: "Done".localized,
                     disabled: false)
        {
            if model.cards.isEmpty {
                showAlert = true
            } else {
                commit()
            }
        }
    }
}

// MARK: - generation
extension NoteEditView {
    func generate() {
        Task { @MainActor in
            progressMessage = "Generating AI flashcards...".localized
            do {
                try await model.generate()
            } catch {
                ContentViewModel.shared.error = error
            }
            progressMessage = nil
        }
    }
    
    func commit() {
        Task { @MainActor in
            do {
                try await model.commit()
                myHomeViewModel.navPopToRoot()
            } catch {
                ContentViewModel.shared.error = error
            }
        }
    }
}
