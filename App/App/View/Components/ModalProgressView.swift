//
//  ModalProgressView.swift
//  App
//
//  Created by Yongsik Kim on 12/28/24.
//

import SwiftUI

struct ModalProgressView: View {
    let text: String?
    let onTap: (() -> Void)?
    
    init(text: String? = nil, onTap: (() -> Void)? = nil) {
        self.text = text
        self.onTap = onTap
    }
    
    var body: some View {
        Color.black.opacity(0.8)
            .overlay {
                VStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color.white)
                    if let text {
                        Text(text)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
            }
            .modify {
                if let onTap {
                    $0.onTapGesture {
                        onTap()
                    }
                } else {
                    $0
                }
            }
    }
}
