//
//  MyNoteListView.swift
//  App
//
//  Created by Yongsik Kim on 12/26/24.
//

import SwiftUI

struct MyNoteListView: View {
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                ForEach(0..<100, id: \.self) { note in
                    Text("\(note)")
                        .padding()
                        .border(.red)
                }
            }
        }
    }
}
