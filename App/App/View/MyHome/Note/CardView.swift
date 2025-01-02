//
//  CardView.swift
//  App
//
//  Created by Yongsik Kim on 1/1/25.
//

import SwiftUI

struct CardView: View {
    let card: EntityCard
    
    @State var isFront = true
    @State var frontDegree: CGFloat = 0
    @State var backDegree: CGFloat = -90
    let flipDuration: CGFloat = 0.3
    
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        ZStack {
            frontView
                .rotation3DEffect(.degrees(frontDegree), axis: (x: 0, y: 1, z: 0))
            backView
                .rotation3DEffect(.degrees(backDegree), axis: (x: 0, y: 1, z: 0))
            
        }
        .contentShape(.rect)
        .onTapGesture {
            isFront.toggle()
            if isFront {
                withAnimation(.spring(duration: flipDuration)) {
                    frontDegree = 90
                }
                withAnimation(.spring(duration: flipDuration).delay(flipDuration)) {
                    backDegree = 0
                }
            } else {
                withAnimation(.spring(duration: flipDuration)) {
                    backDegree = -90
                }
                withAnimation(.spring(duration: flipDuration).delay(flipDuration)) {
                    frontDegree = 0
                }
            }
        }
    }
    
    var frontView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text(card.question)
                    .foregroundStyle(.label1)
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            Spacer()
        }
        .clipShape(.rect(cornerRadius: 24))
        .background(
            Color.primaryFill
                .clipShape(.rect(cornerRadius: 24))
                .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 16)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.appPrimary, lineWidth: 4)
        }
    }
    
    var backView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text(card.answer)
                    .font(.title)
                    .bold()
                Spacer()
            }
            Spacer()
        }
        .clipShape(.rect(cornerRadius: 24))
        .background(
            Color.secondaryFill
                .clipShape(.rect(cornerRadius: 24))
                .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 16)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.primaryFill, lineWidth: 4)
        }
    }
}

#Preview {
    let card = EntityCard(createdAt: .now,
                          updatedAt: .now,
                          userId: .init(),
                          noteId: 0,
                          cardType: .wordCard,
                          question: "HAHAHAHAHA",
                          answer: "HOHOHOHOH",
                          sttEnabled: true,
                          isPrivate: false)
    CardView(card: card)
}
