//
//  MyHomeView.swift
//  App
//
//  Created by Yongsik Kim on 12/26/24.
//

import SwiftUI

struct MyHomeView: View {
    @Bindable var viewModel = MyHomeViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.navPath) {
            contentView
                .navigationTitle("My Notes")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        "plus.circle.fill".iconButton(font: .headline, monochrome: .label1) {
                            viewModel.navPush(.addNote)
                        }
                    }
                }
                .navigationDestination(for: MyHomeViewModel.NavPath.self) { path in
                    switch path {
                    case .addNote:
                        CaptureNoteView()
                    default:
                        Color.red.ignoresSafeArea()
                    }
                }
        }
    }
    
    var contentView: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            MyNoteListView()
        }
    }
}
