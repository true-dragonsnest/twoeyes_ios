//
//  TalkView.swift
//  App
//
//  Created by Yongsik Kim on 1/27/25.
//

import SwiftUI

private let T = #fileID

struct TalkView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.sceneSize) var sceneSize
    @Environment(\.safeAreaInsets) var safeAreaInsets
    
    @State var model = TalkModel()
    
    @State var speaking = false
    @State var speakInput: String = ""
    
    @State var inProgress = false
    @State var errorMessage: String?
    
    var body: some View {
        contentView
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarRole(.editor)
            .toolbar(.hidden, for: .tabBar)
//            .navigationBarBackButtonHidden(true)
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    "chevron.left.circle.fill".navbarButton {
//                        dismiss()
//                    }
//                }
//            }
            .preferredColorScheme(.dark)
            .onAppear {
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(3))
                    withAnimation {
                        speaking = true
                    }
                }
            }
    }
    
    @ViewBuilder
    var contentView: some View {
        if inProgress {
            VStack {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.label1)
            }
        } else if let errorMessage {
            Text(errorMessage)
                .font(.headline)
                .foregroundStyle(Color.error)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        } else {
            talkView
        }
    }
    
    var talkView: some View {
        ZStack {
            backgroundView
            
            VStack {
                Color.clear
                    .layoutPriority(1)
                chatListView
                    .edgesIgnoringSafeArea([.bottom])
                    .layoutPriority(1)
            }
            
            VStack {
                Spacer()
                controlView
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    var backgroundView: some View {
        Color.background
            .overlay {
                Image("iu")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
//                    .frame(height: sceneSize.height + safeAreaInsets.top + safeAreaInsets.bottom)
            }
            .ignoresSafeArea()
    }
}

// MARK: - chat list
extension TalkView {
    var chatListView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                ForEach(0..<model.chats.count, id: \.self) { index in
                    if let chat = model.chats[safe: index] {
                        if chat.role == .assistant {
                            opponentChatView(chat, index: index)
                        } else {
                            userChatView(chat, index: index)
                        }
                    }
                }
            }
        }
        .contentMargins(.bottom, safeAreaInsets.bottom + 32)
        .mask(alignment: .top) {
            VStack(spacing: 0) {
                LinearGradient(
                    gradient: Gradient(colors: [
                        .black.opacity(1),
                        .black.opacity(0)
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 64)
                Color.black
            }
        }
    }
    
    func opponentChatView(_ chat: EntityChat, index: Int) -> some View {
        HStack {
            Text("\(index) : " + chat.message)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(Color.label1)
                .multilineTextAlignment(.leading)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 16))
            Spacer()
        }
        .padding(.horizontal)
    }
    
    func userChatView(_ chat: EntityChat, index: Int) -> some View {
        HStack {
            Spacer()
            Text("\(index) : " + chat.message)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(Color.white)
                .multilineTextAlignment(.trailing)
                .padding()
                .background(Color.appPrimary)
                .clipShape(.rect(cornerRadius: 16))
        }
        .padding(.horizontal)
    }
}

// MARK: - control view
extension TalkView {
    var controlView: some View {
        VStack(spacing: 0) {
            VStack {
                if speaking {
                    HStack {
                        Spacer()
                        hintButton
                    }
                    .overlay {
                        SpeakAlertView()
                    }
                    Text(speakInput)
                        .font(.title3)
                        .foregroundStyle(Color.label1)
                        .multilineTextAlignment(.center)
                        .frame(minHeight: 64)
                        .overlay {
                            "ellipsis".iconButton(font: .title, monochrome: .label2)
                                .symbolEffect(.variableColor)
                        }
                }
            }
            .padding(.top)
            .padding(.horizontal)
            
            Color.clear.frame(height: safeAreaInsets.bottom)
        }
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 32))
        .shadow(color: .black.opacity(0.3), radius: 4)
    }
    
    var hintButton: some View {
        "questionmark.circle.fill".iconButton(font: .title, palette: .label1, .appPrimary)
    }
}

private struct SpeakAlertView: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var count = 0

    var body: some View {
        HStack {
            "microphone.circle.fill".iconButton(font: .title3, palette: .label1, .red)
            Text("Speak now")
                .font(.headline)
                .foregroundStyle(.label1)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.regularMaterial)
        .clipShape(.capsule)
        .opacity(count % 3 == 2 ? 0 : 1)
        .onReceive(timer) { val in
            withAnimation {
                count += 1
            }
        }
    }
}
