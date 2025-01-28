//
//  MyHomeView.swift
//  App
//
//  Created by Yongsik Kim on 12/26/24.
//

import SwiftUI

struct MyHomeView: View {
    @StateObject var viewModel = MyHomeViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.navPath) {
            contentView
                .navigationTitle("My Notes")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        "plus.circle.fill".iconButton(font: .headline, monochrome: .appPrimary) {
                            viewModel.navPush(.init(viewType: .noteEdit(model: .init())))
                        }
                    }
                }
                .navigationDestination(for: MyHomeViewModel.NavPath.self) { path in
                    switch path.viewType {
                    case .noteEdit(let model):
                        NoteEditView(model: model)
                            .environmentObject(viewModel)
                    case .noteCapture(let model):
                        NoteCaptureView(model: model)
                            .environmentObject(viewModel)
                    case .cardList(let note):
                        CardListView(note: note)
                            .environmentObject(viewModel)
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
                .environmentObject(viewModel)
        }
    }
}
