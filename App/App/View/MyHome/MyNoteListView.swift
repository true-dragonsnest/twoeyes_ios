//
//  MyNoteListView.swift
//  App
//
//  Created by Yongsik Kim on 12/26/24.
//

import SwiftUI

struct MyNoteListView: View {
    @EnvironmentObject var myHomeViewModel: MyHomeViewModel
    
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                addNoteView
                
                if myHomeViewModel.notes.isEmpty == false {
                    Divider()
                    ForEach(myHomeViewModel.notes) { note in
                        NoteListCell(note: note)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    var addNoteView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Add Note")
                    .font(.title)
                    .fontWeight(.semibold)
                Spacer()
            }
            Spacer()
            "plus.circle.fill".iconButton(font: .title, palette: .white, .appPrimary)
            Spacer()
        }
        .frame(height: 150)
        .clipShape(.rect(cornerRadius: 24))
        .background(
            Color.primaryFill
                .clipShape(.rect(cornerRadius: 24))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.appPrimary, lineWidth: 1)
        }
        .contentShape(.rect)
        .onTapGesture {
            myHomeViewModel.navPush(.init(viewType: .noteCapture))
        }
    }
}

import Kingfisher

struct NoteListCell: View {
    let note: EntityNote
    
    var body: some View {
        HStack(spacing: 24) {
            if let imageUrl = note.pictureUrl {
                KFImage(URL(fromString: imageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(16)
            }
         
            VStack(spacing: 16) {
                if let title = note.title {
                    HStack {
                        Text(title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.label1)
                        Spacer()
                    }
                }
                Spacer()
                // FIXME: need stats in note table
//                HStack(alignment: .bottom) {
//                    "rectangle.portrait.on.rectangle.portrait.fill".iconButton(font: .title, palette: .label1, .label2)
//                    Text(note.)
//                }
            }
        }
        .frame(height: 200)
        .padding()
        .background(.regularMaterial)
        .overlay(alignment: .bottomTrailing) {
            Text(note.createdAt, style: .relative)
                .font(.footnote)
                .foregroundStyle(.label2)
                .padding()
        }
        .clipShape(.rect(cornerRadius: 24))
    }
}
