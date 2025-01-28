//
//  CardListView.swift
//  App
//
//  Created by Yongsik Kim on 1/7/25.
//

import SwiftUI

struct CardListView: View {
    @EnvironmentObject var myHomeViewModel: MyHomeViewModel
    @Environment(\.sceneSize) var sceneSize
    
    let note: EntityNote
    @State var cards: [EntityCard] = []
    
    var body: some View {
        contentView
            .navigationTitle("Card List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarRole(.editor)
            .toolbar(.hidden, for: .tabBar)
            .task {
                await fetchCards()
            }
    }
    
    @ViewBuilder
    var contentView: some View {
        let cardWidth = sceneSize.width - 32 * 2 - 16 * 2
        let cardHeight = cardWidth * 9 / 16

        if cards.isEmpty {
            ModalProgressView()
                .ignoresSafeArea()
        } else {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(0..<cards.count, id: \.self) { i in
                        CardView(card: cards[i])
                            .frame(width: cardWidth, height: cardHeight)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
    
    func fetchCards() async {
        guard let noteId = note.id else { return }
        
        do {
            let cards = try await UseCases.Fetch.noteCards(noteId: noteId)
            await MainActor.run {
                self.cards = cards
            }
        } catch {
            ContentViewModel.shared.error = error
        }
    }
}

