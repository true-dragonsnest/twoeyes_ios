//
//  NoteEditView.swift
//  App
//
//  Created by Yongsik Kim on 12/28/24.
//

import SwiftUI

struct NoteEditView: View {
    @Bindable var model: NoteModel
    
    @State var tagInputFocused: Bool? = false
    @State var inProgress = false
    
    var body: some View {
        contentView
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarRole(.editor)
            .toolbar(.hidden, for: .tabBar)
    }
    
    var contentView: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    imageView
                    infoView
                    tagView
                    Spacer()
                    actionButton
                }
            }
            .contentShape(.rect)
            .onTapGesture {
                tagInputFocused = false
            }
            
            if inProgress {
                ModalProgressView()
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
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.label1)
                Spacer()
            }
            HStack {
                TextField("Input note title", text: $model.title)
                    .font(.headline)
                    .foregroundStyle(.label1)
                    .padding()
                    .background(.secondaryFill)
                    .clipShape(.rect(cornerRadius: 24))
                    .onSubmit {
                        "haha : \(model.title)".ld()
                    }
                Spacer()
            }
        }
        .padding(.horizontal)
    }
    
    var tagView: some View {
        VStack {
            HStack {
                Text("Tags")
                    .font(.subheadline)
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
        .padding(.horizontal)
    }
        
    var actionButton: some View {
        Text(model.isEditMode ? "Apply Changes" : "Post Note")
            .font(.headline)
            .foregroundStyle(model.readyToSave ? .white : .label3)
            .padding()
            .background(model.readyToSave ? .appPrimary : .secondaryFill)
            .clipShape(.capsule)
            .onTapGesture {
                "cta".ld()
            }
            .padding(.bottom)
    }
}
